{...}: {
  enable = true;
  authKeyFile = "/home/color/.secrets/tailscale_auth";
  extraUpFlags = [
    "--accept-routes"
    # "--exit-node=100.74.238.25" # goofy ahh slow internet at server network makes this impossible
    "--reset"
  ];
  useRoutingFeatures = "client";
}

