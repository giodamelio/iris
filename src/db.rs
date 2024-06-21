use std::fmt::Debug;

use serde::Deserialize;
use surrealdb::engine::local::{Db, Mem};
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
    async fn count(db: &DB) -> surrealdb::Result<usize> {
        let count: Option<Count> = db
            .query("SELECT count() FROM type::table($table) GROUP BY count")
            .bind(("table", Self::name()))
            .await?
            .take(0)?;

        Ok(count.expect("Cannot count!").count)
    }
}

pub type DB = Surreal<Db>;

pub async fn init() -> surrealdb::Result<DB> {
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("test").use_db("test").await?;
    Ok(db)
}
