{
  flake.nixosModules.services-qbittorrent =
    { config, ... }:
    let
      domain = "torrent.color";
      port = "10095";

      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      virtualisation.oci-containers.containers.qbittorrentvpn = {
        volumes = [
          "/var/lib/qbittorrentvpn/data:/data"
          "/var/lib/qbittorrentvpn/config:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/mnt/neodata/default/Vault/Torrents:/mnt/neodata/default/Vault/Torrents"
          "/mnt/neodata/autobrr:/mnt/neodata/autobrr"
        ];
        ports = [
          "127.0.0.1:${port}:${port}"
        ];
        image = "ghcr.io/binhex/arch-qbittorrentvpn:5.2.3-3-01@sha256:229e441811921893e77b483a192006e5dd598c356f94a80dbadbb9cf88c0f69f";
        hostname = "qbittorrentvpn";
        environment = {
          VPN_ENABLED = "yes";
          STRICT_PORT_FORWARD = "yes";
          LAN_NETWORK = "10.0.0.0/24";
          UMASK = "000";
          ENABLE_STARTUP_SCRIPTS = "no";
          WEBUI_PORT = "${port}";
          PUID = "568";
          PGID = "568";
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

      # Need myself some kernel modules for that container to work
      boot.kernelModules = [
        "ip_tables"
        "iptable_filter"
        "iptable_nat"
        "iptable_mangle"
        "iptable_raw"
      ];

      users = {
        users."qbittorrent" = {
          isSystemUser = true;
          uid = 568;
          group = "qbittorrent";
        };
        groups.qbittorrent.gid = 568;
      };

      services.nginx.virtualHosts."${domain}" = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${port}";
          extraConfig = ''
            auth_request /outpost.goauthentik.io/auth/nginx;
            error_page 401 = @goauthentik_proxy_signin;

            auth_request_set $auth_cookie $upstream_http_set_cookie;
            add_header Set-Cookie $auth_cookie;

            auth_request_set $authentik_username     $upstream_http_x_authentik_username;
            auth_request_set $authentik_groups       $upstream_http_x_authentik_groups;
            auth_request_set $authentik_entitlements $upstream_http_x_authentik_entitlements;
            auth_request_set $authentik_email        $upstream_http_x_authentik_email;
            auth_request_set $authentik_name         $upstream_http_x_authentik_name;
            auth_request_set $authentik_uid          $upstream_http_x_authentik_uid;

            proxy_set_header X-authentik-username     $authentik_username;
            proxy_set_header X-authentik-groups       $authentik_groups;
            proxy_set_header X-authentik-entitlements $authentik_entitlements;
            proxy_set_header X-authentik-email        $authentik_email;
            proxy_set_header X-authentik-name         $authentik_name;
            proxy_set_header X-authentik-uid          $authentik_uid;

            auth_request_set $authentik_auth $upstream_http_authorization;
            proxy_set_header Authorization $authentik_auth;
          '';
        };
        locations."/outpost.goauthentik.io".extraConfig = ''
          proxy_pass http://127.0.0.1:8080/outpost.goauthentik.io;
          proxy_set_header Host $ak_http_host;
          proxy_set_header X-Original-URL $scheme://$ak_http_host$request_uri;

          add_header Set-Cookie $auth_cookie;
          auth_request_set $auth_cookie $upstream_http_set_cookie;
          proxy_pass_request_body off;
          proxy_set_header Content-Length "";
        '';
        locations."@goauthentik_proxy_signin".extraConfig = ''
          internal;
          add_header Set-Cookie $auth_cookie;
          return 302 /outpost.goauthentik.io/start?rd=$scheme://$ak_http_host$request_uri;
        '';

        forceSSL = true;

        sslCertificateKey = crtCfg.key.path;
        sslCertificate = crtCfg.crt.path;
      };

      my.certificates.certs."${domain}" = { };

      sops = {
        secrets = {
          "services/qbittorrentvpn/vpnUser" = { };
          "services/qbittorrentvpn/vpnPass" = { };
          "services/qbittorrentvpn/vpnProv" = { };
          "services/qbittorrentvpn/vpnClient" = { };
        };

        templates."qbittorrentvpn.env" = {
          content = ''
            VPN_USER=${config.sops.placeholder."services/qbittorrentvpn/vpnUser"}
            VPN_PASS=${config.sops.placeholder."services/qbittorrentvpn/vpnPass"}
            VPN_PROV=${config.sops.placeholder."services/qbittorrentvpn/vpnProv"}
            VPN_CLIENT=${config.sops.placeholder."services/qbittorrentvpn/vpnClient"}
          '';
          restartUnits = [ "podman-qbittorrentvpn.service" ];
        };
      };
    };
}
