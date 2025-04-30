# Nix config

![hours spent last 30 days](https://waka.colorman.me/api/badge/colorman/interval:30_days/project:nixcfg?label=last%2030d)

system configurations for all my machines

## Layout

- `hosts/` - Configuration for each machine.
  - `framework/` - My Framework laptop.
  - `boarding/` - WSL.
  - `live/` - WIP live bootable ISO.
- `lib/` - Reusable Nix functions.
- `apps/` - Applications I use interactively. Git, neovim, mpv.
- `services/` - Background services with no direct influence tools. Docker,
  tailscale, kanata.
- `system/` - System settings. Boot, desktop environment, networking.
- `utils/` - Applications that have a more indirect impact on my workflow, but
  still in the foreground. Shells, mounts, terminals.

## todo

- [ ] Use `stylix` colors in `oh-my-posh` config.
- [ ] Add config path option to oh-my-posh to allow different configs (for
      containers).
- [ ] Shell improvements
  - [ ] Figure out how to import some of the `oh-my-zsh` aliases.
  - [ ] Allow using ctrl to skip words
- [ ] Better ranger/kitty/tmux/vim integration
  - [x] Enable image preview in kitty
    - This will probably require contributins to tmux to allow kitty images to
      display...
  - [ ] Open files in new tmux window/pane

### toDONE

- [x] Add [`sops-nix`](https://github.com/Mic92/sops-nix) for managing secrets.
- [x] Fix the fucking mess of a config.
- [x] Turn `*nix` aliases into scripts.
- [x] Merge `nixosModules` and `homeManagerModules` directories, mimicking
      [`MatthewCroughan/nixcfg`](https://github.com/MatthewCroughan/nixcfg)
- [x] Add `~/.config/fcitx5` to home-manager.
- [x] Add
      [binfmt](https://search.nixos.org/options?channel=24.05&show=boot.binfmt.emulatedSystems&from=0&size=50&sort=relevance&type=packages&query=boot.binfmt.emulatedSystems)
      support to run binaries from other architectures umulated.
- [x] Remove nvchad from neovim config?
