# configuration.nix
{
  config,
  pkgs,
  outputs,
  inputs,
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

  wsl.enable = true;
  wsl.defaultUser = username;
  wsl.docker-desktop.enable = true;

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
