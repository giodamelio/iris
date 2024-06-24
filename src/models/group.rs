use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;

use crate::db::{Countable, Named};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Group {
    pub id: Option<Thing>,
    pub name: String,
}

impl Countable for Group {}
impl Named for Group {
    fn name() -> &'static str {
        "group"
    }
}
