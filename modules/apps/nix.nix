{ pkgs, ... }:
let
  script = name: text: pkgs.writeShellApplication { inherit name text; };
in
{
  environment.systemPackages = [
    (script "tnix"  "sudo nixos-rebuild test --flake ~/nixcfg --option eval-cache false")
    (script "dbnix" "sudo nixos-rebuild dry-build --flake ~/nixcfg --option eval-cache false")
    (script "danix" "sudo nixos-rebuild dry-activate --flake ~/nixcfg")
    (script "snix"  "sudo nixos-rebuild switch --flake ~/nixcfg")
    (script "bnix"  "sudo nixos-rebuild boot --flake ~/nixcfg")
  ];
}
