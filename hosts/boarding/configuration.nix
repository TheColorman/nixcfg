# configuration.nix
{
  config,
  pkgs,
  outputs,
  inputs,
  lib,
  ...
}: let
  username = "boarder";
in {
  imports = with outputs.modules; [
    inputs.nixos-wsl.nixosModules.default

    profiles-common
    profiles-shell
    system-fonts
    apps-btop
    apps-git
    apps-gpg
    apps-neovim
    apps-nix
    apps-oh-my-posh
    apps-vscode-server
  ];

  my.username = username;
  networking.hostName = "boarding";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    wslConf.interop.appendWindowsPath = false;
    wslConf.network.generateHosts = false;
    defaultUser = username;
    startMenuLaunchers = true;

    docker-desktop.enable = false; # done manually

    extraBin = with pkgs; [
      # Binaries for Docker Desktop wsl-distro-proxy
      {src = "${coreutils}/bin/mkdir";}
      {src = "${coreutils}/bin/cat";}
      {src = "${coreutils}/bin/whoami";}
      {src = "${coreutils}/bin/ls";}
      {src = "${busybox}/bin/addgroup";}
      {src = "${su}/bin/groupadd";}
      {src = "${su}/bin/usermod";}
    ];
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
  };

  ## patch the script
  systemd.services.docker-desktop-proxy.script = lib.mkForce ''${config.wsl.wslConf.automount.root}/wsl/docker-desktop/docker-desktop-user-distro proxy --docker-desktop-root ${config.wsl.wslConf.automount.root}/wsl/docker-desktop "C:\Program Files\Docker\Docker\resources"'';

  home-manager.users.${username}.programs.zsh.shellAliases = {
    docker = "/run/current-system/sw/bin/docker";
  };

  users.users."${username}" = {
    isNormalUser = true;
    hashedPassword = "$y$j9T$sD7TNPmhg9Zxso6eUqMV9/$Wa/zdt3yOxWfrY3aLlRjbajyqy/6r6oYInvjplj02O9";
    extraGroups = ["wheel"];
    packages = with pkgs; [
      fastfetch
      ranger
      aria2
      killall
      dig
      ripgrep
      alejandra
      nixd
    ];
  };

  security.pki.certificates = [
    ''
      gitlab
      -----BEGIN CERTIFICATE-----
      MIID8jCCAtqgAwIBAgIQf2rfdCbPbYNBD8XjcvfnYzANBgkqhkiG9w0BAQsFADBs
      MRMwEQYKCZImiZPyLGQBGRYDY29tMR8wHQYKCZImiZPyLGQBGRYPdXh2dGVjaG5v
      bG9naWVzMRQwEgYKCZImiZPyLGQBGRYEY29ycDEeMBwGA1UEAxMVY29ycC1TUlYt
      QURDUy1CUk83LUNBMB4XDTIyMDYyMDEzNDIzNFoXDTI3MDgwMTEyMTIzNlowbDET
      MBEGCgmSJomT8ixkARkWA2NvbTEfMB0GCgmSJomT8ixkARkWD3V4dnRlY2hub2xv
      Z2llczEUMBIGCgmSJomT8ixkARkWBGNvcnAxHjAcBgNVBAMTFWNvcnAtU1JWLUFE
      Q1MtQlJPNy1DQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOvTrmZn
      c86wbTNLkltuaC+LUk669O7DFc+71YSH8z2VKJdNAkd41NRpSJZumvVnArlduTDi
      F9F8v8i1d5fyVEchvZs2RVNHYUZUrCOzCtq52uuzV+sS/cGvJbpXJ4DVrm44hYwS
      j7pVxIUgejmzWDOxehzRyXcq0kf4LfqUXtvm9JBdpCZgSTpjAU9gvzG3ICEj2wiA
      4ODJi7y6oDTmdChhU56oD8/FSoXUc1ZnYnDrFi2fHREDb5ARqVtRFc+jkgTNI0wb
      oQFLa68Wt/bSfylASdevZxRO9r3EU6zwoT+Vcc8Dy2HO42vjXHwz9bRVAGXu9nBT
      gfh4VsNOZqY4tYkCAwEAAaOBjzCBjDATBgkrBgEEAYI3FAIEBh4EAEMAQTAOBgNV
      HQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQUsxP1Pj1MoBNN
      4iWFCCRfPWjTY5YwEAYJKwYBBAGCNxUBBAMCAQEwIwYJKwYBBAGCNxUCBBYEFMin
      /RHlpU1Ze1XJGNw1OFuqYYD7MA0GCSqGSIb3DQEBCwUAA4IBAQAzSDTtwzlgz+ht
      cZsusPV18f9JkFIeK/qjJFbn5ELxf03qc25GDYf9Jya5trOsBo1d1Z2tigs0OpfJ
      DzMkRY7Pl+CtRzIawoCZaQ4ymQIH9YZ1nFCKH8eASMSaNMNCxSY55H2tku57boYD
      3vbN1RBKlgUK6yh0mzUhDFHyBL1R6R1HmriQx6DHgvQp5i6tNHNqhJEaC7iOtEcH
      23JMtReA3xVMvpA4TglzpN7cdHhMMpJDENLQtEeb1sRPevur89VPR90NkLcGt9lq
      vifry/puzps43gTfiwZGubhHMh+ODlHbBdMvja+o0FWFjD+aN4VvJuxSUcebdIh2
      5W2mXrND
      -----END CERTIFICATE-----
    ''
    ''
      newunifi
      -----BEGIN CERTIFICATE-----
      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
      vuLNOyzAYQ2MGny1Uj/sBwd0Vw==
      -----END CERTIFICATE-----
    ''
    ''
      oldunifi
      -----BEGIN CERTIFICATE-----
      MIIDkDCCAzagAwIBAgIQSlhoa8F4+RwSjvAHRy3vlzAKBggqhkjOPQQDAjA7MQsw
      CQYDVQQGEwJVUzEeMBwGA1UEChMVR29vZ2xlIFRydXN0IFNlcnZpY2VzMQwwCgYD
      VQQDEwNXRTIwHhcNMjQxMDIxMDg0MDU5WhcNMjUwMTEzMDg0MDU4WjATMREwDwYD
      VQQDDAgqLmdjci5pbzBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABAQkJjQubDUh
      PZ6nDOMJAnLLCoXtYcRrkVu39eq6TD8wXTq2sz2VnpgzWKU99Qnkq7gkR9Du9Ef9
      9vG7e7LVbMyjggJCMIICPjAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAwwCgYIKwYB
      BQUHAwEwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQURA/qGLTYihiWpCggWId/LPz1
      bUwwHwYDVR0jBBgwFoAUdb7Ed66J9kQ3fc+xaB8dGuvcNFkwWAYIKwYBBQUHAQEE
      TDBKMCEGCCsGAQUFBzABhhVodHRwOi8vby5wa2kuZ29vZy93ZTIwJQYIKwYBBQUH
      MAKGGWh0dHA6Ly9pLnBraS5nb29nL3dlMi5jcnQwGwYDVR0RBBQwEoIIKi5nY3Iu
      aW+CBmdjci5pbzATBgNVHSAEDDAKMAgGBmeBDAECATA2BgNVHR8ELzAtMCugKaAn
      hiVodHRwOi8vYy5wa2kuZ29vZy93ZTIveHV6dDNQVTlGX3cuY3JsMIIBAwYKKwYB
      BAHWeQIEAgSB9ASB8QDvAHUAzPsPaoVxCWX+lZtTzumyfCLphVwNl422qX5UwP5M
      DbAAAAGSrnOKHwAABAMARjBEAiB+VvOb77nttwJXdiKjaqBILODO19dtRbuJgPlp
      TgkPSgIgdVS/E/lbJNktCFyqWN5m/2cr0tNBKOFy9LSjLQZGZacAdgBOdaMnXJoQ
      wzhbbNTfP1LrHfDgjhuNacCx+mSxYpo53wAAAZKuc4nvAAAEAwBHMEUCIQDzlw+E
      y84bpwXXTq8yUldloy5xoPilPAnpmViypmDj8QIgGGBDxllbOU2mKFW1l7NqSFda
      /xdouSG0z6qvLkFvdEowCgYIKoZIzj0EAwIDSAAwRQIgYoMETpg9HQ2CGOQ72Nv+
      nDJBTpaFPPa781brxEzBzjQCIQDGf7RqpfsKK6ufG1qBMZtc0kWVGQDEY9/FLoWv
      goyc3g==
      -----END CERTIFICATE-----
    ''
  ];

  time.timeZone = "Australia/Sydney";
  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "24.05";
}
