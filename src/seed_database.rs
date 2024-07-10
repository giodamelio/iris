use tracing::info;

use crate::db::Named;
use crate::models::{AuditLog, Group, User};

mod db;
mod models;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Setup Logging
    tracing_subscriber::fmt::init();

    // Init DB
    let db = db::init().await?;

    info!("Seeding Database with test users");

    // Delete existing data
    db.query("DELETE user").await?;
    db.query("DELETE group").await?;
    db.query("DELETE audit_log").await?;

    // Create a test Group
    AuditLog::log(&db, None, "Creating new test group").await?;
    let new_group: Vec<Group> = db
        .create(Group::name())
        .content(Group {
            id: Group::random_id(),
            name: "Test Group".to_string(),
        })
        .await?;

    AuditLog::log(&db, None, "Creating 100 test users").await?;
    for i in 1..=100 {
        let new_user: Vec<User> = db
            .create(User::name())
            .content(User::new(
                format!("Test Person {}", i),
                format!("test_{}@example.com", i),
            ))
            .await?;

        AuditLog::log(&db, Some(new_user[0].clone()), "Created new user").await?;

        // Make the user a member of the test group
        let _relate_response = db
            .query("RELATE $user->member->$group")
            .bind(("user", new_user[0].id.clone()))
            .bind(("group", new_group[0].id.clone()))
            .await?;
    }

    Ok(())
}
