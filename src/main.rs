use anyhow::Result;
use axum::{routing::get, Router};
use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;

use db::{Countable, Named};

mod db;

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

#[tokio::main]
async fn main() -> Result<()> {
    // Init DB
    let db = db::init().await?;

    // Create some test users
    for i in 1..=100 {
        let _created: Vec<Record> = db
            .create(User::name())
            .content(User {
                email: format!("test_{}@example.com", i),
            })
            .await?;
    }

    // Count how many users there are
    let count: usize = User::count(&db).await?;
    println!("There are {:#?} users", count);

    // Setup our server
    let app = Router::new().route("/", get(|| async { "Hello, World!" }));

    // Run our app with Hyper
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;

    Ok(())
}
