{
  services.tailscale = {
    enable = true;
    extraUpFlags = [
      "--accept-routes"
      # "--exit-node=100.74.238.25"
      "--reset"
    ];
    useRoutingFeatures = "client";
  };
}
