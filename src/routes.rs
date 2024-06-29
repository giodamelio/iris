use anyhow::Result;
use maud::html;
use poem::{get, handler, Route};

use crate::template::Template;
use crate::views::layout;

pub fn routes() -> poem::Route {
    Route::new().at("/", get(index))
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
