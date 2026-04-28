{ self, ... }:
{
  flake.nixosModules.system-desktop-plasma =
    { pkgs, ... }:
    {
      imports = [ self.nixosModules.system-desktop-wayland ];

      services = {
        desktopManager.plasma6.enable = true;
        displayManager.plasma-login-manager.enable = true;
      };

      environment.systemPackages = with pkgs; [ kdePackages.kwallet-pam ];
    };
}
