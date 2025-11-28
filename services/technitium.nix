{lib, ...}: {
  services.technitium-dns-server = {
    enable = true;
    openFirewall = true;
  };

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
