{pkgs, inputs, ...}@meta: let
  mod = name: (import "${inputs.this.outPath}/modules/${name}.nix" meta);
  file = name: "${inputs.this.outPath}/modules/${name}";
in {
  # Define a user account.
  users.users.color = mod "users/color"; 

  # Syncthing config
  system.activationScripts = {
    syncthingSetup.text = mod "nixos/syncthing/setup_script";
  };
  services.syncthing = mod "nixos/syncthing/syncthing";
  services.tailscale = mod "nixos/tailscale";

  programs.git = mod "nixos/git";
}
