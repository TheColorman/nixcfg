# zsh and friends
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    zsh
    zoxide
    highlight
  ];

  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  users.defaultUserShell = pkgs.zsh;
  programs.zsh.ohMyZsh = {
    enable = true;
    plugins = [
      "git"
      "sudo"
      "aliases"
      "common-aliases"
      "gh"
      "history"
    ];
    theme = "eastwood";
  };
}
