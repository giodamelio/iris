{ pkgs, lib, config, inputs, ... }:

{
  languages.rust = {
    enable = true;
    channel = "nightly";
  };

  packages = with pkgs; [
    surrealist
  ];
}
