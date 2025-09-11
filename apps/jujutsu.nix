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
    home.packages = with pkgs; [jjui watchman];
    programs = {
      jujutsu = {
        enable = true;
        settings = {
          user = {
            name = "Colorman";
            email = "foss@colorman.me";
          };
          revset-aliases = {
            "branchpoints()" = ''
              roots(::@ ~ ::trunk()) & mine()
            '';
            # Shows all mutable (+ trunk) changes up to youngest forkpoint,
            # skipping immutable changes
            "wip()" = ''
              fork_point(mutable() | trunk()) | (mutable() | trunk() | @-)
            '';
            # Shows all mutable heads
            "h()" = ''
              heads(mutable() | trunk())
            '';
          };
          ui = {
            log-word-wrap = true;
            paginate = "never";
            editor =
              if ((stringLength editor) != 0)
              then editor
              else "pico";
            movement.edit = true;
            default-command = ["l" "-r" "wip()"];
          };
          signing = {
            behavior = "drop";
            backend = "ssh";
            key = "~/.ssh/id_ed25519.pub";
            backends.ssh.program = "${openssh}/bin/ssh-keygen";
          };
          git = {
            sign-on-push = true;
            private-commits = ''
              description(glob-i:'wip:*') | description(glob-i:'ai:*')
            '';
            executable-path = "${getExe git}";
            track-default-bookmark-on-clone = true;
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
            r = ["rebase"];
            # The forkup alias rebases all current forks onto the trunk. Useful
            # when there are multiple parallel local branches that should all
            # be kept up to date with the trunk.
            forkup = [
              "util"
              "exec"
              "--"
              (getExe config.users.users."${username}".shell)
              "-c"
              "jj rebase -s 'all:branchpoints()' -A 'trunk()' && jj simplify-parents"
            ];
          };
        };
      };
      fish.shellAbbrs.j = "jj";
    };
  };
}
