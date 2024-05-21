# zsh and friends
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zsh
    zoxide
    highlight
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
}
