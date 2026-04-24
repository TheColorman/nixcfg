{
  flake.nixosModules.profiles-language-servers =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.my) username;
    in
    {
      users.users.${username}.packages = with pkgs; [
        # Bash/shell
        bash-language-server
        shfmt
      ];
    };
}
