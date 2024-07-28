{ pkgs, lib, config, inputs, ... }: {
  languages.elixir.enable = true;

  packages = with pkgs; [
    inotify-tools
  ];

  env.ELIXIRLS_CMD = "${pkgs.elixir-ls}/lib/language_server.sh";

  enterShell = ''
    export HEX_HOME="$DEVENV_ROOT/.hex";
    export MIX_HOME="$DEVENV_ROOT/.mix";
  '';

  pre-commit = {
    default_stages = ["pre-commit" "pre-push"];
    hooks = {
      mix-format.enable = true;
      mix-test.enable = true;
      credo = {
        enable = true;
        settings.strict = true;
      };
    };
  };
}
