# Dependencies for the snix script
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    ranger
    vim
    git
    gh
    gnupg
    alejandra
  ];
  environment.variables.EDITOR = "vim";

  # GPG
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
}
