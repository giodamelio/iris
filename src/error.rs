use axum::{http::StatusCode, response::IntoResponse};

#[derive(Debug)]
pub struct AppError(anyhow::Error);

// Convience wrapper similar to anyhow::Result
pub type Result<T> = std::result::Result<T, AppError>;

// Render our errors into a string
// Only include the actual error when debug assertions are enabled
impl IntoResponse for AppError {
    fn into_response(self) -> axum::response::Response {
        #[cfg(debug_assertions)]
        let response = format!("500 INTERNAL SERVER ERROR\n\n{}", self.0);

        #[cfg(not(debug_assertions))]
        let response = "500 INTERNAL SERVER ERROR".to_string();

        (StatusCode::INTERNAL_SERVER_ERROR, response).into_response()
    }
}

// This enables using `?` on functions that return `Result<_, anyhow::Error>` to turn them into
// `Result<_, AppError>`. That way you don't need to do that manually.
impl<E> From<E> for AppError
where
    E: Into<anyhow::Error>,
{
    fn from(err: E) -> Self {
        Self(err.into())
    }
}
