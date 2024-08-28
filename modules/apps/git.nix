{ pkgs, outputs, ... }:
{
  imports = [ outputs.modules.apps-gpg ];

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
        signingKey = "AB110475B417291D"; # @TODO: Can this key be created dynamically?
      };
      commit = {
        gpgsign = true;
      };
    };
  };
}
