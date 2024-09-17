{ lib, config, pkgs, ... }:
let
  tmuxEnabled = config.home-manager.users."${config.my.username}".programs.tmux.enable;
in
{
  users.users.${config.my.username}.shell = pkgs.zsh;
  programs.zsh.enable = true;
  environment.systemPackages = with pkgs; [
    zsh
    zoxide
    highlight
  ];
  environment.pathsToLink = [ "/share/zsh" ];

  home-manager.users."${config.my.username}" = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      autocd = true;
      history = {
        ignoreAllDups = true;
        ignoreSpace = true;
      };
      initExtra = ''
        ZINIT_HOME="${pkgs.zinit}/share/zinit"

        source "''${ZINIT_HOME}/zinit.zsh"

        # Should do this declaratively eventually, but that requires basically creating a zinit home-manager module from scratch.
        zinit light Aloxaf/fzf-tab 

        # oh-my-posh initialization
        # eval "$(oh-my-posh init zsh)" # No need, home-manager does this for me :3

        # keybinds
        bindkey '^F' autosuggest-accept
        bindkey '^[v' .describe-key-briefly # for figuring out the actual keys
        bindkey '^[OA' history-search-backward
        bindkey '^[OB' history-search-forward

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

        # Shell integrations
        eval "$(zoxide init --cmd cd zsh)"
        eval "$(fzf --zsh)"
      '';
      initExtraFirst = "";
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
      shellAliases = {
        nixos-diff = "nix profile diff-closures --profile /nix/var/nix/profiles/system";
      };
    };
    programs.fzf = {
      enable = true;
      tmux.enableShellIntegration = lib.mkIf tmuxEnabled true;
    };
  };
}
