use serde::{Deserialize, Serialize};
use surrealdb::sql::Thing;

use crate::db::{Countable, Named};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: Option<Thing>,
    pub name: String,
    pub email: String,
}

impl Countable for User {}
impl Named for User {
    fn name() -> &'static str {
        "user"
    }
}
