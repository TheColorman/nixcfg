{ lib, config, pkgs, ... }:
let
  cfg = config.myNixOS.git;
in
{
  imports = [ ];

  options.myNixOS.git.enable = lib.mkEnableOption "Enable Git";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ git gh ];
    programs.git = {
      config = {
        url = {
          "https://github.com/" = {
            insteadOf = [
              "gh:"
              "github:"
            ];
          };
        };
        user = {
          email = "github@colorman.me";
          name = "TheColorman";
          signingKey = "AB110475B417291D";
        };
        commit = {
          gpgsign = true;
        };
      };
    };
  };
}
