{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  users.users."${username}".extraGroups = ["libvirtd"];

  environment.systemPackages = [pkgs.dnsmasq];

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = [pkgs.virtiofsd];
  };

  programs.virt-manager.enable = true;
}
