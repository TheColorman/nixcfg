# AGENTS.md

NixOS configurations for 8 hosts, built with dendritic (flake-parts + import-tree). No CI, no tests, no devShell — verification is evaluating/building the flake.

## Module naming (dendritic)

- Every `.nix` file in the tree is a module named by its path with dashes: `hosts/archer/configuration.nix` → `self.nixosModules.archer-configuration`.
- Each file must return an attrset keyed by that full name, e.g. `{ flake.nixosModules.apps-git = { ... }: { ... }; }` — not a bare NixOS module.
- Hosts live in `hosts/<name>/`: `default.nix` defines `flake.nixosConfigurations.<name>` via `nixpkgs.lib.nixosSystem`; `configuration.nix` is the real config; `hardware-configuration.nix` is hardware.
- Modules are not global: a file only applies to hosts that import it from their `configuration.nix`. This includes the bundles in `profiles/` (gaming, hacking, office, language-servers). To add a feature, create the file under `apps/`, `services/`, `system/`, or `utils/`, then import it per host.

## Hosts and branches

- Hosts: archer, caster, lancer, mooncancer, pretender, rider, saber, foreigner. foreigner + mooncancer are WSL (`wsl.enable = true`).
- Branches: `main` tracks `nixos-unstable`; `stable` pins `nixos-26.05` + home-manager `release-26.05`. Only caster is deployed from `stable`. Check the current branch before assuming a package or option exists.
- Each host sets `my.username` (defaults to "color") and must set `my.stateVersion` (no default). The username differs per host ("color", "boarder", ...) — always use `"${config.my.username}"`, never hardcode it.

## Verification

- Quick eval: `nix eval .#nixosConfigurations.<host>.config.system.stateVersion --raw`
- Full build: `nix build .#nixosConfigurations.<host>.configuration` (on a host, nixos-rebuild; `result/` is the last-build symlink and is gitignored)
- Format Nix with nixfmt (2-space indent per `.editorconfig`).

## Gotchas

- VCS is Jujutsu (`jj`; `.jj/` present), git works as backend. Commit style: `<path>: <summary>` (e.g. `hosts/saber: add opencode`, `flake.lock: Update`).
- Secrets live in the private `nix-secrets` repo, fetched via `git+ssh://github.com/TheColorman/nix-secrets`. Evaluating the flake requires SSH access to github.com; foreigner also imports `${inputs.nix-secrets}/evaluation-secrets.nix` at eval time. Never commit secrets here.
- sops-nix: age key is generated per host (`/var/lib/sops-nix/key.txt`) plus the host ssh ed25519 key; `sops.defaultSopsFile` points at nix-secrets' `secrets.yaml`.
- WSL hosts (foreigner, mooncancer): envfs must stay force-disabled — it makes the system unbootable.
- Deployment uses deploy-rs; a `deploy` wrapper (piped into nix-output-monitor) is installed only on saber. There is no deploy.yaml/deploy.nix in this repo.
- lancer is provisioned with disko (`lancer-disko-config`, imported from its `default.nix`).
