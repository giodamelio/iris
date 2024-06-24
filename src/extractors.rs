use std::{collections::HashMap, fmt::Debug};

use poem::{
    http::StatusCode,
    web::{Data, Path},
    FromRequest,
};
use serde::de::DeserializeOwned;

use crate::db::{find_by_id, Named, DB};

pub struct ExtractById<T>(pub T);

impl<'a, T> FromRequest<'a> for ExtractById<T>
where
    T: Named + DeserializeOwned + Debug,
{
    async fn from_request(
        req: &'a poem::Request,
        _body: &mut poem::RequestBody,
    ) -> poem::Result<Self> {
        let param_name = format!("{}_id", T::name());

        // Get all the path parameters
        let Path(params): Path<HashMap<String, String>> =
            Path::from_request_without_body(req).await?;

        // Get our specifc param
        let id = params
            .get(&param_name)
            .ok_or(poem::error::Error::from_string(
                "No ID",
                StatusCode::BAD_REQUEST,
            ))?;

        // Get a reference to our database connection
        let Data(db): Data<&DB> = Data::from_request_without_body(req).await?;

        // Get our thing
        let thing: T = find_by_id(db, id)
            .await?
            .ok_or(poem::error::Error::from_string(
                format!("No such {}", T::name()),
                StatusCode::NOT_FOUND,
            ))?;

        Ok(ExtractById(thing))
    }
}
