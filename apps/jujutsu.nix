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
    config.home-manager.users."${username}".home.sessionVariables.EDITOR
    or "";
in {
  home-manager.users.${username} = {
    # fs monitor
    home.packages = [pkgs.watchman];
    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Colorman";
          email = "foss@colorman.me";
        };
        # Make commits authored by other people immutable
        revset-aliases."immutable_heads()" = ''
          builtin_immutable_heads() | (trunk().. & ~mine())
        '';
        ui = {
          log-word-wrap = true;
          paginate = "never";
          editor =
            if ((stringLength editor) != 0)
            then editor
            else "pico";
          movement.edit = true;
          default-command = "l";
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
        # template for showing diff during a jj describe
        # https://github.com/jj-vcs/jj/issues/1946#issuecomment-2561045057
        templates.draft_commit_description = ''
          concat(
            coalesce(description, default_commit_description, "\n"),
            surround(
              "\nJJ: This commit contains the following changes:\n", "",
              indent("JJ:     ", diff.stat(72)),
            ),
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';

        aliases = {
          l = ["log" "--reversed"];
          d = ["describe"];
          p = ["prev"];
          n = ["next"];
          gp = ["git" "push"];
          gf = ["git" "fetch"];
          setmain = ["bookmark" "set" "main" "-r=@-"];
        };
      };
    };
  };
}
