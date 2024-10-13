{ lib, config, inputs, pkgs, ... }:
let
  cfg = config.my.stylix;
in
{
  imports = [ inputs.stylix.nixosModules.stylix ];

  options.my.stylix.heliotheme = {
    enable = lib.mkOption {
      default = false;
      description = ''
        If enabled, will automatically switch Stylix polarity on sunset and
        sunrise.
      '';
    };
    latitude = lib.mkOption {
      default = "-33.8582504248224";
      description = "Latitude for day/night cycle calculation. Defaults to Australia/Sydney";
      type = lib.types.str;
    };
    longitude = lib.mkOption {
      default = "151.21476416121257";
      description = "Longitude for day/night cycle calculation. Defaults to Australia/Sydney";
      type = lib.types.str;
    };
  };

  config = {
    stylix = {
      enable = true;
      image = ./assets/2024-H2.png;
      fonts = with pkgs; {
        # @TODO: these probably shouldn't all be the same with different names right?...
        serif = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font Propo";
        };
        sansSerif = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font Propo";
        };
        monospace = {
          package = (nerdfonts.override { fonts = [ "CascadiaCode" ]; });
          name = "CaskaydiaCove Nerd Font";
        };
      };
      opacity = {
        applications = 0.5;
        desktop = 0.5;
        popups = 0.7;
        terminal = 0.4;
      };
      polarity = "dark";
    };

    # @TODO: this can probably be removed now that I have home-manager "backupFileExpension" 
    system.activationScripts.fix_stylix.text = ''
      rm /home/color/.gtkrc-2.0 -f
    '';

    home-manager.users."${config.my.username}" = {
      stylix.autoEnable = true;
      stylix.enable = true;
    };

    # Heliosynchronous polarity
    specialisation = lib.mkIf cfg.heliotheme.enable {
      light.configuration.stylix.polarity = lib.mkForce "light";
    };

    systemd.services.heliotheme = lib.mkIf cfg.heliotheme.enable {
      enable = true;
      description = "Theme polarity switcher";

      wantedBy = [ "graphical.target" ];
      path = with pkgs; [ gitMinimal ];
      script = let
        jq = "${pkgs.jq}/bin/jq";
        date = "${pkgs.coreutils}/bin/date";
        nixos-rebuild = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
        location = "--latitude ${cfg.heliotheme.latitude} --longitude ${cfg.heliotheme.longitude}";
        heliocron = "${pkgs.heliocron}/bin/heliocron ${location}";
        switch_dark = "${nixos-rebuild} test --flake /home/${config.my.username}/nixcfg";
        switch_light = "${switch_dark} --specialisation light";
      in ''
        # Let's wait a little bit for the system to finish booting/building
        sleep 60
        # Check what polarisation we should be using right now
        sunrise=$(${heliocron} report --json | ${jq} -r '.sunrise')
        sunset=$(${heliocron} report --json | ${jq} -r '.sunset')
        echo "Calculated todays Sunrise/Sunset: $sunrise/$sunset"

        sunrise_epoch=$(${date} -d "$sunrise" +%s)
        sunset_epoch=$(${date} -d "$sunset" +%s)
        now_epoch=$(${date} +%s)
        target_polarity="dark" && [[ "$sunrise_epoch" -lt "$now_epoch" ]] && [[ "$sunset_epoch" -gt "$now_epoch" ]] && target_polarity="light"

        # Update to target polarity
        # - Note: when shutting down in light polarity, and then booting into
        #   dark polarity, lots of KDE elements are still light for some reason,
        #   so instead of checking whether we're in the correct polarity, I just
        #   switch regardless.
        echo "Changing polarity..."
        if [ "$target_polarity" == "light" ]; then
          echo "Attempting to switch to Light polarity"
          ${switch_light}
        else
          echo "Attempting to switch to Dark polarity"
          ${switch_dark}
        fi

        # Wait for astronomical event
        while :
        do
          echo "Waiting for sunrise..."
          ${heliocron} wait --event sunrise && echo "Attempting to switch to Light polarity" && ${switch_light}
          echo "Waiting for sunset..."
          ${heliocron} wait --event sunset && echo "Attempting to switch to Dark polarity" && ${switch_dark}
          echo "Waiting for sunrise tomorrow..."
          ${heliocron} -d $(${date} -d '+1 day' +%Y-%m-%d) wait --event sunrise && echo "Attempting to switch to light polarity" && ${switch_light} 
        done
      '';
    };
  };
}
