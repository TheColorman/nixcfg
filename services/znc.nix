{
  inputs,
  pkgs,
  ...
}: let
  inherit ((import "${inputs.nix-secrets}/evaluation-secrets.nix").services.znc) networks;
in {
  services.znc = {
    enable = true;

    useLegacyConfig = false;
    mutable = false;

    modulePackages = with pkgs.zncModules; [
      clientbuffer
    ];

    config = {
      MaxBufferSize = 1000;

      Listener.listener0 = {
        AllowIRC = true;
        AllowWeb = true;
        IPv4 = true;
        IPv6 = false;
        Port = 6501;
        SSL = false;
        URIPrefix = "/";
      };

      User.admin = {
        Admin = true;
        QuitMsg = "👋";

        Network = networks;

        Pass.password = {
          Method = "SHA256";
          Hash = "5525442d7df76848c06399dddfa4cb094e984fd6edfd996b760f869f2d051551";
          Salt = "AZ)dhl6rlq,N1:wm)SB6";
        };
      };
    };

    openFirewall = true;
  };
}
