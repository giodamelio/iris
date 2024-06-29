use anyhow::Result;
use maud::html;
use poem::session::{CookieConfig, MemoryStorage, ServerSession};
use poem::{get, handler, EndpointExt, Route};

use crate::template::Template;
use crate::views::layout;

pub fn routes() -> impl EndpointExt {
    Route::new()
        .at("/", get(index))
        .with(ServerSession::<MemoryStorage>::new(
            CookieConfig::new(),
            MemoryStorage::new(),
        ))
}

#[handler]
async fn index() -> Result<Template> {
    let response = html! {
        article {
            header {
                strong {
                    "HELLO"
                }
            }
            "WORLD"
        }
    };

    Ok(layout(response).into())
}
