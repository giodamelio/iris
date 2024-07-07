use anyhow::{anyhow, Result};
use maud::html;
use poem::session::{CookieConfig, CookieSession, Session};
use poem::web::cookie::CookieKey;
use poem::web::Data;
use poem::{get, handler, EndpointExt, Route};
use serde::{Deserialize, Serialize};
use tokio::sync::OnceCell;

use crate::db::DB;
use crate::extractors::ExtractById;
use crate::models::InvitePasskey;
use crate::template::Template;
use crate::views::layout;

// Get or generate our cookie key
static COOKIE_KEY: OnceCell<CookieKey> = OnceCell::const_new();
async fn get_key_from_db_or_generate(db: &DB) -> Result<CookieKey> {
    use base64::prelude::*;

    // Create temp struct for KV data
    #[derive(Debug, Clone, Serialize, Deserialize)]
    struct Key {
        key: String,
    }

    // Get or generate key
    let key_from_db: Option<Key> = db.select(("kv", "cookie_key")).await?;
    let key_bytes = if let Some(key) = key_from_db {
        BASE64_STANDARD.decode(key.key)?
    } else {
        // Generate key and base64 encode
        let new_key = CookieKey::try_generate().ok_or(anyhow!("Could not generate key"))?;
        let encoded_key = Key {
            key: BASE64_STANDARD.encode(new_key.master()),
        };

        // Save new key to the db
        db.create::<Option<Key>>(("kv", "cookie_key"))
            .content(encoded_key)
            .await?;

        new_key.master().to_vec()
    };
    Ok(CookieKey::derive_from(&key_bytes))
}
async fn cookie_key(db: &DB) -> Result<&CookieKey> {
    COOKIE_KEY
        .get_or_try_init(|| async { get_key_from_db_or_generate(db).await })
        .await
}

pub async fn routes(db: &DB) -> Result<impl EndpointExt> {
    let cookie_key = cookie_key(db).await?;

    Ok(Route::new()
        .at("/", get(index))
        .at("/invite/passkey/:invite_passkey_id", get(invite_passkey))
        .with(CookieSession::new(CookieConfig::private(
            cookie_key.clone(),
        ))))
}

#[handler]
async fn index(session: &Session) -> Result<Template> {
    let count = session.get::<i32>("count").unwrap_or(0) + 1;
    session.set("count", count);

    let response = html! {
        article {
            header {
                strong {
                    "HELLO WORLD"
                }
            }
            "You have been here " (count) " times!"
        }
    };

    Ok(layout(response).into())
}

#[handler]
async fn invite_passkey(
    _session: &Session,
    Data(db): Data<&DB>,
    ExtractById(invite): ExtractById<InvitePasskey>,
) -> Result<Template> {
    if !invite.is_valid() {
        return Ok(layout(html! {
            h1 { "Invite expired or already used" }
        })
        .into());
    }

    let user = invite.user(db).await?;

    let response = html! {
        h1 { "Register Passkey for " (user.email) }
        form {
            input type="text" placeholder="Passkey Name" {}
            input type="submit" value="Create Passkey" {}
        }
    };

    Ok(layout(response).into())
}
