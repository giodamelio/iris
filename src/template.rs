use axum::response::{Html, IntoResponse};
use maud::PreEscaped;

pub struct Template(PreEscaped<String>);

impl IntoResponse for Template {
    fn into_response(self) -> axum::response::Response {
        Html(self.0.into_string()).into_response()
    }
}

impl From<PreEscaped<String>> for Template {
    fn from(value: PreEscaped<String>) -> Self {
        Self(value)
    }
}

