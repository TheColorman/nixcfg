{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.my) username;
  inherit (lib) getExe;
  inherit (pkgs) openssh git;
  inherit (builtins) stringLength;

  editor =
    config.home-manager.users."${username}".home.sessionVariables.EDITO
    or "";
in {
  home-manager.users.${username}.programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Colorman";
        email = "foss@colorman.me";
      };
      # Make commits authored by other people immutable
      revset-aliases."immutable_heads()" = ''
        builtins_immutable_heads() | (trunk().. & ~mine())
      '';
      ui = {
        log-word-wrap = true;
        paginate = "never";
        editor =
          if ((stringLength editor) != 0)
          then editor
          else "pico";
      };
      signing = {
        behavior = "drop";
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        backends.ssh.program = "${openssh}/bin/ssh-keygen";
      };
      git = {
        sign-on-push = true;
        private-commits = "description(glob:'temp:*')";
        executable-path = "${getExe git}";
      };
    };
  };
}
