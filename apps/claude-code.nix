{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  home-manager.users."${username}".home = {
    packages = [pkgs.claude-code];
    sessionVariables = {
      DISABLE_TELEMETRY = 1;
      DISABLE_ERROR_REPORTING = 1;
      DISABLE_NON_ESSENTIAL_MODEL_CALLS = 1;
    };
  };
}
