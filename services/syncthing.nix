{
  pkgs,
  config,
  inputs,
  ...
}: let
  inherit (config.my) username;
  inherit
    ((import "${inputs.nix-secrets}/evaluation-secrets.nix").syncthing)
    devices
    ;
in {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    settings.devices = {
      colorcloud = {
        inherit (devices.colorcloud) id;
        addresses = [
          "tcp://192.168.50.222:20978"
          "tcp://192.168.50.222:20979"
          "quic://192.168.50.222:20978"
          "quic://192.168.50.222:20979"
        ];
      };

      colorpixel = {
        inherit (devices.colorpixel) id;
        addresses = ["dynamic"];
      };
    };
    settings.folders = {
      brain = {
        devices = ["colorcloud" "colorpixel"];
        id = "yedar-6vrrr";
        path = "/home/${username}/brain";
      };
      CTF = {
        devices = ["colorcloud"];
        id = "dh6gy-zxqu6";
        path = "/home/${username}/CTF";
      };
      ITU = {
        devices = ["colorcloud"];
        id = "yc39s-4wtgc";
        path = "/home/${username}/ITU";
      };
      Documents = {
        devices = ["colorcloud" "colorpixel"];
        id = "wt32c-t7rkv";
        path = "/home/${username}/Documents";
      };
    };
  };
  system.activationScripts.syncthingSetup.text = ''
    mkdir -p /home/${username}/brain
    mkdir -p /home/${username}/CTF
    mkdir -p /home/${username}/ITU
    mkdir -p /home/${username}/Documents

    setfacl=${pkgs.acl}/bin/setfacl

    $setfacl -Rdm u:syncthing:rwx /home/${username}/brain
    $setfacl -Rdm u:syncthing:rwx /home/${username}/CTF
    $setfacl -Rdm u:syncthing:rwx /home/${username}/ITU
    $setfacl -Rdm u:syncthing:rwx /home/${username}/Documents
    $setfacl -Rm u:syncthing:rwx /home/${username}/brain
    $setfacl -Rm u:syncthing:rwx /home/${username}/CTF
    $setfacl -Rm u:syncthing:rwx /home/${username}/ITU
    $setfacl -Rm u:syncthing:rwx /home/${username}/Documents

    $setfacl -Rdm u:${username}:rwx /home/${username}/brain
    $setfacl -Rdm u:${username}:rwx /home/${username}/CTF
    $setfacl -Rdm u:${username}:rwx /home/${username}/ITU
    $setfacl -Rdm u:${username}:rwx /home/${username}/Documents
    $setfacl -Rm u:${username}:rwx /home/${username}/brain
    $setfacl -Rm u:${username}:rwx /home/${username}/CTF
    $setfacl -Rm u:${username}:rwx /home/${username}/ITU
    $setfacl -Rm u:${username}:rwx /home/${username}/Documents

    $setfacl -m u:syncthing:--x /home/${username}
  '';
  environment.systemPackages = with pkgs; [syncthing];
}
