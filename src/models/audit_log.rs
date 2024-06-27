use anyhow::Result;
use chrono::Utc;
use serde::{Deserialize, Serialize};
use surrealdb::{opt::RecordId, sql::Datetime};

use crate::db::{Countable, Named, DB};

use super::User;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuditLog {
    pub id: Option<RecordId>,
    pub performed_at: Datetime,
    pub message: String,
}

impl AuditLog {
    pub async fn log<S>(db: &DB, user: Option<User>, message: S) -> Result<()>
    where
        S: Into<String>,
    {
        // Create the audit log entry
        let log_entry: Vec<AuditLog> = db
            .create(Self::name())
            .content(AuditLog {
                id: None,
                performed_at: Utc::now().into(),
                message: message.into(),
            })
            .await?;

        // Link the user if they are passed in
        if let Some(u) = user {
            let _relate_response = db
                .query("RELATE $user->performed->$log_entry")
                .bind(("user", u.id))
                .bind(("log_entry", log_entry[0].id.clone()))
                .await?;
        }

        Ok(())
    }
}

impl Countable for AuditLog {}
impl Named for AuditLog {
    fn name() -> &'static str {
        "audit_log"
    }
}
