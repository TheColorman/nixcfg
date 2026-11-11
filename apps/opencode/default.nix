{
  flake.nixosModules.apps-opencode =
    { config, pkgs, ... }:
    {
      home-manager.users."${config.my.username}".programs.opencode = {
        enable = true;
        context = ./context.md;
        settings.mcp.servers = {
          "GitLab" = {
            type = "remote";
            url = "{file:OC_MCP_GITLAB_URL}";
          };

          "Slack" = {
            type = "remote";
            url = "https://mcp.slack.com/mcp";
            oauth = {
              client_id = "{file:~/.slack/opencode-mcp/client-id}";
              client_secret = "{file:~/.slack/opencode-mcp/client-secret}";
              scope = "search:read.public channels:history channels:read search:read.private groups:history groups:read";
              callback_port = 19876;
              redirect_uri = "http://localhost:19876/callback";
            };
          };
        };
      };

      sops.secrets = {
        "oc/mcp/gitlab/url" = { };
        "oc/mcp/slack/clientId" = { };
        "oc/mcp/slack/clientSecret" = { };
      };
    };
}
