use std::sync::Arc;

use axum::{extract::State, routing::get, Router};
use maud::{html, Markup};
use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;
use tracing::{debug, info};

use crate::db::{Countable, Named, DB};
use crate::error::Result;

mod db;
mod error;

#[derive(Debug, Serialize)]
struct User {
    email: String,
}

impl db::Countable for User {}
impl db::Named for User {
    fn name() -> &'static str {
        "user"
    }
}

#[derive(Debug, Deserialize)]
struct Record {
    #[allow(dead_code)]
    id: Thing,
}

async fn count_users(State(db): State<Arc<DB>>) -> Result<Markup> {
    let count: usize = User::count(&db).await?;

    let response = html! {
        p { "There are " (count) " users!" }
    };

    Ok(response)
}

#[tokio::main]
async fn main() -> Result<()> {
    // Setup Logging
    tracing_subscriber::fmt::init();

    // Init DB
    let db = db::init().await?;

    // Create some test users if they don't exist
    if User::count(&db).await? == 0 {
        debug!("Creating 100 test users");

        for i in 1..=100 {
            let _created: Vec<Record> = db
                .create(User::name())
                .content(User {
                    email: format!("test_{}@example.com", i),
                })
                .await?;
        }
    }

    // Setup our server
    let app = Router::new()
        .route("/", get(count_users))
        .with_state(Arc::new(db));

    // Run our app with Hyper
    info!("Starting server on http://127.0.0.1:3000");
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;

    Ok(())
}
