# configuration.nix
{
  pkgs,
  inputs,
  system,
  config,
  ...
}: let
  pkg = name: inputs.${name}.packages.${system}.default;
in {
  imports = [
    ./hardware-configuration.nix
    ./user-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "color" = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    python312Packages.pygments
    input-remapper
    aria2
    (pkg "fw-ectool")
    fprintd
    zinit

    mangohud # gaming
  ];

  environment.pathsToLink = ["/share/zsh"];
  services.input-remapper.enable = true;
  services.fwupd.enable = true;
  hardware.bluetooth.enable = true;

  # Stylix config
  stylix = {
    enable = true;
    image = ./assets/2024-H1.png;
    fonts = with pkgs; {
      serif = {
        package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        name = "CascadiaCode Serif";
      };
      sansSerif = {
        package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        name = "CascadiaCode Sans";
      };
      monospace = {
        package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        name = "CascadiaCode Sans Mono";
      };
    };
    polarity = "dark";
  };

  # Gaming stuff
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;
  
}
