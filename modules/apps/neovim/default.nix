{ config, pkgs, lib, ... }: 
let
#   lastplace = pkgs.vimUtils.buildVimPlugin {
#     name = "lastplace";
#     src = ./lastplace.lua;
#   };
  inherit (lib.meta) getExe;
in
{
  home-manager.users."${config.my.username}" = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      
      coc = {
        enable = true;
        settings = {
          formatOnSaveFileTypes = ["*"];
          languageserver.nix = {
            command = getExe pkgs.nil;
            filetypes = ["nix"];
            rootPatterns = ["flake.nix"];
            settings.nil.formatting.command = [ "${getExe pkgs.alejandra}" ];
          };
        };
      };

      plugins = [
      #  lastplace # I'll figure this out again some other time
      ];
      extraConfig = ''
        set tabstop=2
	      set softtabstop=0
	      set shiftwidth=0
	      set shiftround
	      set expandtab
	      set autoindent
        filetype plugin indent on

	      autocmd FileType ts setlocal noexpandtab
	      autocmd FileType c setlocal tabstop=4
      '';

      extraLuaConfig = ''
        --  ▗▄▄▖ ▗▄▖ ▗▖   ▗▄▄▄▖▗▖  ▗▖ ▗▄▖ ▗▖ ▗▖     ▗▄▄▖▗▖ ▗▖▗▄▄▖ ▗▖       ▗▄▄▖ ▗▄▄▄▖▗▖  ▗▖ ▗▄▖ ▗▄▄▖ ▗▄▄▖▗▄▄▄▖▗▖  ▗▖ ▗▄▄▖
        -- ▐▌   ▐▌ ▐▌▐▌   ▐▌   ▐▛▚▞▜▌▐▌ ▐▌▐▌▗▞▘    ▐▌   ▐▌ ▐▌▐▌ ▐▌▐▌       ▐▌ ▐▌▐▌   ▐▛▚▞▜▌▐▌ ▐▌▐▌ ▐▌▐▌ ▐▌ █  ▐▛▚▖▐▌▐▌   
        -- ▐▌   ▐▌ ▐▌▐▌   ▐▛▀▀▘▐▌  ▐▌▐▛▀▜▌▐▛▚▖     ▐▌   ▐▌ ▐▌▐▛▀▚▖▐▌       ▐▛▀▚▖▐▛▀▀▘▐▌  ▐▌▐▛▀▜▌▐▛▀▘ ▐▛▀▘  █  ▐▌ ▝▜▌▐▌▝▜▌
        -- ▝▚▄▄▖▝▚▄▞▘▐▙▄▄▖▐▙▄▄▖▐▌  ▐▌▐▌ ▐▌▐▌ ▐▌    ▝▚▄▄▖▝▚▄▞▘▐▌ ▐▌▐▙▄▄▖    ▐▌ ▐▌▐▙▄▄▖▐▌  ▐▌▐▌ ▐▌▐▌   ▐▌  ▗▄█▄▖▐▌  ▐▌▝▚▄▞▘

      	-- Adapted from https://www.reddit.com/r/Colemak/comments/xspr75/does_anyone_have_a_neovimvim_config_where_all_of/iqpf2np/

        -- Functional wrapper for mapping custom keybindings
        function map(mode, lhs, rhs, opts)
            local options = { noremap = true }
            if opts then
                options = vim.tbl_extend("force", options, opts)
            end
            vim.api.nvim_set_keymap(mode, lhs, rhs, options)
        end
        
        -- Colemak: hjkl>nieo, i>t
        map("n", "n", "h")          -- move Left
        map("n", "e", "gk")         -- move Up (g to allow move within wrapped lines)
        map("n", "i", "gj")         -- move Down (g to allow move within wrapped lines)
        map("n", "o", "l")          -- move Right
        map("n", "t", "i")          -- (t)ype           replaces (i)nsert
        map("n", "T", "I")          -- (T)ype at bol    replaces (I)nsert
        map("n", "E", "e")          -- end of word      replaces (e)nd
        map("n", "k", "n")          -- next match       replaces (n)ext
        map("n", "K", "N")          -- previous match   replaces (N) prev
        map("n", "h", "o")          -- new line below and insert mode
	      map("n", "H", "O")          -- new line above and insert mode

        -- Visual Colemak
        map("v", "n", "h")          -- move Left
        map("v", "e", "gk")         -- move Up (g to allow move within wrapped lines) - ~~shifted to fix [v]isual[i]n[...]~~ NOT shifted - I'll update the visual keybindings if I ever end up needing them.
        map("v", "i", "gj")         -- move Down (g to allow move within wrapped lines)
        map("v", "o", "l")          -- move Right 

        -- Enter commands without pressing shift
        map("n", ";", ":")
        map("n", ":", ";")
        
        -- Quickly return to normal_mode
        map("i", ",n", "<Esc>")
        
        -- Ctrl+up/down to page up/down
        map("n", "<C-e>", "<C-b>M")  -- page up
        map("n", "<C-i>", "<C-f>M")  -- page down

        --  ▗▄▄▖ ▗▄▖ ▗▖  ▗▖▗▄▄▄▖▗▄▄▄▖ ▗▄▄▖
        -- ▐▌   ▐▌ ▐▌▐▛▚▖▐▌▐▌     █  ▐▌   
        -- ▐▌   ▐▌ ▐▌▐▌ ▝▜▌▐▛▀▀▘  █  ▐▌▝▜▌
        -- ▝▚▄▄▖▝▚▄▞▘▐▌  ▐▌▐▌   ▗▄█▄▖▝▚▄▞▘

        vim.opt.relativenumber = true
      '';
    };
  };
}
