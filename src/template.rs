use poem::{web::Html, IntoResponse};

pub struct Template(maud::Markup);

impl From<maud::Markup> for Template {
    fn from(value: maud::Markup) -> Self {
        Template(value)
    }
}

impl IntoResponse for Template {
    fn into_response(self) -> poem::Response {
        let res: Html<String> = Html::default();
        res.with_body(self.0.into_string()).into_response()
    }
}
