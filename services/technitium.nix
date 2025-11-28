{lib, ...}: {
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

  # FIXME: (upstream) technitium does not work with DynamicUser
  systemd.services.technitium-dns-server = {
    serviceConfig = {
      User = "technitium";
      Group = "technitium";
      DynamicUser = lib.mkForce false;
    };
  };

  users = {
    users."technitium" = {
      group = "technitium";
      isSystemUser = true;
    };
    groups."technitium" = {};
  };
}
