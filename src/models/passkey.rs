use serde::{Deserialize, Serialize};
use surrealdb::{opt::RecordId, sql::Datetime};

use crate::db::{Countable, Named};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Passkey {
    pub id: RecordId,
    pub user: RecordId,
    pub name: String,
    pub created_at: Datetime,
    pub passkey: webauthn_rs::prelude::Passkey,
}

impl Passkey {}

impl Countable for Passkey {}
impl Named for Passkey {
    fn name() -> &'static str {
        "passkey"
    }
}
