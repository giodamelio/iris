{ pkgs, lib, config, inputs, ... }: let
  system = pkgs.stdenv.system;
in {
  languages.rust = {
    enable = true;
    channel = "nightly";
  };

  packages = with pkgs; [
    surrealdb

    # TODO: remove this when a new version lands in Nixpkgs unstable
    inputs.nixpkgs-surrealist-pr.legacyPackages.${system}.surrealist
  ];
}
