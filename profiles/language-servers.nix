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
      users.users.${username}.packages =
        with pkgs;
        (
          # Language servers
          [
            # Bash/shell
            bash-language-server
            # Markdown
            marksman
          ]
          ++ [
            # Bash/shell
            shfmt
            # JavaScript/TypeScript/JSON/Markdown etc.
            prettierd
            # Rust
            rust-analyzer
          ]
        );
    };
}
