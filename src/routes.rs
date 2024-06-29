use anyhow::Result;
use maud::html;
use poem::session::{CookieConfig, CookieSession, Session};
use poem::web::cookie::CookieKey;
use poem::{get, handler, EndpointExt, Route};
use tokio::sync::OnceCell;

use crate::db::DB;
use crate::template::Template;
use crate::views::layout;

// Get or generate our cookie key
static COOKIE_KEY: OnceCell<CookieKey> = OnceCell::const_new();
pub async fn cookie_key(db: &DB) -> &CookieKey {
    COOKIE_KEY
        .get_or_init(|| async { CookieKey::generate() })
        .await
}

pub async fn routes(db: &DB) -> impl EndpointExt {
    let cookie_key = cookie_key(db).await;

    Route::new()
        .at("/", get(index))
        .with(CookieSession::new(CookieConfig::private(
            cookie_key.clone(),
        )))
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
