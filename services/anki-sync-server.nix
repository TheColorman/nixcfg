{config, ...}: {
  services.anki-sync-server = {
    enable = true;
    # TODO: Get users dynamically somehow? Global list of users that get used
    #       by all services? Probably not a good idea.
    # TODO: PR this service adding the support for the "PASSWORDS_HASHED"
    #       environment variable.
    users."colorman".passwordFile = config.sops.secrets.anki_passwd_plaintext.path;
  };
}
