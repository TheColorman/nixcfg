{ ... }: {
  imports = [ ] ++ [
    ./features/kdeconnect.nix
    ./features/kitty.nix
    ./features/oh-my-posh.nix
    ./features/stylix.nix
    ./features/tmux.nix
    ./features/vesktop.nix
    ./features/vim.nix
    ./features/zsh.nix
  ] ++ [
    ./bundles/gaming.nix
  ];

  config = {
    programs.home-manager.enable = true;
  };
}
