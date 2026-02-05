{pkgs, ...}: {
  imports = [
    ./hyprland.nix
    ./hyprcursor.nix
  ];

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "hypr";
      text = ''
        if uwsm check may-start; then
          uwsm start default
        fi
      '';
    })
  ];
}
