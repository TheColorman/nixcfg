# configuration.nix
{
  pkgs,
  inputs,
  system,
  config,
  ...
}@meta: let
  pkg = name: inputs.${name}.packages.${system}.default;
  mod = name: (import "${inputs.this.outPath}/modules/${name}.nix");
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

  # container bullshit
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "wlp1s0";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  environment.systemPackages = with pkgs; [
    python312Packages.pygments
    input-remapper
    aria2
    (pkg "fw-ectool")
    fprintd
    zinit

    mangohud # gaming

    killall
    bottles
    mpv
    safeeyes
    dig
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
        name = "CaskaydiaCove Nerd Font Propo";
      };
      sansSerif = {
        package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        name = "CaskaydiaCove Nerd Font Propo";
      };
      monospace = {
        package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
        name = "CaskaydiaCove Nerd Font";
      };
    };
    polarity = "dark";
  };

  # Gaming stuff
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;
 
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-mozc
      ];
      waylandFrontend = true;
      plasma6Support = true;
    };
  };

  containers.hacking = mod "nixos/containers/hack" meta;
}
