# Noctalia shell architectural refinement plan

Status: Phase 0 complete. Phase 1 is pending explicit approval.

## Scope and classification

The requested implementation is non-trivial: it changes the typed graphical-shell schema, NixOS module composition, Home Manager ownership, checks, and architecture documentation. The implementation must use the repository’s planner → implementer → reviewer workflow; only the implementer may edit implementation files.

This is a focused refinement after the migration plan’s Phase 8. It does not approve the migration plan’s pending final checkpoint or authorize wider architectural work.

## Current execution path

`flake.nix` imports `modules/default.nix`, which discovers registrations. The typed registries are defined in `modules/schema.nix`; `modules/configurations.nix::mkHost` resolves the selected host, desktop, shell, theme, integration, features, and users.

Current system composition is host, feature systems, user systems, desktop system, Home Manager NixOS configuration, integration system, and extras. There is no shell system side because the shell schema exposes only `home`. Shared Home Manager imports are composed independently for each selected user and include feature homes, desktop home, shell home, theme home, and integration home.

`modules/shells/noctalia.nix` owns the upstream Noctalia Home Manager module and program enablement. `modules/themes/noctalia.nix` currently owns the recursive `.config/noctalia` target and immutable `builtins.path` snapshot, plus the Kitty `themes/noctalia.conf` include. The Hyprland–Noctalia integration owns IPC, startup, bindings, layer rules, Lua theme application, and Starship palette activation.

## Ownership map

| Concern | Current owner | Target owner |
| --- | --- | --- |
| Noctalia HM module and package/program enablement | `shells.noctalia.home` | unchanged |
| `.config/noctalia` recursive target and immutable asset snapshot | `themes.noctalia.home` | `shells.noctalia.home` |
| Noctalia general config, plugins, templates, QML, scripts, and assets | theme target | shell target |
| Noctalia colors and Kitty theme include | theme | theme |
| Hyprland IPC/startup/bindings/layer/Lua/Starship integration | integration | unchanged |
| Personal `noctalia-config` export alias | Sree user home | unchanged |
| Physical asset location | `modules/noctalia/` | unchanged |

The preferred strategy is an atomic move of the unchanged parent target. Do not split the tree into per-file declarations, retain a compatibility duplicate, filter assets, or touch `modules/noctalia/**`. This leaves exactly one Home Manager target and keeps the source path, recursive behavior, plugin enablement, templates, QML, scripts, and all current behavior unchanged. The inventory contains 157 actual non-backup entries:

| Asset subtree | Entries | Target owner |
| --- | ---: | --- |
| `colors.json`, `config.toml`, `plugins.json`, `user-templates.toml` | 4 | shell target (colors remains styling content) |
| `plugins/ds4-colors/` | 14 | shell |
| `plugins/noctalia-calculator/` | 19 | shell |
| `plugins/screen-recorder/` | 24 | shell |
| `plugins/screen-shot-and-record/` | 17 | shell |
| `plugins/tamagotchi/` | 34 | shell |
| `plugins/usb-drive-manager/` | 14 | shell |
| `plugins/wallcards/` | 31 | shell |

The current enabled/disabled plugin state is preserved. The theme retains the Kitty include and visual styling responsibility; it does not provide general shell state.

## Phase 1 — Add and compose `shell.system`

Checkpoint: `Approve Phase 1 — Add shell system composition`.

Expected files: `modules/schema.nix`, `modules/configurations.nix`, and `modules/checks.nix`; current shell registrations need not change if the new field defaults to `{}`.

1. Extend the existing shell submodule helper with optional `system` of the existing deferred-module type, default `{}`, and retain `home` unchanged.
2. Resolve the selected shell once and compose `shell.system` exactly once immediately after `desktop.system` and before Home Manager’s NixOS modules.
3. Keep `composeUserHomes` and per-user Home Manager isolation unchanged.
4. Add focused composition checks for a shell with both sides and a home-only shell using the default empty system side. Do not create fake enabled runtime shells.
5. Preserve registry names, integrations, aliases, and Chapel behavior.

Acceptance: existing home-only registrations evaluate; future shells can provide a NixOS module; the selected shell system module appears once in the documented order; canonical and alias Chapel outputs remain equal.

## Phase 2 — Split Noctalia ownership

Checkpoint: `Approve Phase 2 — Split Noctalia shell and theme ownership`.

Expected files: `modules/shells/noctalia.nix` and `modules/themes/noctalia.nix`. Move the unchanged `home.file.".config/noctalia"` block, including `path = ../noctalia`, `name = "noctalia-assets"`, and `recursive = true`, from theme to shell. Keep the upstream Noctalia options in the shell and Kitty styling in the theme. Do not modify the Noctalia asset tree or Hyprland integration.

Acceptance: the shell is the sole owner of the target; the theme owns only independent visual styling; exactly one target remains; all assets and plugin states are preserved; the evaluated source and Chapel derivation remain unchanged.

## Phase 3 — Documentation and final review

Checkpoint: `Approve Phase 3 — Final review`.

Expected files: `README.md` and this plan, with only a concise follow-up in `docs/dendritic-migration-plan.md` if needed. Document that graphical shells may provide both NixOS and Home Manager modules; shell configuration is functional UI state; themes are visual styling; integrations are pair-specific; and Noctalia assets are immutable repository-owned assets. Include the requested ownership table.

Terra must independently verify schema optionality, generator composition, per-user isolation, shell/theme separation, target uniqueness, asset completeness, no checkout path or out-of-store symlink regression, integration behavior, alias equality, both closures, documentation, and absence of medium/high findings.

## Risks and recovery

The principal risks are duplicate Home Manager targets, asset mutation from the dirty Noctalia tree, accidental per-user module leakage, module-order regressions, and alias divergence. Rollback is an inverse patch limited to the current phase; do not use `git reset`, `git checkout`, cleanup, activation, or switch commands. No boot, storage, login, data-loss, or reboot risk is introduced without activation.

The worktree has 1,113 pre-existing status entries, including `flake.lock`, `modules/features/packages.nix`, and extensive modified/typechanged/untracked Noctalia backup and symlink files. These are user-owned and must remain untouched. Before each phase, snapshot those paths and confirm expected phase files are clean; after each phase compare the snapshots and inspect only the phase-scoped diff. Stop for user direction if any unrelated snapshot changes.

## Verification commands

Run the narrowest relevant checks after each phase and the full matrix at the end:

```fish
nix fmt
git diff --check
nix flake show
nix flake check
nix eval --json .#nixosConfigurations --apply builtins.attrNames
nix eval .#nixosConfigurations.chapel.config.networking.hostName
nix eval .#nixosConfigurations.chapel-hyprland-noctalia.config.networking.hostName
nix eval .#nixosConfigurations.chapel.config.programs.hyprland.enable
nix build .#nixosConfigurations.chapel.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.chapel-hyprland-noctalia.config.system.build.toplevel --no-link
nix eval --raw .#nixosConfigurations.chapel.config.system.build.toplevel.drvPath
nix eval --raw .#nixosConfigurations.chapel-hyprland-noctalia.config.system.build.toplevel.drvPath
rg -n 'home\\.file.*noctalia|xdg\\.configFile.*noctalia|builtins\\.path|mkOutOfStoreSymlink' modules --glob '*.nix'
rg -n '/home/sree/nixos|~/nixos|mkOutOfStoreSymlink' modules --glob '*.nix'
find modules/noctalia -type f -print | sort
find modules/noctalia -type l -print
nix build .#nixosConfigurations.chapel.config.home-manager.users.sree.home.activationPackage --no-link
```

Also evaluate the final Home Manager target to confirm `recursive = true`, its source, and exactly one `.config/noctalia` entry; verify Noctalia remains enabled with systemd disabled; check JSON assets; and compare canonical and alias derivation paths. Record that `nix fmt` may report no formatter output if that pre-existing limitation remains.

Stop here. Phase 1 requires explicit approval.

