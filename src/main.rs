use std::{collections::HashMap, fmt::Debug};

use anyhow::Result;
use maud::{html, Markup};
use poem::{
    get, handler,
    http::StatusCode,
    listener::TcpListener,
    middleware::AddData,
    web::{Data, Path},
    EndpointExt, FromRequest, IntoResponse, Route, Server,
};
use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;
use tracing::{debug, info};

use crate::db::{find_by_id, Countable, Named, DB};

mod db;
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

// struct ExtractById<T>(T);
//
// #[async_trait]
// impl<T> FromRequestParts<Arc<DB>> for ExtractById<T>
// where
//     T: db::Named + DeserializeOwned + Debug,
// {
//     type Rejection = (StatusCode, String);
//
//     async fn from_request_parts(
//         parts: &mut Parts,
//         state: &Arc<DB>,
//     ) -> std::result::Result<Self, Self::Rejection> {
//         let param_name = format!("{}_id", T::name());
//
//         // Get a hashmap of all the path params
//         let Path(params): Path<HashMap<String, String>> =
//             Path::from_request_parts(parts, state).await.map_err(|e| {
//                 trace!("Path param error: {:?}", e);
//                 (StatusCode::INTERNAL_SERVER_ERROR, "Invalid ID".to_string())
//             })?;
//
//         // Get our specifc param
//         let id = params
//             .get(&param_name)
//             .ok_or((StatusCode::INTERNAL_SERVER_ERROR, "Invalid ID".to_string()))?;
//
//         // Query the database
//         let not_found_error = (StatusCode::NOT_FOUND, format!("{} not found", T::name()));
//         let thing: T = find_by_id(state.clone(), id)
//             .await
//             .map_err(|e| {
//                 trace!(
//                     "Cannot find {} with id of {}. Error: {:?}",
//                     T::name(),
//                     id,
//                     e
//                 );
//                 not_found_error.clone()
//             })?
//             .ok_or(not_found_error)?;
//
//         Ok(ExtractById(thing))
//     }
// }

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

impl<'a> FromRequest<'a> for User {
    async fn from_request(
        req: &'a poem::Request,
        _body: &mut poem::RequestBody,
    ) -> poem::Result<Self> {
        let param_name = "user_id".to_string();

        // Get all the path parameters
        let Path(params): Path<HashMap<String, String>> =
            Path::from_request_without_body(req).await?;

        // Get our specifc param
        let id = params
            .get(&param_name)
            .ok_or(poem::error::Error::from_string(
                "No ID",
                StatusCode::BAD_REQUEST,
            ))?;

        // Get a reference to our database connection
        let Data(db): Data<&DB> = Data::from_request_without_body(req).await?;

        // Get our user
        let user: User = find_by_id(db, id)
            .await?
            .ok_or(poem::error::Error::from_string(
                "No such user",
                StatusCode::NOT_FOUND,
            ))?;

        Ok(user)
    }
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
async fn users_show(user: User) -> Result<Template> {
    info!("Extracted User: {:#?}", user);

    let response = html! {
        h1 { "Users" }
        (user_card(&user))
    };

    Ok(views::layout(response).into())
}

struct Template(maud::Markup);

impl From<maud::Markup> for Template {
    fn from(value: maud::Markup) -> Self {
        Template(value)
    }
}

impl IntoResponse for Template {
    fn into_response(self) -> poem::Response {
        self.0.into_string().into()
    }
}
