{
  outputs,
  config,
  ...
}: let
  domain = "torrent.color";
  port = "10095";

  crtCfg = config.my.certificates.certs."${domain}";
in {
  imports = [
    outputs.modules.services-sops
  ];

  virtualisation.oci-containers.containers.qbittorrentvpn = {
    volumes = [
      "/var/lib/qbittorrentvpn/data:/data"
      "/var/lib/qbittorrentvpn/config:/config"
      "/etc/localtime:/etc/localtime:ro"
      "/mnt/neodata/default/Vault/Torrents:/mnt/neodata/default/Vault/Torrents"
      "/mnt/neodata/autobrr:/mnt/neodata/autobrr"
    ];
    ports = [
      "127.0.0.1:${port}:8080"
    ];
    image = "binhex/arch-qbittorrentvpn";
    hostname = "qbittorrentvpn";
    environment = {
      VPN_ENABLED = "yes";
      STRICT_PORT_FORWARD = "yes";
      LAN_NETWORK = "10.0.0.0/24";
      UMASK = "000";
    };
    environmentFiles = [
      config.sops.templates."qbittorrentvpn.env".path
    ];

    capabilities = {
      NET_ADMIN = true;
      NET_RAW = true;
      SYS_MODULE = true;
    };
    devices = [
      "/dev/net/tun"
    ];

    privileged = true;
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/".proxyPass = "http://127.0.0.1:${port}";
    forceSSL = true;

    sslCertificateKey = crtCfg.key.path;
    sslCertificate = crtCfg.crt.path;
  };

  my.certificates.certs."${domain}" = {};

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
