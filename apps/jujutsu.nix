{
  config,
  lib,
  pkgs,
  inputs,
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
            default-command = ["l" "-r" "wip() | latest(tags()) | bookmarks()"];
            diff-editor = ":builtin";
            merge-editor = "nvim";
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
          templates = {
            # template for showing diff during a jj describe
            # https://github.com/jj-vcs/jj/issues/1946#issuecomment-2561045057
            draft_commit_description = ''
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
            # Names branches created by `jj git push -c` based on latest commit
            # message. Replaced all non-alphanumeric with -.
            # "feat(shopping): add the amazing button" ->
            # "feat/shopping-add-amazing-button"
            git_push_bookmark = ''
              description
                .first_line()
                .replace(
                  regex:"['\"]",
                  ""
                )
                .replace(
                  regex:"[^a-zA-Z0-9]+",
                  "-"
                )
                .replace(
                  regex:"-+$",
                  ""
                )
                .replace(
                  "-",
                  "/",
                  1
                )
            '';
          };

          aliases = {
            l = ["log" "--reversed"];
            d = ["describe"];
            p = ["prev"];
            n = ["next"];
            gp = ["git" "push"];
            gf = ["git" "fetch"];
            r = ["rebase"];

            # Move nearest ancestor bookmark to parent change
            tug = [
              "bookmark"
              "move"
              "--from"
              "heads(::@- & bookmarks())"
              "--to"
              "@-"
            ];
            # Rebase all mutable roots onto the trunk
            rebase-all = ["rebase" "--source" "roots(trunk()..mutable())" "--destination" "trunk()"];
          };

          merge-tools.nvim = {
            merge-args = [
              "$output"
              "-M"
              "-c"
              "set modifiable"
              "-c"
              "set write"
            ];
            merge-tool-edits-conflict-markers = true;
          };
        };
      };

      fish = {
        shellAbbrs = {
          j = "jj";
          jrt = "jj rebase -d 'trunk()' && jj simplify-parents";
          jri = "jj rebase -A 'trunk()' -B 'merge' -r";
        };

        plugins = [
          {
            name = "jj";
            src = inputs.fish-plugin-jj;
          }
        ];
      };
    };
  };
}
