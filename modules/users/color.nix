{pkgs, config, ...}: {
  isNormalUser = true;
  hashedPasswordFile = config.sops.secrets.color_passwd.path;
  description = "color";
  extraGroups = ["networkmanager" "wheel"];
  packages = with pkgs; [
    google-chrome
    vscode
    vesktop
    obsidian
    fastfetch
    syncthing
    tailscale
    wireguard-tools
    firefox
    unzip
    btop
    p7zip
  ];
}
