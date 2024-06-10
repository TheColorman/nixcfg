{pkgs, ...}: {
  isNormalUser = true;
  hashedPassword = "$y$j9T$GeIykcimY0uMSihQJFxJr.$d98nEQugR8otnw8stez46hw8L2EBnp3lNTJAcen0Q42";
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
  ];
}
