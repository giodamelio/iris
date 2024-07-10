use anyhow::Result;
use serde::{Deserialize, Serialize};
use surrealdb::opt::RecordId;

use crate::db::{Countable, Named, DB};

use super::{Group, InvitePasskey};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: RecordId,
    pub webauthn_id: surrealdb::sql::Uuid,
    pub name: String,
    pub email: String,
}

impl User {
    pub fn new<S: Into<String>>(name: S, email: S) -> Self {
        Self {
            id: User::random_id(),
            webauthn_id: surrealdb::sql::Uuid::new_v7(),
            name: name.into(),
            email: email.into(),
        }
    }

    pub fn webauth_id(&self) -> webauthn_rs::prelude::Uuid {
        self.webauthn_id.into()
    }

    pub async fn groups(&self, db: &DB) -> Result<Vec<Group>> {
        let mut response = db
            .query("SELECT VALUE ->member->group.* AS groups FROM ONLY $id")
            .bind(self)
            .await?;

        Ok(response.take(0)?)
    }

    pub async fn invite_passkeys(&self, db: &DB) -> Result<Vec<InvitePasskey>> {
        let mut response = db
            .query(
                "
                SELECT * FROM invite_passkey
                WHERE user.id = $id
                ORDER BY created_at DESC
                ",
            )
            .bind(self)
            .await?;

        Ok(response.take(0)?)
    }

    pub fn link(&self) -> String {
        format!("/admin/users/{}", self.id.id)
    }
}

impl Countable for User {}
impl Named for User {
    fn name() -> &'static str {
        "user"
    }
}
