use std::fmt::Debug;

use anyhow::Result;
use maud::{html, Markup};
use models::Group;
use poem::{
    get, handler, listener::TcpListener, middleware::AddData, web::Data, EndpointExt, Route, Server,
};
use serde::Deserialize;
use surrealdb::sql::Thing;
use tracing::{debug, info};

use crate::db::{Countable, Named, DB};
use crate::extractors::ExtractById;
use crate::models::User;
use crate::template::Template;

mod db;
mod extractors;
mod models;
mod template;
mod views;

#[derive(Debug, Deserialize)]
struct Record {
    #[allow(dead_code)]
    id: Thing,
}

fn user_card(user: &User) -> Markup {
    html! {
        article {
            header { strong { (user.name) } }
            ul {
                li {
                    strong { "ID: " }
                    (user.id.clone().unwrap().id)
                }
                li {
                    strong { "Email: " }
                    (user.email)
                }
            }
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Setup Logging
    tracing_subscriber::fmt::init();

    // Init DB
    let db = db::init().await?;

    // Create some test users if they don't exist
    if User::count(&db).await? == 0 {
        debug!("Creating 100 test users");

        // Create a test Group
        let _new_group: Vec<Record> = db
            .create(Group::name())
            .content(Group {
                id: None,
                name: "Test Group".to_string(),
            })
            .await?;

        for i in 1..=100 {
            let _created: Vec<Record> = db
                .create(User::name())
                .content(User {
                    id: None,
                    name: format!("Test Person {}", i),
                    email: format!("test_{}@example.com", i),
                })
                .await?;
        }
    }

    // Run our app
    info!("Starting server on http://127.0.0.1:3000");
    let app = Route::new()
        .at("/", get(index))
        .at("/users", get(users_index))
        .at("/users/:user_id", get(users_show))
        .with(AddData::new(db));
    Server::new(TcpListener::bind("127.0.0.1:3000"))
        .run(app)
        .await?;

    Ok(())
}

#[handler]
async fn index(Data(db): Data<&DB>) -> Result<Template> {
    let count: usize = User::count(db).await?;

    let response = html! {
        article {
            header {
                strong {
                    "Users"
                }
            }
            (count) " registered users "
            a href="/users" { "View Users" }
        }
    };

    Ok(views::layout(response).into())
}

#[handler]
async fn users_index(Data(db): Data<&DB>) -> Result<Template> {
    let users: Vec<User> = db.select(User::name()).await?;

    let response = html! {
        h1 { "Users" }

        @for user in &users {
            (user_card(&user))
        }
    };

    Ok(views::layout(response).into())
}

#[handler]
async fn users_show(ExtractById(user): ExtractById<User>) -> Result<Template> {
    info!("Extracted User: {:#?}", user);

    let response = html! {
        h1 { "Users" }
        (user_card(&user))
    };

    Ok(views::layout(response).into())
}
