{outputs, ...}: {
  imports = with outputs.modules; [
    services-fzf
    utils-direnv
    utils-zoxide
  ];
}
