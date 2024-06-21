use std::fmt::Debug;

use serde::{Deserialize, Serialize};
use surrealdb::engine::local::Mem;
use surrealdb::sql::Thing;
use surrealdb::Surreal;

#[derive(Debug, Serialize)]
struct User {
    email: String,
}

#[derive(Debug, Deserialize)]
struct Record {
    #[allow(dead_code)]
    id: Thing,
}

#[derive(Deserialize)]
struct Count {
    #[allow(dead_code)]
    count: usize,
}

impl Debug for Count {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.count)
    }
}

#[tokio::main]
async fn main() -> surrealdb::Result<()> {
    let db = Surreal::new::<Mem>(()).await?;
    db.use_ns("test").use_db("test").await?;

    // Create some test users
    for i in 1..=100 {
        let _created: Vec<Record> = db
            .create("user")
            .content(User {
                email: format!("test_{}@example.com", i),
            })
            .await?;
    }

    // Count how many users there are
    let count: Option<Count> = db
        .query("SELECT count() FROM user GROUP BY count")
        .await?
        .take(0)?;
    println!("There are {:#?} users", count.expect("Error getting count"));

    Ok(())
}
