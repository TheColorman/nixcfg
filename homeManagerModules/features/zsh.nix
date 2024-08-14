{ lib, config, pkgs, ... }:
let
  cfg = config.myHomeManager.zsh;
in
{
  imports = [ ];

  options.myHomeManager.zsh.enable = lib.mkEnableOption "Enable zsh config";

  config = lib.mkIf cfg.enable {
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
      shellAliases = {
        tnix = "pushd ~/nixos && git add . && sudo nix flake update && git add . && git commit -m 'temp' && sudo nixos-rebuild test --flake ~/nixos --option eval-cache false && git reset --soft HEAD~1 && popd";
        snix = "pushd ~/nixos && sudo nixos-rebuild switch --flake ~/nixos && popd";
        bnix = "pushd ~/nixos && sudo nixos-rebuild boot --flake ~/nixos && popd";
        dnix = "pushd ~/nixos && sudo nixos-rebuild dry-build --flake ~/nixos && popd";
        conf = "pushd ~/nixos && ranger && popd";
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
    };
    programs.fzf = {
      enable = true;
      tmux.enableShellIntegration = lib.mkIf config.myHomeManager.tmux.enable true;
    };
  };
}
