{ pkgs, lib, config, inputs, ... }: {
  languages.elixir.enable = true;

  enterShell = ''
    export HEX_HOME="$DEVENV_ROOT/.hex";
    export MIX_HOME="$DEVENV_ROOT/.mix";
  '';
}
