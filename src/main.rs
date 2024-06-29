use poem::endpoint::EmbeddedFilesEndpoint;
use poem::{listener::TcpListener, middleware::AddData, EndpointExt, Route, Server};
use rust_embed::Embed;
use tracing::{debug, info};

use crate::db::Named;
use crate::models::{AuditLog, Group, User};

mod admin;
mod db;
mod extractors;
mod models;
mod routes;
mod template;
mod views;

#[derive(Embed)]
#[folder = "static/"]
struct Assets;

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
        db.query("DELETE audit_log").await?;

        // Create a test Group
        AuditLog::log(&db, None, "Creating new test group").await?;
        let new_group: Vec<Group> = db
            .create(Group::name())
            .content(Group {
                id: None,
                name: "Test Group".to_string(),
            })
            .await?;

        AuditLog::log(&db, None, "Creating 100 test users").await?;
        for i in 1..=100 {
            let new_user: Vec<User> = db
                .create(User::name())
                .content(User {
                    id: None,
                    name: format!("Test Person {}", i),
                    email: format!("test_{}@example.com", i),
                })
                .await?;

            AuditLog::log(&db, Some(new_user[0].clone()), "Created new user").await?;

            // Make the user a member of the test group
            let _relate_response = db
                .query("RELATE $user->member->$group")
                .bind(("user", new_user[0].id.clone()))
                .bind(("group", new_group[0].id.clone()))
                .await?;
        }
    }

    let app = Route::new()
        .nest("/", routes::routes(&db).await?)
        .nest("/admin", admin::routes())
        .nest("/static", EmbeddedFilesEndpoint::<Assets>::new())
        .with(AddData::new(db));

    // Run our app
    info!("Starting server on http://127.0.0.1:3000");
    Server::new(TcpListener::bind("127.0.0.1:3000"))
        .run(app)
        .await?;

    Ok(())
}
