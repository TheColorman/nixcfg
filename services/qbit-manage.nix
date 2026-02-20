{config, ...}: let
  domain = "manage.torrent.color";
  port = "42918";

  crtCfg = config.my.certificates.certs."${domain}";
in {
  virtualisation = {
    podman.defaultNetwork.settings.dns_enabled = true;
    oci-containers.containers.qbit_manage = {
      image = "ghcr.io/stuffanthings/qbit_manage:v4.6.5";
      volumes = [
        "/var/lib/qbit_manage/config:/config"
        "/mnt/neodata/default/Vault/Torrents:/mnt/neodata/default/Vault/Torrents"
        "/mnt/neodata/autobrr:/mnt/neodata/autobrr"
      ];
      ports = ["127.0.0.1:${port}:${port}"];
      environment = {
        QBT_WEB_SERVER = "true";
        QBT_PORT = port;

        QBT_CONFIG_DIR = "/config";
        QBT_REM_ORPHANED = "true";
        QBT_TAG_NOHARDLINKS = "true";
      };
      networks = ["podman"];
    };
  };

  services.nginx.virtualHosts."${domain}" = {
    locations."/".proxyPass = "http://127.0.0.1:${port}";
    forceSSL = true;

    sslCertificateKey = crtCfg.key.path;
    sslCertificate = crtCfg.crt.path;
  };

  my.certificates.certs."${domain}" = {};
}
