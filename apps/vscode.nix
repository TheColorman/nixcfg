{
  config,
  pkgs,
  ...
}: {
  users.users."${config.my.username}".packages = with pkgs; [
    vscode
    nil
    alejandra
  ];
}
