{
  outputs,
  config,
  ...
}: {
  imports = [
    outputs.modules.services-sops
  ];

  virtualisation.oci-containers.containers.qbittorrentvpn = {
    volumes = [
      "/var/lib/qbittorrentvpn/data:/data"
      "/var/lib/qibittorrentvpn/config:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/mnt/neodata/default/Vault/Torrents:/torrents"
    ];
    ports = [
      "127.0.0.1:10095:8080"
    ];
    image = "binhex/arch-qbittorrentvpn";
    hostname = "qbittorrentvpn";
    capabilities.NET_ADMIN = true;
    environment = {
      VPN_ENABLED = "yes";
      STRICT_PORT_FORWARD = "yes";
      LAN_NETWORK = "192.158.50.0/24";
      UMASK = "000";
    };
    environmentFiles = [
      config.sops.templates."qbittorrentvpn.env".path
    ];
  };

  sops = {
    secrets = {
      "services/qbittorrentvpn/vpnUser" = {};
      "services/qbittorrentvpn/vpnPass" = {};
      "services/qbittorrentvpn/vpnProv" = {};
      "services/qbittorrentvpn/vpnClient" = {};
    };

    templates."qbittorrentvpn.env" = {
      content = ''
        VPN_USER=${config.sops.placeholder."services/qbittorrentvpn/vpnUser"}
        VPN_PASS=${config.sops.placeholder."services/qbittorrentvpn/vpnPass"}
        VPN_PROV=${config.sops.placeholder."services/qbittorrentvpn/vpnProv"}
        VPN_CLIENT=${config.sops.placeholder."services/qbittorrentvpn/vpnClient"}
      '';
      restartUnits = ["podman-qbittorrentvpn.service"];
    };
  };
}
