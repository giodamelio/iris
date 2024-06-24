use std::{collections::HashMap, fmt::Debug, sync::Arc};

use axum::{
    async_trait,
    extract::{FromRequestParts, Path, State},
    http::{request::Parts, StatusCode},
    routing::get,
    Router,
};
use maud::{html, Markup};
use serde::{de::DeserializeOwned, Deserialize, Serialize};
use surrealdb::sql::Thing;
use tracing::{debug, info, trace};

use crate::db::{find_by_id, Countable, Named, DB};
use crate::error::Result;

mod db;
mod error;
mod views;

#[derive(Debug, Clone, Serialize, Deserialize)]
struct User {
    id: Option<Thing>,
    name: String,
    email: String,
}

impl db::Countable for User {}
impl db::Named for User {
    fn name() -> &'static str {
        "user"
    }
}

struct ExtractById<T>(T);

#[async_trait]
impl<T> FromRequestParts<Arc<DB>> for ExtractById<T>
where
    T: db::Named + DeserializeOwned + Debug,
{
    type Rejection = (StatusCode, String);

    async fn from_request_parts(
        parts: &mut Parts,
        state: &Arc<DB>,
    ) -> std::result::Result<Self, Self::Rejection> {
        let param_name = format!("{}_id", T::name());

        // Get a hashmap of all the path params
        let Path(params): Path<HashMap<String, String>> =
            Path::from_request_parts(parts, state).await.map_err(|e| {
                trace!("Path param error: {:?}", e);
                (StatusCode::INTERNAL_SERVER_ERROR, "Invalid ID".to_string())
            })?;

        // Get our specifc param
        let id = params
            .get(&param_name)
            .ok_or((StatusCode::INTERNAL_SERVER_ERROR, "Invalid ID".to_string()))?;

        // Query the database
        let not_found_error = (StatusCode::NOT_FOUND, format!("{} not found", T::name()));
        let thing: T = find_by_id(state.clone(), id)
            .await
            .map_err(|e| {
                trace!(
                    "Cannot find {} with id of {}. Error: {:?}",
                    T::name(),
                    id,
                    e
                );
                not_found_error.clone()
            })?
            .ok_or(not_found_error)?;

        Ok(ExtractById(thing))
    }
}

#[derive(Debug, Deserialize)]
struct Record {
    #[allow(dead_code)]
    id: Thing,
}

async fn home(State(db): State<Arc<DB>>) -> Result<Markup> {
    let count: usize = User::count(&db).await?;

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

    Ok(views::layout(response))
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

async fn users_index(State(db): State<Arc<DB>>) -> Result<Markup> {
    let users: Vec<User> = db.select(User::name()).await?;

    let response = html! {
        h1 { "Users" }

        @for user in &users {
            (user_card(&user))
        }
    };

    Ok(views::layout(response))
}

async fn users_show(ExtractById(user): ExtractById<User>) -> Result<Markup> {
    info!("Extracted User: {:#?}", user);

    let response = html! {
        h1 { "Users" }
        (user_card(&user))
    };

    Ok(views::layout(response))
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
                    id: None,
                    name: format!("Test Person {}", i),
                    email: format!("test_{}@example.com", i),
                })
                .await?;
        }
    }

    // Setup our server
    let app = Router::new()
        .route("/", get(home))
        .route("/users", get(users_index))
        .route("/users/:user_id", get(users_show))
        .with_state(Arc::new(db));

    // Run our app with Hyper
    info!("Starting server on http://127.0.0.1:3000");
    let listener = tokio::net::TcpListener::bind("127.0.0.1:3000").await?;
    axum::serve(listener, app).await?;

    Ok(())
}
