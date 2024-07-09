{ pkgs, lib, config, inputs, ... }: let
  system = pkgs.stdenv.system;
in {
  languages.rust = {
    enable = true;
    channel = "nightly";
  };

  packages = with pkgs; [
    surrealdb
    cargo-watch
    openssl

    # TODO: remove this when a new version lands in Nixpkgs unstable
    inputs.nixpkgs-surrealist-pr.legacyPackages.${system}.surrealist
  ];

  processes.surrealdb = {
    exec = "${pkgs.surrealdb}/bin/surreal start --bind 127.0.0.1:8000 file:dev.db";
  };

  scripts = {
    dev.exec = "cargo watch -x run";
    seed_database.exec = "cargo run --bin seed_database";
  };

  env.RUST_LOG = "server=trace,seed_database=trace";
}
