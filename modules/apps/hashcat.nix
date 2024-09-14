{ pkgs, config, ... }: let
  username = config.my.username;
in {
  users.users."${username}".packages = with pkgs; [ hashcat ];

  # hashcat needs some hardware acceleration type shit to work i guess
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
       rocmPackages_5.clr.icd
       rocmPackages_5.clr
       rocmPackages_5.rocminfo
       rocmPackages_5.rocm-runtime
    ];
  };
}
