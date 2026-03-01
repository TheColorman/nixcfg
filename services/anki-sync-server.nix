{
  flake.nixosModules.services-anki-sync-server = {config, ...}: {
    services.anki-sync-server = {
      enable = true;
      # TODO: Get users dynamically somehow? Global list of users that get used
      #       by all services? Probably not a good idea.
      # TODO: PR this service adding the support for the "PASSWORDS_HASHED"
      #       environment variable.
      users = [
        {
          username = "colorman";
          passwordFile = config.sops.secrets.anki_passwd_plaintext.path;
        }
      ];
      openFirewall = true;
      address = "0.0.0.0";
    };
  };
}
