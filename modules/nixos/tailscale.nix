{ config, ... }: {
  enable = true;
  authKeyFile = "${config.sops.secrets.tailscale_auth.path}";
  extraUpFlags = [
    "--accept-routes"
    # "--exit-node=100.74.238.25" # goofy ahh slow internet at server network makes this impossible
    "--reset"
  ];
  useRoutingFeatures = "client";
}

