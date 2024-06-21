use std::fmt::Debug;

use anyhow::{Context, Result};
use serde::Deserialize;
use surrealdb::engine::remote::http::{Client, Http};
use surrealdb::Surreal;

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
        let count: Count = db
            .query("SELECT count() FROM type::table($table) GROUP BY count")
            .bind(("table", Self::name()))
            .await?
            .take::<Option<Count>>(0)?
            .context("Cannot get count")?;

        Ok(count.count)
    }
}

pub type DB = Surreal<Client>;

pub async fn init() -> Result<DB> {
    let db = Surreal::new::<Http>("localhost:8000").await?;
    db.use_ns("test").use_db("test").await?;
    Ok(db)
}
