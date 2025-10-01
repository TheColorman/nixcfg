{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.my) username;
  inherit (lib.strings) optionalString;
  inherit (lib.modules) mkMerge mkIf;
  inherit (lib.meta) getExe;

  desktopPortalEnabled = config.xdg.portal.enable or false;
  stylixEnabled = config.stylix.enable or false;
in {
  home-manager.users."${username}" = mkMerge [
    # Installation
    {
      programs.zellij = {
        enable = true;
        # If I have a desktop portal, then I don't expect to have Zellij in the
        # TTY. If I do not have one, I do want zellij in TTY.
        enableFishIntegration = mkIf (!desktopPortalEnabled) true;
        attachExistingSession = mkIf (!desktopPortalEnabled) true;
        exitShellOnExit = mkIf (!desktopPortalEnabled) true;
      };
    }

    # Integration
    {
      xdg.configFile = {
        "kitty/launch.conf".text = ''
          launch ${getExe pkgs.zellij} attach -c
        '';
      };
    }

    # Configuration
    {
      # zellij uses kdl for config, but that looks ass in HM/Nix
      xdg.configFile."zellij/config.kdl".text = ''
        keybinds clear-defaults=true {
            locked {
                bind "Ctrl g" { SwitchToMode "Normal"; }
            }
            resize {
                bind "Ctrl n" { SwitchToMode "Normal"; }
                bind "n" "Left" { Resize "Increase Left"; }
                bind "e" "Up" { Resize "Increase Up"; }
                bind "i" "Down" { Resize "Increase Down"; }
                bind "o" "Right" { Resize "Increase Right"; }
                bind "N" { Resize "Decrease Left"; }
                bind "E" { Resize "Decrease Up"; }
                bind "I" { Resize "Decrease Down"; }
                bind "O" { Resize "Decrease Right"; }
                bind "=" "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
            }
            pane {
                bind "Ctrl p" { SwitchToMode "Normal"; }
                bind "n" "Left" { MoveFocus "Left"; }
                bind "e" "Up" { MoveFocus "Up"; }
                bind "i" "Down" { MoveFocus "Down"; }
                bind "o" "Right" { MoveFocus "Right"; }
                bind "p" { SwitchFocus; }
                bind "t" { NewPane; SwitchToMode "Normal"; }
                bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                bind "r" { NewPane "Right"; SwitchToMode "Normal"; }
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "z" { TogglePaneFrames; SwitchToMode "Normal"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
                bind "m" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0;}
                bind "k" { TogglePanePinned; SwitchToMode "Normal"; }
            }
            move {
                bind "Ctrl h" { SwitchToMode "Normal"; }
                bind "t" "Tab" { MovePane; }
                bind "p" { MovePaneBackwards; }
                bind "n" "Left" { MovePane "Left"; }
                bind "e" "Up" { MovePane "Up"; }
                bind "i" "Down" { MovePane "Down"; }
                bind "o" "Right" { MovePane "Right"; }
            }
            tab {
                bind "Ctrl t" { SwitchToMode "Normal"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "n" "Left" "Up" "e" { GoToPreviousTab; }
                bind "o" "Right" "Down" "i" { GoToNextTab; }
                bind "t" { NewTab; SwitchToMode "Normal"; }
                bind "x" { CloseTab; SwitchToMode "Normal"; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
                bind "b" { BreakPane; SwitchToMode "Normal"; }
                bind "]" { BreakPaneRight; SwitchToMode "Normal"; }
                bind "[" { BreakPaneLeft; SwitchToMode "Normal"; }
                bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                bind "6" { GoToTab 6; SwitchToMode "Normal"; }
                bind "7" { GoToTab 7; SwitchToMode "Normal"; }
                bind "8" { GoToTab 8; SwitchToMode "Normal"; }
                bind "9" { GoToTab 9; SwitchToMode "Normal"; }
                bind "Tab" { ToggleTab; }
            }
            scroll {
                bind "Ctrl s" { SwitchToMode "Normal"; }
                bind "t" { EditScrollback; SwitchToMode "Normal"; }
                bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                bind "i" "Down" { ScrollDown; }
                bind "e" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" "Right" "o" { PageScrollDown; }
                bind "Ctrl b" "PageUp" "Left" "n" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
            }
            search {
                bind "Ctrl s" { SwitchToMode "Normal"; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Normal"; }
                bind "i" "Down" { ScrollDown; }
                bind "e" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" "Right" "o" { PageScrollDown; }
                bind "Ctrl b" "PageUp" "Left" "n" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "k" { Search "down"; }
                bind "K" { Search "up"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "r" { SearchToggleOption "WholeWord"; }
            }
            entersearch {
                bind "Ctrl c" "Esc" { SwitchToMode "Scroll"; }
                bind "Enter" { SwitchToMode "Search"; }
            }
            renametab {
                bind "Ctrl c" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenameTab; SwitchToMode "Tab"; }
            }
            renamepane {
                bind "Ctrl c" { SwitchToMode "Normal"; }
                bind "Esc" { UndoRenamePane; SwitchToMode "Pane"; }
            }
            session {
                bind "Ctrl e" { SwitchToMode "Normal"; }
                bind "Ctrl s" { SwitchToMode "Scroll"; }
                bind "d" { Detach; }
                bind "w" {
                    LaunchOrFocusPlugin "session-manager" {
                        floating true
                        move_to_focused_tab true
                    };
                    SwitchToMode "Normal"
                }
                bind "c" {
                    LaunchOrFocusPlugin "configuration" {
                        floating true
                        move_to_focused_tab true
                    };
                    SwitchToMode "Normal"
                }
                bind "p" {
                    LaunchOrFocusPlugin "plugin-manager" {
                        floating true
                        move_to_focused_tab true
                    };
                    SwitchToMode "Normal"
                }
                bind "a" {
                    LaunchOrFocusPlugin "zellij:about" {
                        floating true
                        move_to_focused_tab true
                    };
                    SwitchToMode "Normal"
                }
            }
            // tmux {
            //     bind "[" { SwitchToMode "Scroll"; }
            //     bind "Ctrl b" { Write 2; SwitchToMode "Normal"; }
            //     bind "\"" { NewPane "Down"; SwitchToMode "Normal"; }
            //     bind "%" { NewPane "Right"; SwitchToMode "Normal"; }
            //     bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
            //     bind "c" { NewTab; SwitchToMode "Normal"; }
            //     bind "," { SwitchToMode "RenameTab"; }
            //     bind "p" { GoToPreviousTab; SwitchToMode "Normal"; }
            //     bind "n" { GoToNextTab; SwitchToMode "Normal"; }
            //     bind "Left" { MoveFocus "Left"; SwitchToMode "Normal"; }
            //     bind "Right" { MoveFocus "Right"; SwitchToMode "Normal"; }
            //     bind "Down" { MoveFocus "Down"; SwitchToMode "Normal"; }
            //     bind "Up" { MoveFocus "Up"; SwitchToMode "Normal"; }
            //     bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
            //     bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
            //     bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
            //     bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
            //     bind "o" { FocusNextPane; }
            //     bind "d" { Detach; }
            //     bind "Space" { NextSwapLayout; }
            //     bind "x" { CloseFocus; SwitchToMode "Normal"; }
            // }
            shared_except "locked" {
                bind "Ctrl g" { SwitchToMode "Locked"; }
                bind "Ctrl q" { Quit; }
                bind "Alt f" { ToggleFloatingPanes; }
                bind "Alt t" { NewPane; }
                bind "Alt l" { MoveTab "Left"; }
                bind "Alt ;" { MoveTab "Right"; }
                bind "Alt n" "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt e" "Alt Up" { MoveFocus "Up"; }
                bind "Alt i" "Alt Down" { MoveFocus "Down"; }
                bind "Alt o" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt =" "Alt +" { Resize "Increase"; }
                bind "Alt -" { Resize "Decrease"; }
                bind "Alt [" { PreviousSwapLayout; }
                bind "Alt ]" { NextSwapLayout; }
            }
            shared_except "normal" "locked" {
                bind "Enter" "Esc" { SwitchToMode "Normal"; }
            }
            shared_except "pane" "locked" {
                bind "Ctrl p" { SwitchToMode "Pane"; }
            }
            shared_except "resize" "locked" {
                bind "Ctrl n" { SwitchToMode "Resize"; }
            }
            shared_except "scroll" "locked" {
                bind "Ctrl s" { SwitchToMode "Scroll"; }
            }
            shared_except "session" "locked" {
                bind "Ctrl e" { SwitchToMode "Session"; }
            }
            shared_except "tab" "locked" {
                bind "Ctrl t" { SwitchToMode "Tab"; }
            }
            shared_except "move" "locked" {
                bind "Ctrl h" { SwitchToMode "Move"; }
            }
            // shared_except "tmux" "locked" {
            //     bind "Ctrl b" { SwitchToMode "Tmux"; }
            // }
        }

        // Plugin aliases - can be used to change the implementation of Zellij
        // changing these requires a restart to take effect
        plugins {
            tab-bar location="zellij:tab-bar"
            status-bar location="zellij:status-bar"
            strider location="zellij:strider"
            compact-bar location="zellij:compact-bar"
            session-manager location="zellij:session-manager"
            welcome-screen location="zellij:session-manager" {
                welcome_screen true
            }
            filepicker location="zellij:strider" {
                cwd "/"
            }
            configuration location="zellij:configuration"
            plugin-manager location="zellij:plugin-manager"
            about location="zellij:about"
        }

        scroll_buffer_size 100000

        pane_frames false

        show_startup_tips false

        ${optionalString (!stylixEnabled) ''theme "gruvbox-light"''}
      '';
    }
  ];
}
