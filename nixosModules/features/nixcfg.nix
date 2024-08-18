{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.nixcfg;
  writeShellApplication = pkgs.writeShellApplication;
  preBuild = ''
    pushd ~/nixcfg
    git add .
    git commit -m "tnix-temp"
  '';
  postBuild = ''
    git reset HEAD~1
    popd
  '';
in
{
  options.myNixOS.nixcfg.enable = lib.mkEnableOption "enable nix config command helpers";

  config = {
    environment.systemPackages = [
      # These three scripts are for testing unstaged config changes
      (writeShellApplication {
        name = "tnix";
        runtimeInputs = with pkgs; [ git ];
        text = preBuild + ''
          sudo nixos-rebuild test --flake ~/nixcfg --option eval-cache false
        '' + postBuild;
      })
      (writeShellApplication {
        name = "dbnix";
        runtimeInputs = with pkgs; [ git ];
        text = preBuild + ''
          sudo nixos-rebuild dry-build --flake ~/nixcfg --option eval-cache false
        '' + postBuild;
      })
      (writeShellApplication {
        name = "danix";
        runtimeInputs = with pkgs; [ git ];
        text = preBuild + ''
          sudo nixos-rebuild dry-activate --flake ~/nixcfg
        '' + postBuild;
      })
      # These are for actually adding a generation to the nix store, they assume there is already a commit
      # @TODO: Eventually I should create a script that runs git commit in case there are unstaged changes
      (writeShellApplication {
        name = "snix";
        text = "sudo nixos-rebuild switch --flake ~/nixcfg";
      })
      (writeShellApplication {
        name = "bnix";
        text = "sudo nixos-rebuild boot --flake ~/nixcfg";
      })
    ];
  };
}
