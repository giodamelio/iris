use anyhow::Result;
use serde::{Deserialize, Serialize};
use surrealdb::opt::RecordId;

use crate::db::{Countable, Named, DB};

use super::Group;

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
}

impl Countable for User {}
impl Named for User {
    fn name() -> &'static str {
        "user"
    }
}
