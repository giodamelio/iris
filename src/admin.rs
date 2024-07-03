use anyhow::{anyhow, Result};
use maud::{html, Markup};
use poem::post;
use poem::web::{Form, Redirect};
use poem::{get, handler, web::Data, Route};
use serde::Deserialize;
use surrealdb::sql::Datetime;

use crate::db::{find_by_id, Countable, Named, DB};
use crate::extractors::ExtractById;
use crate::models::{Group, InvitePasskey, User};
use crate::template::Template;
use crate::views::{admin_layout, datetime};

pub fn routes() -> poem::Route {
    Route::new()
        .at("/", get(index))
        .at("/audit_log", get(audit_log_index))
        .at("/users", get(users_index))
        .at("/users/:user_id", get(users_show))
        .at("/groups", get(groups_index))
        .at("/groups/:group_id", get(groups_show))
        .at("/invite/passkey", post(create_invite_passkey))
}

#[handler]
async fn index(Data(db): Data<&DB>) -> Result<Template> {
    let users_count: usize = User::count(db).await?;
    let groups_count: usize = Group::count(db).await?;

    let response = html! {
        article {
            header {
                strong {
                    "Users"
                }
            }
            (users_count) " registered users "
            a href="/admin/users" { "View" }
        }
        article {
            header {
                strong {
                    "Groups"
                }
            }
            (groups_count) " groups "
            a href="/admin/groups" { "View" }
        }
    };

    Ok(admin_layout(response).into())
}

#[handler]
async fn audit_log_index(Data(db): Data<&DB>) -> Result<Template> {
    #[derive(Deserialize)]
    struct LogEntry {
        performed_at: Datetime,
        performed_by: Option<User>,
        message: String,
    }
    let mut response = db
        .query(
            "
            SELECT performed_at, message, performed_by FROM audit_log
            ORDER BY performed_at DESC
            FETCH performed_by",
        )
        .await?;
    let log_entries: Vec<LogEntry> = response.take(0)?;

    let response = html! {
        h1 { "Audit Log" }

        table {
            thead {
                tr {
                    th { "Performed at" }
                    th { "Performed by" }
                    th { "Message" }
                }
            }
            tbody {
                @for entry in &log_entries {
                    tr {
                        td {
                            (datetime(entry.performed_at.clone()))
                        }
                        td {
                            @if let Some(performed_by) = &entry.performed_by {
                                a href=(performed_by.link()) {
                                    (performed_by.name)
                                }
                            } @else {
                                "SYSTEM"
                            }
                        }
                        td { (entry.message) }
                    }
                }
            }
        }
    };

    Ok(admin_layout(response).into())
}

#[handler]
async fn users_index(Data(db): Data<&DB>) -> Result<Template> {
    let users: Vec<User> = db.select(User::name()).await?;

    let response = html! {
        h1 { "Users" }

        @for user in &users {
            (user_card(&user))
        }
    };

    Ok(admin_layout(response).into())
}

#[handler]
async fn users_show(Data(db): Data<&DB>, ExtractById(user): ExtractById<User>) -> Result<Template> {
    let groups = user.groups(db).await?;
    let invites = user.invite_passkeys(db).await?;

    let response = html! {
        h1 { "User" }

        (user_card(&user))

        article #passkey-invites {
            header {
                h2 { "Passkey Invites" }
                form action="/admin/invite/passkey" method="POST" up-submit up-target="#passkey-invites" {
                    input type="hidden" name="user_id" value=(user.id.clone().unwrap().id) {}
                    input type="submit" value="New" {}
                 }
            }
            ul {
                @for invite in &invites {
                    li {
                        (invite.id.clone().unwrap().id) " (created at: " (datetime(invite.clone().created_at)) ")"
                    }
                }
            }
        }

        article {
            h2 { "Member Groups" }
            ul {
                @for group in &groups {
                    li { (group.name) }
                }
            }
        }
    };

    Ok(admin_layout(response).into())
}

#[handler]
async fn groups_index(Data(db): Data<&DB>) -> Result<Template> {
    let groups: Vec<Group> = db.select(Group::name()).await?;

    let response = html! {
        h1 { "Groups" }

        @for group in &groups {
            (group_card(&group))
        }
    };

    Ok(admin_layout(response).into())
}

#[handler]
async fn groups_show(ExtractById(group): ExtractById<Group>) -> Result<Template> {
    let response = html! {
        h1 { "Group" }
        (group_card(&group))
    };

    Ok(admin_layout(response).into())
}

#[derive(Deserialize, Debug, Clone)]
struct CreateInvitePasskey {
    user_id: String,
}

#[handler]
async fn create_invite_passkey(
    Data(db): Data<&DB>,
    Form(create_data): Form<CreateInvitePasskey>,
) -> Result<Redirect> {
    // Verify that the user exists
    let user: User = find_by_id(db, create_data.clone().user_id)
        .await?
        .ok_or(anyhow!("No such user"))?;

    // Create the invite
    let _new_invite: Vec<InvitePasskey> = db
        .create(InvitePasskey::name())
        .content(InvitePasskey::for_user(user.clone())?)
        .await?;

    Ok(Redirect::see_other(format!(
        "/admin/users/{}",
        create_data.user_id,
    )))
}

fn user_card(user: &User) -> Markup {
    html! {
        article {
            header {
                a href=(user.link()) {
                    strong {
                        (user.name)
                    }
                }
            }
            ul {
                li {
                    strong { "ID: " }
                    (user.id.clone().unwrap().id)
                }
                li {
                    strong { "Email: " }
                    (user.email)
                }
            }
        }
    }
}

fn group_card(group: &Group) -> Markup {
    html! {
        article {
            header {
                a href=(group.link()) {
                    strong {
                        (group.name)
                    }
                }
            }
            ul {
                li {
                    strong { "ID: " }
                    (group.id.clone().unwrap().id)
                }
            }
        }
    }
}
