{pkgs, ...}: {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  autocd = true;
  dirHashes = {
    dl = "$HOME/Downloads";
  };
  history = {
    ignoreAllDups = true;
    ignoreSpace = true;
  };
  initExtra = ''
    ZINIT_HOME="${pkgs.zinit}/share/zinit"

    source "''${ZINIT_HOME}/zinit.zsh"

    # Should do this declaratively eventually, but that requires basically creating a zinit home-manager module from scratch.
    zinit ice depth=1; zinit light romkatv/powerlevel10k
    zinit light Aloxaf/fzf-tab 

    # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
    [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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
  initExtraFirst = ''
    # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
    # Initialization code that may require console input (password prompts, [y/n]
    # confirmations, etc.) must go above this block; everything else may go below.
    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    fi
  '';
  shellAliases = {
    tnix = "pushd ~/nixos/config && sudo nix flake update && sudo nixos-rebuild test --flake ~/nixos/config && popd";
    snix = "pushd ~/nixos/config && sudo nix flake update && sudo nixos-rebuild switch --flake ~/nixos/config && popd";
    bnix = "pushd ~/nixos/config && sudo nix flake update && sudo nixos-rebuild boot --flake ~/nixos/config && popd";
    dnix = "pushd ~/nixos/config && sudo nix flake update && sudo nixos-rebuild dry-build --flake ~/nixos/config && popd";
    nixswitch = "pushd ~/nixos/config && sudo nixos-rebuild switch --flake ~/nixos/config && popd";
  };
  syntaxHighlighting = {
    enable = true;
    highlighters = ["main" "brackets"];
  };
}