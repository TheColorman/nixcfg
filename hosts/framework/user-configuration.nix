{pkgs, inputs, config, ...}@meta: let
  mod = name: (import "${inputs.this.outPath}/modules/${name}.nix" meta);
  file = name: "${inputs.this.outPath}/modules/${name}";
in {
  # Define a user account.
  users.users.color = mod "users/color"; 

  # Syncthing config
  system.activationScripts = {
    syncthingSetup.text = mod "nixos/syncthing/setup_script" "color";
    fix_stylix.text = ''
      rm /home/color/.gtkrc-2.0 -f
    '';
  };
  services.syncthing = mod "nixos/syncthing/syncthing" "color";
  services.tailscale = mod "nixos/tailscale";

  programs.git = mod "nixos/git";

  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [{
      from = 1714; # KDE Connect
      to = 1764;
    }];
    allowedUDPPortRanges = [{
      from = 1714; # KDE Connect
      to = 1764;
    }];
  };
}
