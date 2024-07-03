use chrono::{DateTime, Utc};
use maud::{html, Markup, DOCTYPE};

pub fn datetime<D: Into<DateTime<Utc>>>(dt: D) -> Markup {
    let dt_string = dt.into().to_rfc3339();
    html! {
        time datetime=(dt_string) title=(dt_string) {
            (dt_string)
        }
    }
}

fn unpoly() -> Markup {
    html! {
        script
            src="https://cdn.jsdelivr.net/npm/unpoly@3.8.0/unpoly.min.js"
            integrity="sha384-yy6W2QJYEjmd9vxdE4pvPrJ15/5rWk4qrpd3Gp4M13xc5Hzp4pn4ZtxzsR6XUNyp"
            crossorigin="anonymous" {}
        link
            rel="stylesheet"
            href="https://cdn.jsdelivr.net/npm/unpoly@3.8.0/unpoly.min.css"
            integrity="sha384-Is9x4GWs06J4kBhE9CfvxKY73C9HwM+3hpw0cNkpgAPcQnMFX04sJJSG0QXxN3zR"
            crossorigin="anonymous";
    }
}

pub fn layout(m: Markup) -> Markup {
    html! {
        (DOCTYPE)

        head {
            meta charset="utf-8";
            meta name="viewport" content="width=device-width, initial-scale=1";
            meta name="color-scheme" content="light dark";

            link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css";
            (unpoly())
            script type="module" src="/static/prettify_datetimes.js" {}
        }

        body {
            header {
                nav {
                    ul {
                        li {
                            strong { "Iris" }
                        }
                    }
                    ul {
                        li {
                            a href="/" { "Apps" }
                        }
                        li {
                            a href="/settings" { "Settings" }
                        }
                    }
                }
            }
            main {
                (m)
            }
        }
    }
}

pub fn admin_layout(m: Markup) -> Markup {
    html! {
        (DOCTYPE)

        head {
            meta charset="utf-8";
            meta name="viewport" content="width=device-width, initial-scale=1";
            meta name="color-scheme" content="light dark";

            link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css";
            (unpoly())
            script type="module" src="/static/prettify_datetimes.js" {}
        }

        body {
            header {
                nav {
                    ul {
                        li {
                            strong { "Iris Admin" }
                        }
                    }
                    ul {
                        li {
                            a href="/admin" { "Home" }
                        }
                        li {
                            a href="/admin/audit_log" { "Audit Log" }
                        }
                        li {
                            a href="/admin/users" { "Users" }
                        }
                        li {
                            a href="/admin/groups" { "Groups" }
                        }
                    }
                }
            }
            main {
                (m)
            }
        }
    }
}
