{ inputs, config, pkgs, ... }:
let
  inherit (builtins) toString;
in
{
  imports = [ inputs.sops-nix.nixosModules.sops ];

  environment.systemPackages = [ pkgs.age ];

  sops = {
    defaultSopsFile = "${toString inputs.nix-secrets}/secrets.yaml";
    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    secrets = {
      color_passwd = { neededForUsers = true; };
      lastfm_auth = { owner = config.users.users.color.name; };
      tailscale_auth = { };
    };
  };
}
