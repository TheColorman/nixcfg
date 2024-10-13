{ pkgs, ... }: {
  # Multiple modules rely on apps-gpg, so it is instead imported in host
  # configuration.nix.
  # See: https://github.com/NixOS/nixpkgs/issues/340361
  # imports = [ outputs.modules.apps-gpg ];

  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
}
