use anyhow::Result;
use serde::{Deserialize, Serialize};
use surrealdb::opt::RecordId;

use crate::db::{Countable, Named, DB};

use super::{Group, InvitePasskey};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Option<RecordId>,
    pub name: String,
    pub email: String,
}

impl User {
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
                ",
            )
            .bind(self)
            .await?;

        Ok(response.take(0)?)
    }

    pub fn link(&self) -> String {
        format!("/admin/users/{}", self.id.clone().unwrap().id)
    }
}

impl Countable for User {}
impl Named for User {
    fn name() -> &'static str {
        "user"
    }
}
