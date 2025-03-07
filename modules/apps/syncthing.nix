{
  pkgs,
  config,
  inputs,
  ...
}: let
  user = config.my.username;
  secrets = (import "${inputs.nix-secrets}/evaluation-secrets.nix").syncthing.devices;
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings.devices = {
      colorcloud = {
        inherit (secrets.colorcloud) id;
        addresses = [
          "tcp://192.168.50.222:20978"
          "tcp://192.168.50.222:20979"
          "quic://192.168.50.222:20978"
          "quic://192.168.50.222:20979"
        ];
      };

      colorpixel = {
        inherit (secrets.colorpixel) id;
        addresses = ["dynamic"];
      };
    };
    settings.folders = {
      brain = {
        devices = ["colorcloud" "colorpixel"];
        id = "yedar-6vrrr";
        path = "/home/${user}/brain";
      };
      CTF = {
        devices = ["colorcloud"];
        id = "dh6gy-zxqu6";
        path = "/home/${user}/CTF";
      };
      ITU = {
        devices = ["colorcloud"];
        id = "yc39s-4wtgc";
        path = "/home/${user}/ITU";
      };
      Documents = {
        devices = ["colorcloud" "colorpixel"];
        id = "wt32c-t7rkv";
        path = "/home/${user}/Documents";
      };
    };
  };
  system.activationScripts.syncthingSetup.text = ''
    mkdir -p /home/${user}/brain
    mkdir -p /home/${user}/CTF
    mkdir -p /home/${user}/ITU
    mkdir -p /home/${user}/Documents

    setfacl=${pkgs.acl}/bin/setfacl

    $setfacl -Rdm u:syncthing:rwx /home/${user}/brain
    $setfacl -Rdm u:syncthing:rwx /home/${user}/CTF
    $setfacl -Rdm u:syncthing:rwx /home/${user}/ITU
    $setfacl -Rdm u:syncthing:rwx /home/${user}/Documents
    $setfacl -Rm u:syncthing:rwx /home/${user}/brain
    $setfacl -Rm u:syncthing:rwx /home/${user}/CTF
    $setfacl -Rm u:syncthing:rwx /home/${user}/ITU
    $setfacl -Rm u:syncthing:rwx /home/${user}/Documents

    $setfacl -Rdm u:${user}:rwx /home/${user}/brain
    $setfacl -Rdm u:${user}:rwx /home/${user}/CTF
    $setfacl -Rdm u:${user}:rwx /home/${user}/ITU
    $setfacl -Rdm u:${user}:rwx /home/${user}/Documents
    $setfacl -Rm u:${user}:rwx /home/${user}/brain
    $setfacl -Rm u:${user}:rwx /home/${user}/CTF
    $setfacl -Rm u:${user}:rwx /home/${user}/ITU
    $setfacl -Rm u:${user}:rwx /home/${user}/Documents

    $setfacl -m u:syncthing:--x /home/${user}
  '';
  environment.systemPackages = with pkgs; [syncthing];
}
