{...}: owner: with builtins; rec {
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
      path = "/home/${owner}/brain";
    };
    CTF = {
      devices = devs;
      id = "dh6gy-zxqu6";
      path = "/home/${owner}/CTF";
    };
    ITU = {
      devices = devs;
      id = "yc39s-4wtgc";
      path = "/home/${owner}/ITU";
    };
  };
}
