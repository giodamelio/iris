use maud::{html, Markup, DOCTYPE};

pub fn layout(m: Markup) -> Markup {
    html! {
        (DOCTYPE)

        head {
            meta charset="utf-8";
            meta name="viewport" content="width=device-width, initial-scale=1";
            meta name="color-scheme" content="light dark";

            link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.min.css";
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
                            a href="/" { "Home" }
                        }
                        li {
                            a href="/users" { "Users" }
                        }
                        li {
                            a href="/groups" { "Groups" }
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
