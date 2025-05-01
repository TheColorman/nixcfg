{
  pkgs,
  config,
  ...
}: {
  # This module requires importing apps-sops in configuration.nix to work.
  # See https://github.com/NixOS/nix/issues/7270
  # imports = with outputs.modules; [ apps-sops ];

  services.tailscale = {
    enable = true;
    authKeyFile = "${config.sops.secrets.tailscale_auth.path}";
    extraUpFlags = [
      "--accept-routes"
      # "--exit-node=100.74.238.25"
      "--reset"
    ];
    useRoutingFeatures = "client";
  };
  environment.systemPackages = with pkgs; [tailscale];
}
