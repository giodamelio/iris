use poem::endpoint::EmbeddedFilesEndpoint;
use poem::middleware::Tracing;
use poem::{listener::TcpListener, middleware::AddData, EndpointExt, Route, Server};
use rust_embed::Embed;
use tracing::info;

mod admin;
mod db;
mod extractors;
mod models;
mod routes;
mod template;
mod views;

#[derive(Embed)]
#[folder = "static/"]
struct Assets;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Setup Logging
    tracing_subscriber::fmt::init();

    // Init DB
    let db = db::init().await?;

    // Build our route table
    let app = Route::new()
        .nest("/", routes::routes(&db).await?)
        .nest("/admin", admin::routes())
        .nest("/static", EmbeddedFilesEndpoint::<Assets>::new())
        .with(Tracing)
        .with(AddData::new(db));

    // Run our app
    info!("Starting server on http://127.0.0.1:3000");
    Server::new(TcpListener::bind("127.0.0.1:3000"))
        .run(app)
        .await?;

    Ok(())
}
