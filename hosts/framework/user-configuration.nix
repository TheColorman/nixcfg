{pkgs, ...}: {
  # Define a user account.
  users.users.color = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$GeIykcimY0uMSihQJFxJr.$d98nEQugR8otnw8stez46hw8L2EBnp3lNTJAcen0Q42";
    description = "color";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      google-chrome
      vscode
      vesktop
      obsidian
      fastfetch
      syncthing
      tailscale
      wireguard-tools
      firefox
      unzip
    ];
  };

  # Syncthing config
  system.activationScripts = {
    syncthingSetup.text = ''
      mkdir -p /home/color/brain
      mkdir -p /home/color/CTF
      mkdir -p /home/color/ITU

      setfacl=${pkgs.acl}/bin/setfacl

      $setfacl -Rdm u:syncthing:rwx /home/color/brain
      $setfacl -Rdm u:syncthing:rwx /home/color/CTF
      $setfacl -Rdm u:syncthing:rwx /home/color/ITU
      $setfacl -Rm u:syncthing:rwx /home/color/brain
      $setfacl -Rm u:syncthing:rwx /home/color/CTF
      $setfacl -Rm u:syncthing:rwx /home/color/ITU

      $setfacl -m u:syncthing:--x /home/color
    '';
  };
  services.syncthing = with builtins; rec {
    enable = true;
    openDefaultPorts = true;
    settings.devices = {
      "colordesktop" = {
        addresses = ["dynamic"];
        id = "MCFUD3B-ZCXDBVJ-H243LXH-V3N6CEK-IT6PW6E-2EMYKH2-FURKLOT-546OQAQ";
      };
      "colorcloud" = {
        addresses = [
          "tcp://192.168.50.222:20978"
          "tcp://192.168.50.222:20979"
          "quic://192.168.50.222:20978"
          "quic://192.168.50.222:20979"
        ];
        id = "HRE2PWX-SNH52Z7-4YWWZRK-GX5IJ5V-SNYBZOY-P4NHNWC-TDBV5ZY-MKZLKA7";
      };
    };
    settings.folders = let
      devs = attrNames settings.devices;
    in {
      brain = {
        devices = devs;
        id = "yedar-6vrrr";
        path = "/home/color/brain";
      };
      CTF = {
        devices = devs;
        id = "dh6gy-zxqu6";
        path = "/home/color/CTF";
      };
      ITU = {
        devices = devs;
        id = "yc39s-4wtgc";
        path = "/home/color/ITU";
      };
    };
  };

  # Git config
  programs.git.config = {
    url = {
      "https://github.com/" = {
        insteadOf = [
          "gh:"
          "github:"
        ];
      };
    };
    user = {
      email = "thoren.alex@gmail.com";
      name = "TheColorman";
      signingKey = "3ECF7505E982C8F6";
    };
    commit = {
      gpgsign = true;
    };
  };
  # tailscale config
  services.tailscale = {
    enable = true;
    authKeyFile = "/home/color/.secrets/tailscale_auth";
    extraUpFlags = [
      "--accept-routes"
      "--exit-node=100.74.238.25"
    ];
    useRoutingFeatures = "client";
  };
}
