use anyhow::Result;
use maud::{html, Markup};
use models::Group;
use poem::{
    get, handler, listener::TcpListener, middleware::AddData, web::Data, EndpointExt, Route, Server,
};
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

fn user_card(user: &User) -> Markup {
    html! {
        article {
            header {
                a href=(format!("/users/{}", user.clone().id.unwrap().id)) {
                    strong {
                        (user.name)
                    }
                }
            }
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
    if true {
        debug!("Creating 100 test users");

        // Create a test Group
        let new_group: Vec<Group> = db
            .create(Group::name())
            .content(Group {
                id: None,
                name: "Test Group".to_string(),
            })
            .await?;

        for i in 1..=100 {
            let new_user: Vec<User> = db
                .create(User::name())
                .content(User {
                    id: None,
                    name: format!("Test Person {}", i),
                    email: format!("test_{}@example.com", i),
                })
                .await?;

            // Make the user a member of the test group
            let _relate_response = db
                .query("RELATE $user->member->$group")
                .bind(("user", new_user[0].id.clone()))
                .bind(("group", new_group[0].id.clone()))
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
            a href="/users" { "View" }
        }
        article {
            header {
                strong {
                    "Groups"
                }
            }
            (count) " groups "
            a href="/groups" { "View" }
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
async fn users_show(Data(db): Data<&DB>, ExtractById(user): ExtractById<User>) -> Result<Template> {
    let groups = user.groups(db).await?;

    let response = html! {
        h1 { "User" }
        (user_card(&user))

        article {
            h2 { "Member Groups" }
            ul {
                @for group in &groups {
                    li { (group.name) }
                }
            }
        }
    };

    Ok(views::layout(response).into())
}
