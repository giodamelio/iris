use std::fmt::Debug;

use serde::Deserialize;
use surrealdb::engine::remote::http::{Client, Http};
use surrealdb::Surreal;
use tracing::debug;

use crate::error::Result;

#[derive(Deserialize)]
pub struct Count {
    #[allow(dead_code)]
    pub count: usize,
}

impl Debug for Count {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.count)
    }
}

pub trait Named {
    fn name() -> &'static str;
}

pub trait Countable: Named {
    async fn count(db: &DB) -> Result<usize> {
        let mut response = db
            .query("SELECT count() FROM type::table($table) GROUP BY count")
            .bind(("table", Self::name()))
            .await?;

        match response.take::<Option<Count>>(0)? {
            None => Ok(0),
            Some(count) => Ok(count.count),
        }
    }
}

pub type DB = Surreal<Client>;

pub async fn init() -> Result<DB> {
    debug!("Connecting to DB");
    let db = Surreal::new::<Http>("localhost:8000").await?;
    db.use_ns("test").use_db("test").await?;
    Ok(db)
}
