# Nix config

![hours spent last 30 days](https://waka.colorman.me/api/badge/colorman/interval:30_days/project:nixcfg?label=last%2030d)

system configurations for all my machines

## Layout

- `hosts/` - Configuration for each machine.
  - `archer/` - My Framework laptop.
  - `boarding/` - WSL.
  - `live/` - WIP live bootable ISO.
- `lib/` - Reusable Nix functions.
- `apps/` - Applications I use interactively. Git, neovim, mpv.
- `services/` - Background services with no direct influence tools. Docker,
  tailscale, kanata.
- `system/` - System settings. Boot, desktop environment, networking.
- `utils/` - Applications that have a more indirect impact on my workflow, but
  still in the foreground. Shells, mounts, terminals.
