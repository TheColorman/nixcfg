{pkgs, ...}: {
  environment.systemPackages = [pkgs.dnsmasq];

  virtualisation.libvirtd = {
    enable = true;
    qemu.vhostUserPackages = [pkgs.virtiofsd];
  };

  programs.virt-manager.enable = true;
}
