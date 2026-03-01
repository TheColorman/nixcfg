# Wrapper around deploy-rs that pipes nix output into nix-output-monitor
{
  flake.nixosModules.apps-deploy-rs = {
    config,
    pkgs,
    ...
  }: {
    users.users."${config.my.username}".packages = [
      (pkgs.writeShellApplication {
        name = "deploy";
        runtimeInputs = with pkgs; [deploy-rs nix-output-monitor];
        text = ''
          deploy "$@" -- --log-format internal-json -v |& nom --json
        '';
      })
    ];
  };
}
