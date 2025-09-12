{
  config,
  inputs,
  systemPlatform,
  lib,
  ...
}: let
  inherit (config.my) username;
  inherit (builtins) listToAttrs;
  inherit (lib.modules) mkMerge mkIf;

  stylixEnabled = config.stylix.enable or false;
in {
  nixpkgs.overlays = [
    (_: _: {
      zen-browser = inputs.zen-browser.packages.${systemPlatform}.twilight;
    })
  ];

  home-manager.users."${username}" = mkMerge [
    {
      imports = [inputs.zen-browser.homeModules.twilight];

      xdg.mimeApps = let
        associations = listToAttrs (map (name: {
            inherit name;
            value = "zen-twilight.desktop";
          }) [
            "application/x-extension-shtml"
            "application/x-extension-xhtml"
            "application/x-extension-html"
            "application/x-extension-xht"
            "application/x-extension-htm"
            "x-scheme-handler/unknown"
            "x-scheme-handler/mailto"
            "x-scheme-handler/chrome"
            "x-scheme-handler/about"
            "x-scheme-handler/https"
            "x-scheme-handler/http"
            "application/xhtml+xml"
            "application/json"
            "text/plain"
            "text/html"
          ]);
      in {
        enable = true;
        associations.added = associations;
        defaultApplications = associations;
      };

      programs.zen-browser = {
        enable = true;
        policies = {
          # See https://mozilla.github.io/policy-templates/
          AppAutoUpdate = false;
          AutofillAddressEnabled = false;
          AutofillCreditCardEnabled = false;
          Cookies = {
            # NOTE: There's an "AllowedSession" field which can be used to block
            # all cookies, except for websites whitelisted for that session. Are
            # there any extensions that actually make use of this? My ideal
            # scenario would be to block all cookies, except first-party cookies
            # on origins I whitelist, then remember that whitelist across
            # sessions. If you're reading this and know of a solution, please let
            # me know!
            Behavior = "reject-foreign";
            BehaviorPrivateBrowsing = "reject-foreign";
          };
          DisableSetDesktopBackground = true;
          DisableTelemetry = true;
          EnableTrackingProtection = {
            Value = true;
            Cryptomining = true;
            Fingerprinting = true;
            EmailTracking = true;
          };
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
          Preferences = {
            "browser.tabs.warnOnClose" = {
              Value = false;
              Status = "locked";
            };
          };
          PromptForDownloadLocation = false;
          RequestedLocales = "en-US";
          SearchEngines.Add = let
            mkSearch = alias: name: host: path: {
              Name = name;
              URLTemplate = "https://${host}${path}";
              Method = "GET";
              IconURL = "https://${host}/favicon.ico";
              Alias = alias;
            };
          in [
            (mkSearch "pp" "Perplexity" "www.perplexity.ai" "/search?q={searchTerms}")
            (mkSearch "np" "Nix packages" "search.nixos.org" "/packages?channel=unstable&query={searchTerms}")
            (mkSearch "no" "Nix options" "search.nixos.org" "/options?channel=unstable&query={searchTerms}")
          ];
          SkipTermsOfUse = true;
        };
      };
    }
    (mkIf stylixEnabled {
      stylix.targets.zen-browser.profileNames = ["fxh4dbd1.Default Profile"];
    })
  ];
}
