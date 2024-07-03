use anyhow::Result;
use chrono::{Duration, Utc};
use serde::{Deserialize, Serialize};
use surrealdb::{opt::RecordId, sql::Datetime};

use crate::db::{find_by_id_error, Countable, Named, DB};

use super::User;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvitePasskey {
    pub id: RecordId,
    pub user: RecordId,
    pub valid_until: Datetime,
    pub used: bool,
    pub created_at: Datetime,
}

impl InvitePasskey {
    pub fn for_user(user_id: User) -> Result<Self> {
        Ok(Self {
            id: Self::random_id(),
            user: user_id.id,
            valid_until: (Utc::now() + Duration::minutes(10)).into(),
            used: false,
            created_at: Utc::now().into(),
        })
    }

    pub async fn user(&self, db: &DB) -> Result<User> {
        find_by_id_error(db, self.user.clone()).await
    }

    // Ensure invite has not already been used and the time is still valid
    pub fn is_valid(&self) -> bool {
        Utc::now() < self.valid_until.0 && !self.used
    }
}

impl Countable for InvitePasskey {}
impl Named for InvitePasskey {
    fn name() -> &'static str {
        "invite_passkey"
    }
}
