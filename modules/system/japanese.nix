{ pkgs, ... }: {
  # @TODO: Call this fcitx5.nix instead of japanese.nix and move to apps/
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [ fcitx5-mozc ];
      waylandFrontend = true;
      plasma6Support = true;
    };
  };
}
