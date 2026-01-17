# Wrapper around deploy-rs that pipes nix output into nix-output-monitor
{
  config,
  pkgs,
  ...
}: let
  inherit (config.my) username;
in {
  users.users."${username}".packages = [
    (pkgs.writeShellApplication {
      name = "deploy";
      runtimeInputs = with pkgs; [deploy-rs nix-output-monitor];
      text = ''
        deploy "$@" -- --log-format internal-json -v |& nom --json
      '';
    })
  ];
}
