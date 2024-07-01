use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use surrealdb::opt::RecordId;

use crate::db::{Countable, Named};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InvitePasskey {
    pub id: Option<RecordId>,
    pub user: RecordId,
    pub valid_until: DateTime<Utc>,
    pub used: bool,
}

impl Countable for InvitePasskey {}
impl Named for InvitePasskey {
    fn name() -> &'static str {
        "invite_passkey"
    }
}
