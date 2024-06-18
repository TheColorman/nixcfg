{pkgs, inputs, ...}@meta: let
  mod = name: (import "${inputs.this.outPath}/modules/${name}.nix" meta);
  file = name: "${inputs.this.outPath}/modules/${name}";
in {
  # Define a user account.
  users.users.color = mod "users/color"; 

  # Syncthing config
  system.activationScripts = {
    syncthingSetup.text = mod "nixos/syncthing/setup_script" "color";
  };
  services.syncthing = mod "nixos/syncthing/syncthing" "color";
  services.tailscale = mod "nixos/tailscale";

  programs.git = mod "nixos/git";
}
