use serde::{Deserialize, Serialize};
use surrealdb::opt::RecordId;

use crate::db::{Countable, Named};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: RecordId,
    pub name: String,
}

impl Group {
    pub fn link(&self) -> String {
        format!("/admin/groups/{}", self.id.id)
    }
}

impl Countable for Group {}
impl Named for Group {
    fn name() -> &'static str {
        "group"
    }
}
