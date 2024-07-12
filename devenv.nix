{ pkgs, lib, config, inputs, ... }: {
  languages.elixir.enable = true;

  packages = with pkgs; [
    inotify-tools
  ];

  enterShell = ''
    export HEX_HOME="$DEVENV_ROOT/.hex";
    export MIX_HOME="$DEVENV_ROOT/.mix";
  '';
}
