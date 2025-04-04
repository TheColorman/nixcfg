# Nix config

my nix configs and update script

## Layout

- `hosts/` - Configuration for each machine.
  - `framework/` - My Framework laptop. Only host for now.
- `modules/` - Nix [modules](https://nixos.wiki/wiki/Module) exposed as an output in `flake.nix`, which allows me to import them in host configurations or in other modules.
  - `apps/` - Each file enables a single application, along with my preffered configuration. If I want an application with its default configuration I won't create a separate app file for it.
  - `containers/` - NixOS containers, they can import other modules.
  - `patches/` - Git patches to change the source of any imported package.
  - `profiles/` - Collections of several apps and extra config.
  - `system/` - Configs for system features that aren't necessarily applications, e.g. fonts.

## todo

- [ ] Use `stylix` colors in `oh-my-posh` config.
- [ ] Add config path option to oh-my-posh to allow different configs (for containers).
- [ ] Shell improvements
  - [ ] Figure out how to import some of the `oh-my-zsh` aliases.
  - [ ] Allow using ctrl to skip words
- [ ] Better ranger/kitty/tmux/vim integration
  - [ ] Enable image preview in kitty
    - This will probably require contributins to tmux to allow kitty images to display...
  - [ ] Open files in new tmux window/pane
- [ ] Remove nvchad from neovim config?

### toDONE

- [x] Add [`sops-nix`](https://github.com/Mic92/sops-nix) for managing secrets.
- [x] Fix the fucking mess of a config.
- [x] Turn `*nix` aliases into scripts.
- [x] Merge `nixosModules` and `homeManagerModules` directories, mimicking [`MatthewCroughan/nixcfg`](https://github.com/MatthewCroughan/nixcfg)
- [x] Add `~/.config/fcitx5` to home-manager.
- [x] Add [binfmt](https://search.nixos.org/options?channel=24.05&show=boot.binfmt.emulatedSystems&from=0&size=50&sort=relevance&type=packages&query=boot.binfmt.emulatedSystems) support to run binaries from other architectures umulated.
