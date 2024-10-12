{ lib, config, pkgs, ... }:
let
  inherit (lib) concatStringsSep;
  inherit (lib.meta) getExe;

  username = config.my.username;
  fzf = config.home-manager.users.${username}.programs.fzf;
  zoxide = config.home-manager.users.${username}.programs.zoxide;
  direnv = config.home-manager.users.${username}.programs.direnv;

  # https://github.com/nix-community/home-manager/blob/086f619dd991a4d355c07837448244029fc2d9ab/modules/programs/fzf.nix#L211
  fzfIntegration = ''
    if [[ $options[zle] = on ]]; then
      eval "$(${getExe fzf.package} --zsh)"
    fi
  '';
  # https://github.com/nix-community/home-manager/blob/086f619dd991a4d355c07837448244029fc2d9ab/modules/programs/zoxide.nix#L75
  zoxideIntegration = "eval \"$(${zoxide.package}/bin/zoxide init zsh ${concatStringsSep " " zoxide.options})\"";
  # https://github.com/nix-community/home-manager/blob/086f619dd991a4d355c07837448244029fc2d9ab/modules/programs/direnv.nix#L122
  direnvIntegration = "eval \"$(${getExe direnv.package} hook zsh)\"";
in
{
  # Set as login shell
  programs.zsh.enable = true;
  users.users.${username}.shell = pkgs.zsh;
  # environment.pathsToLink = [ "/share/zsh" ];

  # Configure
  home-manager.users.${username}.programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    autocd = true;
    history = {
      ignoreAllDups = true;
      ignoreSpace = true;
    };
    initExtra = ''
      # === Zinit setup === #
      ZINIT_HOME="${pkgs.zinit}/share/zinit"

      source "''${ZINIT_HOME}/zinit.zsh"

      # @TODO: Should do this declaratively eventually, but that requires basically creating a zinit home-manager module from scratch.
      zinit light Aloxaf/fzf-tab 

      # === keybinds === #
      bindkey '^y' autosuggest-accept
      bindkey '^e' history-search-backward
      bindkey '^i' history-search-forward

      # === Completion styling === #
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

      # === Shell integrations === #
      # Not sure why I have to do this. Integrations like zoxide and fzf have
      # attributes called "enableZshIntegration", that when enabled, should add
      # their init commands to initExtra of zsh. They don't seem to get added,
      # so I do it here manually.
      ${if fzf.enable then fzfIntegration else ""}
      ${if zoxide.enable then zoxideIntegration else ""} 
      ${if direnv.enable then direnvIntegration else ""}
    '';
    syntaxHighlighting = {
      enable = true;
      highlighters = [ "main" "brackets" ];
    };
    shellAliases = {
      nixos-diff = "nix profile diff-closures --profile /nix/var/nix/profiles/system";
    };
  };
}
