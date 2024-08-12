{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
  ];

  users.mutableUsers = false;
  system.nixos.label = "add_sops_nix";
}
