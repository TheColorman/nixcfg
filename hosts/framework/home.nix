{
  config,
  pkgs,
  ...
}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "color";
  home.homeDirectory = "/home/color";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".p10k.zsh".source = ./dotfiles/p10k.zsh;
    ".config/kitty/launch.conf".source = ./dotfiles/kitty_launch.conf;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/color/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    zsh = {
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
        nixtest = "pushd ~/nixos/config && sudo nix flake update && sudo nixos-rebuild test --flake ~/nixos/config && popd";
        nixswitch = "pushd ~/nixos/config && sudo nixos-rebuild switch --flake ~/nixos/config && popd";
      };
      syntaxHighlighting = {
        enable = true;
        highlighters = ["main" "brackets"];
      };
    };

    kitty = {
      enable = true;
      font.name = "CaskaydiaCove Nerd Font";
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
      };
      shellIntegration.enableZshIntegration = true;
      extraConfig = ''
        startup_session launch.conf
      '';
    };

    tmux = {
      enable = true;
      clock24 = true;
      customPaneNavigationAndResize = true;
      keyMode = "vi";
      mouse = true;
      terminal = "screen-256color";
    };

    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };
  };
}
