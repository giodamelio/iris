use anyhow::{anyhow, Result};
use chrono::{Duration, Utc};
use serde::{Deserialize, Serialize};
use surrealdb::{opt::RecordId, sql::Datetime};

use crate::db::{Countable, Named};

use super::User;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvitePasskey {
    pub id: Option<RecordId>,
    pub user: RecordId,
    pub valid_until: Datetime,
    pub used: bool,
    pub created_at: Datetime,
}

impl InvitePasskey {
    pub fn for_user(user_id: User) -> Result<Self> {
        Ok(Self {
            id: None,
            user: user_id.id.ok_or(anyhow!("User ID cannot be converted"))?,
            valid_until: (Utc::now() + Duration::minutes(10)).into(),
            used: false,
            created_at: Utc::now().into(),
        })
    }
}

impl Countable for InvitePasskey {}
impl Named for InvitePasskey {
    fn name() -> &'static str {
        "invite_passkey"
    }
}
