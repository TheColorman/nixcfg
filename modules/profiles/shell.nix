{ outputs, config, pkgs, ... }: {
  imports = with outputs.modules; [
    apps-direnv
    apps-fzf
    apps-zoxide
    apps-zsh
  ];
}
