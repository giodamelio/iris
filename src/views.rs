use maud::{html, Markup, DOCTYPE};

pub fn layout(m: Markup) -> Markup {
    html! {
        (DOCTYPE)

        head {
            meta charset="utf-8";
            meta name="viewport" content="width=device-width, initial-scale=1";
            meta name="color-scheme" content="light dark";

            link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css";
            script src="https://unpkg.com/htmx.org@2.0.0" integrity="sha384-wS5l5IKJBvK6sPTKa2WZ1js3d947pvWXbPJ1OmWfEuxLgeHcEbjUUA5i9V5ZkpCw" crossorigin="anonymous" {}
        }

        body hx-boost="true" {
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
