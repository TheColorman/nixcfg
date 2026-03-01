{self, ...}: {
  flake.nixosModules.system-desktop-hyprland = {pkgs, ...}: {
    imports = with self.nixosModules; [
      system-desktop-hyprland-hyprland
      system-desktop-hyprland-hyprcursor
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
  };
}
