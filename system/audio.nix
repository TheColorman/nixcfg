{ pkgs, ... }: {
  flake.nixosModules.system-audio = { pkgs, ... }: {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    systemd.user.services.beosound-a2dp-sink = {
      description = "Force A2DP Sink profile for Beosound Explore";
      after = [ "pipewire.service" ];
      wantedBy = [ "pipewire.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeScript "beosound-a2dp-sink.sh" ''
          #!/run/current-system/sw/bin/bash
          DEV_PATH="/org/bluez/hci0/dev_50_5E_5C_57_32_D0"
          A2DP_SINK="0000110b-0000-1000-8000-00805f9b34fb"

          # Wait for device to be connected
          for i in $(seq 1 20); do
            if ${pkgs.systemd}/bin/busctl get-property org.bluez "''${DEV_PATH}" org.bluez.Device1 Connected 2>/dev/null | grep -q true; then
              # Disconnect first to release WirePlumber's audio-gateway hold
              ${pkgs.systemd}/bin/busctl call org.bluez "''${DEV_PATH}" org.bluez.Device1 Disconnect
              sleep 1

              # Reconnect with A2DP Sink profile
              for j in $(seq 1 5); do
                if ${pkgs.systemd}/bin/busctl call org.bluez "''${DEV_PATH}" org.bluez.Device1 ConnectProfile s "''${A2DP_SINK}" 2>/dev/null; then
                  exit 0
                fi
                sleep 2
              done
              exit 1
            fi
            sleep 1
          done
          exit 1
        ''}";
      };
    };

    security.rtkit.enable = true;
  };
}
