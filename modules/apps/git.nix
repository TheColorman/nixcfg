{ pkgs, ... }:
{
  # Multiple modules rely on apps-gpg, so it is instead imported in host
  # configuration.nix.
  # See: https://github.com/NixOS/nixpkgs/issues/340361
  # imports = [ outputs.modules.apps-gpg ];

  environment.systemPackages = with pkgs; [ git gh ];
  programs.git = {
    config = {
      user = {
        email = "github@colorman.me";
        name = "TheColorman";
        signingKey = "AB110475B417291D"; # @TODO: Can this key be created dynamically?
      };
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      commit.verbose = true;
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
      merge.conflictstyle = "zdiff3";
      column.ui = "auto";
      branch.sort = "-comitterdate";
      tag.sort = "version:refname";
      init.defaultBranch = "main";
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      help.autocorrect = "prompt";
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      core.excludesfile = "~/.gitignore";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
        fsmonitor = true;
      };
      commit = {
        gpgsign = true;
      };
    };
  };
}
