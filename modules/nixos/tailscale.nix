{...}: {
  enable = true;
  authKeyFile = "/home/color/.secrets/tailscale_auth";
  extraUpFlags = [
    "--accept-routes"
    "--exit-node=100.74.238.25"
    "--reset"
  ];
  useRoutingFeatures = "client";
}

