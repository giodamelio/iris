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
                a href=(format!("/admin/users/{}", user.clone().id.unwrap().id)) {
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

fn group_card(group: &Group) -> Markup {
    html! {
        article {
            header {
                a href=(format!("/admin/groups/{}", group.clone().id.unwrap().id)) {
                    strong {
                        (group.name)
                    }
                }
            }
            ul {
                li {
                    strong { "ID: " }
                    (group.id.clone().unwrap().id)
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
        debug!("Creating Test Data");

        // Delete existing data
        db.query("DELETE user").await?;
        db.query("DELETE group").await?;

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

    // Build our routing table
    let admin_router = Route::new()
        .at("/", get(index))
        .at("/users", get(users_index))
        .at("/users/:user_id", get(users_show))
        .at("/groups", get(groups_index))
        .at("/groups/:group_id", get(groups_show));

    let app = Route::new()
        .nest("/admin", admin_router)
        .with(AddData::new(db));

    // Run our app
    info!("Starting server on http://127.0.0.1:3000");
    Server::new(TcpListener::bind("127.0.0.1:3000"))
        .run(app)
        .await?;

    Ok(())
}

#[handler]
async fn index(Data(db): Data<&DB>) -> Result<Template> {
    let users_count: usize = User::count(db).await?;
    let groups_count: usize = Group::count(db).await?;

    let response = html! {
        article {
            header {
                strong {
                    "Users"
                }
            }
            (users_count) " registered users "
            a href="/admin/users" { "View" }
        }
        article {
            header {
                strong {
                    "Groups"
                }
            }
            (groups_count) " groups "
            a href="/admin/groups" { "View" }
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

#[handler]
async fn groups_index(Data(db): Data<&DB>) -> Result<Template> {
    let groups: Vec<Group> = db.select(Group::name()).await?;

    let response = html! {
        h1 { "Groups" }

        @for group in &groups {
            (group_card(&group))
        }
    };

    Ok(views::layout(response).into())
}

#[handler]
async fn groups_show(ExtractById(group): ExtractById<Group>) -> Result<Template> {
    let response = html! {
        h1 { "Group" }
        (group_card(&group))
    };

    Ok(views::layout(response).into())
}
