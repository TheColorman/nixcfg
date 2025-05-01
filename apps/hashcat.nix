{
  pkgs,
  config,
  ...
}: let
  inherit (config.my) username;
in {
  users.users."${username}".packages = with pkgs; [hashcat];

  # hashcat needs some hardware acceleration type shit to work i guess
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocminfo
      rocmPackages.rocm-runtime
    ];
  };
}
