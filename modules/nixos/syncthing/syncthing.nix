{...}: owner: with builtins; rec {
  enable = true;
  openDefaultPorts = true;
  settings.devices = {
    "colordesktop" = {
      addresses = [ "dynamic" ];
      id = "MCFUD3B-ZCXDBVJ-H243LXH-V3N6CEK-IT6PW6E-2EMYKH2-FURKLOT-546OQAQ";
    };
    "colorcloud" = {
      addresses = [ "tcp://192.168.50.222:20978"  "tcp://192.168.50.222:20979"
                    "quic://192.168.50.222:20978" "quic://192.168.50.222:20979" ];
      id = "HRE2PWX-SNH52Z7-4YWWZRK-GX5IJ5V-SNYBZOY-P4NHNWC-TDBV5ZY-MKZLKA7";
    };
    "colorphone" = {
      addresses = [ "dynamic" ];
      id = "FUHS52Q-W6FORIW-OP4737B-RI5FP4Z-KCHL3U6-C2CF7HG-OKMQAU6-AJJYOA3";
    };
  };
  settings.folders = {
    brain = {
      devices = [ "colordesktop" "colorcloud" "colorphone" ];
      id = "yedar-6vrrr";
      path = "/home/${owner}/brain";
    };
    CTF = {
      devices = [ "colordesktop" "colorcloud" ];
      id = "dh6gy-zxqu6";
      path = "/home/${owner}/CTF";
    };
    ITU = {
      devices = [ "colordesktop" "colorcloud" ];
      id = "yc39s-4wtgc";
      path = "/home/${owner}/ITU";
    };
    Documents = {
      devices = [ "colordesktop" "colorcloud" "colorphone" ];
      id = "wt32c-t7rkv";
      path = "/home/${owner}/Documents";
    };
  };
}
