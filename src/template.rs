use poem::IntoResponse;

pub struct Template(maud::Markup);

impl From<maud::Markup> for Template {
    fn from(value: maud::Markup) -> Self {
        Template(value)
    }
}

impl IntoResponse for Template {
    fn into_response(self) -> poem::Response {
        self.0.into_string().into()
    }
}
