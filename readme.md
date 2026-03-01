# Nix config

![hours spent last 30 days](https://waka.colorman.me/api/badge/colorman/interval:30_days/project:nixcfg?label=last%2030d)

[dendritic](https://github.com/mightyiam/dendritic) system configurations for
all my machines

## Layout

- `hosts/` - Configuration for each machine.
  - `archer/` - My Framework laptop.
  - `caster/` - Media + general purpose server.
  - `foreigner/` - WSL.
  - `rider/` - Raspberry Pi 4B.
  - `saber/` - Desktop computer.
- `apps/` - Applications I use interactively. Git, neovim, mpv.
- `services/` - Background services with no direct influence tools. Docker,
  tailscale, kanata.
- `system/` - System settings. Boot, desktop environment, networking.
- `utils/` - Applications that have a more indirect impact on my workflow, but
  still in the foreground. Shells, mounts, terminals.

## Branches

I only have 2 branches `main` and `stable`. `main` runs `nixos-unstable`,
whereas `stable` runs whatever the stable version of nixpkgs is at the moment.
As of writing, this is `25.05`. The only host I build from `stable` is Caster as
the applications running there are at a higher risk of breaking during major
updates. Running stable allows me to plan my updates better.
