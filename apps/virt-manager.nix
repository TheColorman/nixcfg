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
  networking.firewall.trustedInterfaces = ["virbr0"];

  programs.virt-manager.enable = true;
}
