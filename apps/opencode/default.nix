{
  flake.nixosModules.apps-opencode =
    { config, pkgs, ... }:
    let
      inherit (config.my) username;
    in
    {
      home-manager.users."${username}".programs.opencode = {
        enable = true;
        context = ./context.md;
        settings.mcp.servers = {
          "GitLab" = {
            type = "remote";
            url = "{file:${config.sops.secrets."oc/mcp/gitlab/url".path}}";
          };

          "Slack" = {
            type = "remote";
            url = "https://mcp.slack.com/mcp";
            oauth = {
              client_id = "{file:${config.sops.secrets."oc/mcp/slack/clientId".path}}";
              client_secret = "{file:${config.sops.secrets."oc/mcp/slack/clientSecret".path}}";
              scope = "search:read.public channels:history channels:read search:read.private groups:history groups:read";
              callback_port = 19876;
              redirect_uri = "http://localhost:19876/callback";
            };
          };

          "Kagi" = {
            type = "remote";
            url = "https://mcp.kagi.com/mcp";
            headers = {
              "Authorization" = "{file:${config.sops.templates."oc-mcp-kagi-auth".path}}";
            };
          };
        };
        commands."rebase" = ./commands/rebase.md;
      };

      sops = {
        secrets = {
          "oc/mcp/gitlab/url".owner = username;
          "oc/mcp/slack/clientId".owner = username;
          "oc/mcp/slack/clientSecret".owner = username;
          "oc/mcp/kagi/bearerToken".owner = username;
        };
        templates."oc-mcp-kagi-auth" = {
          owner = username;
          content = ''
            Bearer ${config.sops.placeholder."oc/mcp/kagi/bearerToken"}
          '';
        };
      };
    };
}
