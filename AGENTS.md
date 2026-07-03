# Agent Guide

This repository is Sree's NixOS flake. Treat it as a machine configuration first: keep changes small, validate with Nix, and do not rewrite hardware- or host-specific settings unless the user asked for that.

## Repository Shape

- `flake.nix` is the flake-parts entrypoint. It imports all modules under `flake/` through `lib/treeimport.nix`.
- `flake/hosts.nix` owns host composition. Add desktops, themes, host aliases, and `mkHost` changes there.
- `hosts/chapel/` contains Chapel-specific NixOS configuration and generated hardware configuration.
- `modules/nixos/` contains reusable system modules.
- `modules/home/` contains reusable Home Manager modules for user `sree`.
- `modules/home/desktops/` contains desktop-specific Home Manager settings.
- `modules/home/themes/` contains theme integrations.
- `modules/noctalia/` contains Noctalia config and plugin files.
- `configuration.nix` is only a compatibility shim importing `hosts/chapel`.

## Change Placement

- Put host-only boot, LUKS, hostname, kernel, and generated hardware settings in `hosts/chapel/`.
- Put common NixOS packages and Nix settings in `modules/nixos/core/default.nix`.
- Put system services in `modules/nixos/services/default.nix`.
- Put user packages in `modules/home/packages/default.nix`.
- Put shell aliases and CLI integrations in `modules/home/shell/default.nix`.
- Put terminal packages/config in `modules/home/terminals/default.nix`.
- Put Home Manager app modules under `modules/home/programs/` and import them from `modules/home/programs/default.nix`.
- Put XDG MIME/user-dir settings in `modules/home/xdg/default.nix`.
- Put Hyprland user settings in `modules/home/desktops/hyprland.nix`.
- Put Noctalia Home Manager integration in `modules/home/themes/noctalia.nix`.

## Nix Style

- Follow the existing compact Nix style: two-space indentation, grouped option sets, and short modules.
- Prefer explicit imports from the nearest `default.nix` for `modules/home/*` and `modules/nixos/*`.
- For new desktop or theme variants, register them in `flake/hosts.nix` before adding host outputs.
- Keep package lists alphabetized only when the surrounding list already is. Otherwise preserve local ordering and minimize churn.
- Use `with pkgs; [ ... ]` consistently where the existing module already uses it.
- Do not change `system.stateVersion` or `home.stateVersion` unless the user explicitly asks.
- Do not edit `flake.lock` unless updating inputs is part of the task.

## Validation

Run the narrowest useful check after edits:

```bash
nix flake check
```

For system-level changes, also build the Chapel toplevel when practical:

```bash
nix build .#nixosConfigurations.chapel.config.system.build.toplevel
```

Before suggesting a live switch, prefer a test activation:

```bash
sudo nixos-rebuild test --flake .#chapel
```

Use `sudo nixos-rebuild switch --flake .#chapel` only when the user wants the machine switched.

## Workflow Notes

- Check `git status --short` before editing. The worktree may contain user changes; do not revert or overwrite them.
- Keep README command examples aligned with actual flake outputs if outputs change.
- Noctalia plugin changes may involve QML, JSON, shell scripts, images, and i18n files. Keep plugin manifests and settings files in sync with QML entrypoints.
- This repo's default host is `chapel`, and `chapel-hyprland-noctalia` is an alias for it.
- The active branch workflow in `README.md` references `testing`; do not assume commits should go to another branch.
