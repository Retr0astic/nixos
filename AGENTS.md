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

## Token and Context Discipline

- Read only the files needed for the task. Do not scan the whole repo unless the task requires architecture-level understanding.
- Prefer `rg`, `fd`, `git grep`, and targeted file reads over broad recursive dumps.
- When inspecting files, summarize findings instead of pasting large blocks back into chat.
- Before opening many files, identify likely entry points from `flake.nix`, nearest `default.nix`, or the relevant module path.
- Keep responses concise: state what changed, why, validation status, and any risks.
- Do not repeat unchanged config in replies. Show only patches, commands, or small relevant snippets.
- For large refactors, work in phases and keep each phase narrowly scoped.

## Subagent Workflow

Use subagents mainly for inspection and review, not parallel editing.

Recommended flow:
1. Explorer subagent maps relevant files and dependencies.
2. Specialist subagent inspects the specific area being changed.
3. Main agent proposes an exact file-level change plan.
4. Only one implementer edits files.
5. Reviewer subagent checks the diff for Nix syntax, duplicate options, misplaced config, and risky rebuild issues.

Rules:
- Do not let multiple subagents edit the same files concurrently.
- Prefer read-only subagents for discovery.
- Use a single editing agent for actual patches.
- Before editing, list the exact files expected to change.
- After editing, summarize the diff and validation result.
- For risky NixOS, Hyprland, NVIDIA, UWSM, boot, kernel, LUKS, filesystem, or hardware changes, inspect first and explain the planned edits before modifying files.

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

Do not run heavier builds when `nix flake check` already evaluates the affected output enough for the change. For system-level changes that are not sufficiently covered by `nix flake check`, build the Chapel toplevel when practical:

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
