{
  flake.nixosModules.services-home-assistant =
    { config, pkgs, ... }:
    let
      domain = "home-assistant.color";

      crtCfg = config.my.certificates.certs."${domain}";
    in
    {
      services = {
        home-assistant = {
          enable = true;
          extraComponents = [
            "default_config"
            "met"
            "tesla_wall_connector"
            "usb"
            "bluetooth"
          ];

          customComponents =
            let
              pythonPkg = config.services.home-assistant.package.python3Packages;
            in
            [
              (pythonPkg.callPackage ./_components/ha-electricity-costs-dkk { })
            ];
          customLovelaceModules = [ (pkgs.callPackage ./_lovelace/ha-price-timeline-card { }) ];
          extraPackages =
            p3p: with p3p; [
              electrickiwi-api
              (p3p.callPackage ./_components/ha-electricity-costs-dkk/electricity-cost-dkk.nix { })
            ];
          config = {

            lovelace.dashboards.energy-prices = {
              mode = "yaml";
              title = "Energy Prices";
              filename = "dashboards/energy-prices.yaml";
            };

            template = [
              {
                sensor = [
                  {
                    name = "Price Timeline Data";
                    unique_id = "price_timeline_data";
                    unit_of_measurement = "DKK/kWh";
                    state = ''
                      {{ (state_attr('sensor.electricity_costs_dkk_current_hour_cost', 'today').hours
                          | map(attribute='total') | average) | round(2) }}
                    '';
                    attributes.data = ''
                      {% set ns = namespace(items=[]) %}
                      {% for day in ['today', 'tomorrow'] %}
                        {% set d = state_attr('sensor.electricity_costs_dkk_current_hour_cost', day) %}
                        {% if d %}
                          {% for h in d.hours %}
                            {% set ns.items = ns.items + [
                              {
                                'start_time': (as_timestamp(d.date ~ 'T00:00:00') + h.hour * 3600)
                                              | timestamp_custom('%Y-%m-%dT%H:%M:%S%z'),
                                'price_per_kwh': h.total
                              }
                            ] %}
                          {% endfor %}
                        {% endif %}
                      {% endfor %}
                      {{ ns.items }}
                    '';
                  }
                ];
              }
            ];
          };
        };

        nginx.virtualHosts."${domain}" = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
          };
          extraConfig = ''
            proxy_buffering off;
          '';
          forceSSL = true;

          sslCertificateKey = crtCfg.key.path;
          sslCertificate = crtCfg.crt.path;
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/hass/dashboards 0755 hass hass - -"
        "L+ /var/lib/hass/dashboards/energy-prices.yaml - - - - ${./_dashboards/energy-prices.yaml}"
      ];

      my.certificates.certs."${domain}" = { };
    };
}
