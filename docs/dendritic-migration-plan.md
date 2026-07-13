# Final dendritic and modular architecture migration plan

Status: Phase 4 complete; Phase 5 pending explicit approval. This document was
prepared from the repository at `28ac4f2` on 2026-07-13. Phase 1 was completed
after explicit approval; no later phase is authorized by this document.

## 1. Executive summary

The repository already has the important dendritic foundation: `flake.nix`
imports `modules/default.nix`; that file recursively imports Nix registrations;
`modules/schema.nix` defines lazy string-keyed registries with deferred
modules; and `modules/configurations.nix` turns a configuration record into a
NixOS output. The existing `chapel-hyprland-noctalia` output and `chapel`
alias are the correct shape to preserve.

The migration is needed because composition is not yet truthful. The generator
selects feature system modules but hardcodes a list of feature Home Manager
modules, and that same Home Manager list is applied to every selected user.
Hyprland contains Noctalia IPC/Lua/layer behavior, Samsung/HDR/NVIDIA policy,
and personal startup/window rules. Chapel selects `hyprland` in the physical
host. The Noctalia theme points at `/home/sree/nixos` through an out-of-store
symlink, and a generic Home Manager package feature owns Sree’s identity.
Finally, the current `aliases` option does not use the requested
`configurationAliases` name, and the host lower-level tree needs an explicit
retention decision.

The target is a small registry framework where host, user, desktop, shell,
theme, integration, feature, configuration, and alias are independent typed
records. A configuration resolves stable strings, composes each selected
feature’s `system` and `home` sides automatically, and imports each selected
user’s home module only into that user’s Home Manager entry. Compatibility is
validated only through `retr0astic.integrations`. Future variants require only
new registrations and a configuration record.

Strategy: establish a baseline, repair composition without moving files, then
move ownership in narrow behavioral phases. Preserve host boot/storage and the
generated hardware file until their owners are explicit. Do not add Niri, AGS,
Plasma, or other unused implementations.

## 2. Current-state findings

### Confirmed defects

* `modules/configurations.nix:31-38` computes `featureModules` from only
  `.system`, then centrally hardcodes `appearance`, `packages`, `programs`,
  `services-home`, `shell`, `terminals`, `xdg`, and `starship` home features.
  A declared feature therefore does not automatically contribute its home
  side.
* `modules/configurations.nix:36-41` constructs one `userHomes` list and puts
  it into every `home-manager.users.<name>`. Each selected user receives every
  selected user’s `home` module, and all shared modules are indistinguishable
  from personal modules.
* `modules/desktops/session.nix` imports `noctalia`, starts `noctalia`, and
  starts personal Spotify/Vesktop processes. `modules/desktops/settings.nix`
  defines `noctalia msg` IPC and a Noctalia launcher; `bindings.nix` calls
  Noctalia IPC; `rules.nix` owns Noctalia layer rules. The Hyprland registry
  therefore is not shell-independent.
* `modules/desktops/settings.nix` owns the Samsung monitor identity, HDR
  values, NVIDIA environment, and `NIXOS_OZONE_WL`; these are not reusable
  desktop defaults.
* `hosts/chapel/default.nix:46` sets
  `services.displayManager.defaultSession = "hyprland"`.
* `modules/home/packages.nix` hardcodes `username = "sree"` and
  `/home/sree`; `modules/themes/noctalia-theme.nix` hardcodes
  `/home/sree/nixos/modules/noctalia`.

### Architectural coupling

* `modules/integrations/hyprland-noctalia.nix` is currently an empty
  compatibility record, so the settings it should own remain in Hyprland.
* `modules/desktops/rules.nix` mixes reusable game/window behavior with
  Noctalia layer policy and personal application classes.
* `modules/features/graphics.nix` combines reusable graphics with a pinned
  custom NVIDIA driver. The driver and GPU environment need a host/hardware
  boundary, even if the selected Chapel graphics feature remains the current
  registration during migration.
* `modules/features/services.nix` contains both generally reusable services
  and Chapel hardware policy (OpenRGB motherboard, NVIDIA power limit,
  Bluetooth/I2C). These must be separated by ownership, not duplicated.
* `modules/users/sree-system.nix` has an empty personal home registration;
  personal HM content is currently spread through generic feature files.

### Cleanup opportunities

* The current schema uses `retr0astic.aliases`; the requested final API is
  `retr0astic.configurationAliases`. Rename the option and generator use in a
  compatibility-preserving phase, with `chapel` resolving the canonical
  configuration object exactly once.
* `modules/home/*.nix` are registrations despite their path. Keep the path
  temporarily for small diffs, then move registrations to feature/user-owned
  directories only when the ownership change is being made.
* `modules/features/packages.nix` is both the `nvf` package registration and a
  per-system package output. It must remain outside the recursive registration
  import only for `nvf-package.nix`; its package helper must not become a
  module import.

### Uncertain items requiring implementation-time verification

* Whether `inputs.silentSDDM.nixosModules.default` should remain host-owned or
  become a display-manager feature; inspect evaluated option ownership before
  moving it.
* Whether Noctalia’s package/module supports immutable `home.file` sources for
  the complete plugin tree. Prefer a flake path or `builtins.path`; retain an
  out-of-store link only if live editing is an explicit requirement.
* Whether Home Manager’s `imports` merge and duplicate feature selection make
  duplicate application observable. Add a duplicate-selection check rather
  than relying on option merge behavior.
* The exact final split of `modules/desktops/settings.nix` requires preserving
  generated Hyprland Lua syntax; inspect the evaluated text after each move.

## 3. File inventory and classification

All `.nix` files in the repository are classified below. Non-Nix Noctalia
assets are data owned by the shell/theme registration and are not recursive
flake-parts modules.

| Current file | Classification; responsibility and consumers | Final owner / proposed path | Action | Phase |
|---|---|---|---|---|
| `flake.nix` | Flake entry point; inputs and `mkFlake` import; consumes `modules/default.nix` | Same | Retain | 0 |
| `modules/default.nix` | Recursively imported top-level module; discovers registrations; consumed by `flake.nix` | `modules/default.nix` with explicit exclusion rules | Convert/retain | 7 |
| `modules/schema.nix` | Recursively imported top-level module; typed registries/options; consumed by all registrations and generator | `modules/schema.nix` | Convert; add `configurationAliases` | 1/7 |
| `modules/configurations.nix` | Recursively imported top-level module; resolver/composer/output generator | `modules/configurations.nix` | Convert | 1/7 |
| `modules/checks.nix` | Recursively imported top-level module; flake checks; consumes registry names | `modules/checks.nix` | Convert | 1/8 |
| `modules/devshells.nix` | Recursively imported top-level module; per-system dev shell | Same | Retain | 7 |
| `modules/hosts/chapel.nix` | Recursively imported registration; Chapel host and canonical configuration/alias | `modules/hosts/chapel.nix` plus configuration registration | Split/convert | 4/7 |
| `modules/users/sree-system.nix` | Recursively imported user registration; system account and empty home | `modules/users/sree.nix` and private `_sree/home.module.nix` | Convert/split | 2 |
| `modules/desktops/system.nix` | Recursively imported Hyprland system registration; package, portal, UWSM | `modules/desktops/hyprland.nix` | Retain/rename | 3/7 |
| `modules/desktops/session.nix` | Recursively imported Hyprland HM registration; session, hypridle, startup | `modules/desktops/hyprland/core.nix` plus user/integration owners | Split | 3 |
| `modules/desktops/settings.nix` | Recursively imported Hyprland HM registration; compositor defaults plus monitor/GPU/Noctalia | `modules/desktops/hyprland/core.nix`, hardware feature, integration | Split | 3/4 |
| `modules/desktops/animations.nix` | Recursively imported Hyprland HM registration; animations/gestures | `modules/desktops/hyprland/animations.nix` | Move/retain | 7 |
| `modules/desktops/bindings.nix` | Recursively imported Hyprland HM registration; compositor bindings plus Noctalia IPC and personal apps | `hyprland/bindings.nix`, integration, user/workflow feature | Split | 3 |
| `modules/desktops/rules.nix` | Recursively imported Hyprland HM registration; game rules, personal app rules, Noctalia layers | `hyprland/rules.nix`, gaming/user/integration owners | Split | 3/4 |
| `modules/integrations/hyprland-noctalia.nix` | Recursively imported integration registration; currently empty compatibility record | Same, with home/system pair policy | Convert | 3 |
| `modules/shells/noctalia-shell.nix` | Recursively imported shell registration; Noctalia HM module/service | `modules/shells/noctalia.nix` | Rename/retain | 5/7 |
| `modules/themes/noctalia-theme.nix` | Recursively imported theme registration; Noctalia files and Kitty theme include | `modules/themes/noctalia.nix` plus immutable asset helper | Convert | 5 |
| `modules/features/core.nix` | Recursively imported system feature; boot/network/Nix/common packages | `modules/features/core.nix` | Retain; split only if ownership evidence requires | 6 |
| `modules/features/fonts.nix` | Recursively imported system feature; fonts and fontconfig input | `modules/features/fonts.nix` | Retain | 6 |
| `modules/features/gaming.nix` | Recursively imported system feature; Steam/gamescope/gamemode/Heroic | `modules/features/gaming.nix` plus optional HM side | Convert; add home only if needed | 6 |
| `modules/features/graphics.nix` | Recursively imported system feature; graphics/NVIDIA driver | `modules/features/graphics.nix`, `features/hardware/nvidia.nix` | Split/convert | 4/6 |
| `modules/features/packages.nix` | Recursively imported registration; `retr0astic.nvf` and per-system `packages.nvf` | `modules/packages/nvf.nix` registration | Move/convert | 7 |
| `modules/features/nvf-package.nix` | Package expression/helper; NVF module list; consumed only by `packages.nix` | `modules/packages/nvf-package.nix` private helper | Move/retain excluded | 7 |
| `modules/features/services.nix` | Recursively imported system feature; services plus hardware-specific daemons | `features/services.nix`, `features/hardware/openrgb.nix`, `features/graphics/nvidia.nix` | Split | 4/6 |
| `modules/features/starship.nix` | Recursively imported HM feature; Starship and Noctalia palette activation | `features/starship.nix` plus integration hook | Split/convert | 3/6 |
| `modules/features/zen.nix` | Recursively imported system feature; wrapped Zen Browser | `features/zen.nix` | Retain | 6 |
| `modules/features/starship.toml` | Not Nix; Starship data consumed by `features/starship.nix` | Same immutable flake asset | Retain | 5/6 |
| `modules/home/appearance.nix` | Recursively imported HM feature registration; GTK/Qt/cursor | `features/appearance.nix` | Move/convert | 6 |
| `modules/home/packages.nix` | Recursively imported HM feature registration; packages plus Sree identity/state | `users/sree/home.module.nix` and `features/packages-home.nix` | Split | 2/6 |
| `modules/home/programs.nix` | Recursively imported HM feature registration; Spicetify/Zathura | `features/programs.nix`, user profile if personal | Split/convert | 2/6 |
| `modules/home/services.nix` | Recursively imported HM feature registration; OpenRGB user service | `features/services-home.nix` or user workflow | Move/convert | 2/6 |
| `modules/home/shell.nix` | Recursively imported HM feature registration; Fish aliases and shell tools | `features/shell.nix` plus `users/sree/home.module.nix` | Split | 2 |
| `modules/home/terminals.nix` | Recursively imported HM feature registration; Kitty/WezTerm/Ghostty | `features/terminals.nix` | Move/convert | 6 |
| `modules/home/xdg.nix` | Recursively imported HM feature registration; XDG dirs from HM home path | `features/xdg.nix` | Move/convert | 6 |
| `hosts/chapel/default.nix` | Private NixOS helper; boot, hostname, session, common host packages; imported by Chapel registration | `hosts/chapel/host.module.nix` or inline host registration | Retain as private helper after session removal | 4/7 |
| `hosts/chapel/mounts.nix` | Private NixOS helper; `/mnt` mounts; imported by host default | `hosts/chapel/storage.module.nix` | Rename/retain private | 4/7 |
| `hosts/chapel/hardware-configuration.nix` | Generated hardware configuration; imported by host default | `hosts/chapel/hardware-configuration.nix` | Retain generated exception | 4/7 |

No file is currently classified as obsolete, stale duplicate, or obsolete
aggregator based solely on inspection. Phase 7 must prove that any removed
wrapper has no consumers before deletion. `modules/default.nix` is an
import-aggregator by design, not an obsolete aggregator.

## 4. Ownership map

| Responsibility | Current location | Single final authority |
|---|---|---|
| Chapel hostname/architecture | `modules/hosts/chapel.nix`, `hosts/chapel/default.nix` | `retr0astic.hosts.chapel` and private Chapel host module |
| Generated hardware | `hosts/chapel/hardware-configuration.nix` | Chapel hardware helper; generated file remains untouched |
| LUKS, bootloader, kernel | `hosts/chapel/default.nix` | Chapel host/hardware profile |
| Filesystems, mounts, storage | `hosts/chapel/mounts.nix`, generated file | Chapel storage helper; generated root mounts stay generated |
| Sree system account | `modules/users/sree-system.nix` | `retr0astic.users.sree.system` |
| Sree home directory/state | `modules/home/packages.nix` | `retr0astic.users.sree.home` |
| Personal aliases and checkout commands | `modules/home/shell.nix` | Sree profile; use `config.home.homeDirectory`/flake path policy |
| Shared shell tools | `modules/home/shell.nix` | selected `features.shell.home` |
| Hyprland system package/portal | `modules/desktops/system.nix` | `retr0astic.desktops.hyprland.system` |
| Hyprland compositor defaults, animations, input | desktop files | `retr0astic.desktops.hyprland.home` |
| Hypridle/session variables | `modules/desktops/session.nix` | base desktop if shell-neutral |
| Noctalia service/UI/launcher/panel | `modules/shells/noctalia-shell.nix` and current desktop settings | `retr0astic.shells.noctalia.home` |
| Noctalia theme/colors/config/plugins/assets | `modules/noctalia/*`, theme registration | `retr0astic.themes.noctalia.home` with immutable flake assets |
| Hyprland-Noctalia IPC, Lua theme apply, layer rules, launcher/menu bindings | scattered desktop files | `retr0astic.integrations.hyprland-noctalia.home` |
| Default display-manager session | Chapel host currently | selected desktop or desktop/display-manager integration; Chapel is neutral |
| Samsung identity/HDR | `modules/desktops/settings.nix` | Chapel monitor hardware profile |
| NVIDIA driver and compositor env | graphics feature and desktop settings | Chapel NVIDIA hardware feature; only generic graphics stays reusable |
| Gaming packages/services/rules | gaming feature and desktop rules | `features.gaming` (system/home as needed) |
| Services/audio | `features/services.nix` | split reusable services/audio from Chapel hardware daemons |
| Fonts | `features/fonts.nix` | `features.fonts` |
| Application startup | Hyprland session | Sree workflow feature/profile; shell startup only for shell-owned process |
| Personal window rules/workspaces | desktop rules/bindings | Sree profile or named workflow feature |
| Shared packages | core/packages features | owning feature; avoid a catch-all personal package list |
| NVF | `features/packages.nix`, `nvf-package.nix` | `modules/packages/nvf.nix` and private helper |
| Starship | `features/starship.nix`, TOML | Starship feature; Noctalia palette hook only in integration |
| Spicetify | `home/programs.nix` | user-selected programs feature, or Sree profile if personal |
| Noctalia plugins | `modules/noctalia/plugins/*` and JSON/TOML | Noctalia shell/theme asset set; never Hyprland |

The implementation must choose one final owner per row before moving the
setting. A temporary compatibility import is allowed only within one phase and
must be removed before its checkpoint.

## 5. Target architecture

### Proposed tree

```text
flake.nix
modules/
  default.nix                 # recursive importer with private/data exclusions
  schema.nix                  # typed retr0astic registries
  configurations.nix          # generic resolver/composer/output generator
  checks.nix
  devshells.nix
  hosts/chapel.nix             # host and canonical variant registration
  users/sree.nix               # system registration and user composition
  desktops/hyprland.nix        # system registration
  desktops/hyprland/           # private helpers, excluded from recursive import
  shells/noctalia.nix
  themes/noctalia.nix
  integrations/hyprland-noctalia.nix
  features/{core,graphics,gaming,audio,fonts,services,packages,programs,
            shell,terminals,xdg,zen,starship,appearance}.nix
  packages/nvf.nix
  packages/_nvf/package.nix    # excluded package expression
hosts/chapel/
  host.module.nix              # private physical host helper
  storage.module.nix           # private mounts helper
  hardware-configuration.nix  # generated exception
modules/noctalia/              # data/assets only, never imported as Nix modules
```

The exact directory names may be adjusted to minimize churn, but the ownership
and exclusion rules are mandatory. `modules/default.nix` must import only
registration `.nix` files. Private helpers use a reserved `_` directory or an
explicit path predicate; generated hardware and data are never discovered as
registrations. Package expressions are referenced by registration files and
are excluded from recursive module import.

### Schema and composition flow

Retain lazy string registries for `hosts`, `users`, `desktops`, `shells`,
`themes`, `features`, `integrations`, and `configurations`, all using
`deferredModule` where a module is stored. Use the final public alias registry
name `configurationAliases` (optionally accept `aliases` only as a temporary
deprecation bridge). Do not create name enums.

The generator should perform this sequence:

1. Resolve `spec.host`, `desktop`, `shell`, `theme`, and every feature/user
   string against their registry.
2. Resolve exactly `${desktop}-${shell}` in `integrations`, validate its
   identity, and reject missing/mismatched records.
3. Compose system modules: host, selected feature `.system` values, selected
   user `.system` values, desktop `.system`, Home Manager module, integration
   `.system`, and explicit extra modules.
4. For each `userName` independently, build
   `user.home` plus every selected feature’s `.home`, desktop `.home`, shell
   `.home`, theme `.home`, and integration `.home`; assign only that list to
   `home-manager.users.${userName}`. Shared modules are constructed once as
   values but inserted into each user’s list; personal modules are never
   collected globally.
5. Generate `flake.nixosConfigurations.<name>` and resolve each
   `configurationAliases.<alias>` to the already-generated canonical object.

Avoid cycles by keeping registries as declarations only, resolving them in one
direction in `configurations.nix`, and never making a feature discover or
resolve a configuration. Do not expose `inputs` via global `_module.args` or
`specialArgs` unless a concrete module requires it; pass flake inputs through
the flake-parts module argument and capture only the relevant input in the
registration.

## 6. Migration phases

The phases below are sequential and independently reviewable. Every phase has
an approval checkpoint. Approval of the overall plan never authorizes the next
phase automatically.

### Phase 0 — Establish baseline

Objective: record current behavior and identify evaluation blockers.

Expected files: none; baseline artifacts may be stored outside the repository.
Do not change implementation files or the plan except to record results.

Steps: capture status/diff; run the validation matrix commands that can run;
record registry names, output names, hostnames, selected users, system state
versions, and derivation paths; inspect generated/evaluated Home Manager user
lists. If a command fails, retain its exact error.

Commands: `git status --short`, `git diff`, `git diff --cached`,
`git diff --check`, `nix flake show`, registry/user/hostname evals, and no-link
builds. Current result: Nix commands failed because the sandbox could not
connect to `/nix/var/nix/daemon-socket/socket`; the first attempts also
reported a read-only `/home/sree/.cache/nix/fetcher-cache-v4.sqlite`.

Acceptance: baseline results and failures are recorded; worktree is unchanged.
Risk/recovery: no configuration risk; discard only external baseline files.
Reviewer checklist: verify no implementation diff and exact errors are present.

Checkpoint: Approve Phase 1 — Fix central composition correctness.

### Phase 1 — Fix central composition correctness — COMPLETE

Objective: make feature and user composition generic without moving ownership.

Expected files: `modules/configurations.nix`, `modules/checks.nix`, and, only
if required by the public API decision, `modules/schema.nix`.

Steps: replace the central feature-home list with a resolved list of each
selected feature record’s `.home`; construct a per-user `imports` list using
only that user’s `.home` plus the shared selected modules; preserve system
ordering; add checks with two synthetic selected users/features if possible,
or a pure composition helper check that proves each user list is distinct.
Rename `aliases` to `configurationAliases` only if schema compatibility is
included in this phase; otherwise schedule it for Phase 7.

Risks: duplicate modules, altered option ordering, and eager evaluation of
unselected deferred modules. Recovery: revert only these files to the baseline
copy; do not remove current hardcoded home modules until generic composition
evaluates.

Commands: `nix fmt`, `git diff --check`, `nix flake check`, output-name eval,
user-list eval, and both hostname/Hyprland enable evals. Expected result:
current Chapel output remains evaluable and every selected feature’s home side
is present automatically.

Acceptance: no hardcoded feature-home registry names remain in the generator;
user homes are isolated; current output names and behavior are preserved.
What must not change: host boot/storage, desktop settings, asset paths, or
state versions. Reviewer checks generator diff and proof of isolation.

Checkpoint: Approve Phase 2 — Establish user ownership.

Phase 1 completion record: implemented in `modules/configurations.nix`,
`modules/checks.nix`, `modules/schema.nix`, and `modules/hosts/chapel.nix`.
Selected features now contribute both system and Home Manager modules, each
selected user receives only its own personal Home Manager module plus shared
modules, duplicate selections are rejected, and the canonical Chapel feature
list preserves the existing Home Manager behavior. `nix flake check`, all
three targeted check derivations, required output/user/hostname/Hyprland
evaluations, alias/canonical derivation comparison, and `git diff --check`
passed. The pre-existing planning-document worktree change was preserved.
No activation, reboot, commit, or deployment was performed.

### Phase 2 — Establish user ownership

Objective: move identity and personal policy out of reusable modules.

Expected files: `modules/users/sree-system.nix`, `modules/home/packages.nix`,
`modules/home/shell.nix`, `modules/home/programs.nix`, `modules/desktops/
bindings.nix`, `modules/desktops/rules.nix`, and registration/configuration
files as needed.

Steps: keep account name/home in `users.sree.system` and move
`home.username`, `home.homeDirectory`, and `home.stateVersion` to
`users.sree.home`; split generic packages from personal packages; move Sree
aliases, Spotify/Vesktop bindings/startup, and personal app rules into the
Sree profile or a named workflow feature. Make XDG use HM’s configured home
directory. Replace `~/nixos` command assumptions with a profile-owned value or
document that the alias intentionally targets Sree’s checkout.

Risks: changing Home Manager identity can relocate files; personal startup may
be lost. Recovery: retain old profile modules until evaluated output comparison
passes; no activation. Commands: targeted HM options/user names, `nix flake
check`, both builds when available, and prohibited-path search. Acceptance:
shared features contain no Sree/home path; only Sree profile owns personal
policy; state versions unchanged.

What must not change: system account groups, boot, storage, or selected variant
names. Reviewer checks personal/shared boundary and user leakage.

Checkpoint: Approve Phase 3 — Decouple Hyprland and Noctalia.

Phase 2 completion record: implemented user ownership in `modules/users/
sree-system.nix`, moved Sree's Home Manager identity, personal applications,
Spicetify configuration, shell aliases, Hyprland startup, bindings, and window
rules into the Sree profile, and kept reusable packages, gaming tools, Zathura,
and generic shell/desktop behavior in shared features. The trusted-user policy
now keeps `root` in the core feature and adds `sree` from the Sree system
profile. XDG directories remain derived from Home Manager's configured home
directory. Validation was run without activation, reboot, commit, deployment,
or switch; the next phase remains pending explicit approval.

### Phase 3 — Decouple Hyprland and Noctalia

Objective: ensure base Hyprland has zero Noctalia-specific implementation.

Expected files: all `modules/desktops/{session,settings,bindings,rules}.nix`,
`modules/integrations/hyprland-noctalia.nix`, `modules/shells/noctalia-shell.nix`,
`modules/themes/noctalia-theme.nix`, and possibly `features/starship.nix`.

Move to base Hyprland: enable/package/UWSM/portal, generic compositor settings,
animations, input, generic hypridle, and shell-neutral variables/commands.
Move to Noctalia shell: Noctalia package/service/UI and shell-owned commands.
Move to the integration: `require("noctalia").apply_theme()`, `noctalia` startup,
`noctalia msg` IPC variables and launcher/toggle bindings, Noctalia layer
rules, and any Noctalia-specific Starship hook. Move Spotify/Vesktop startup
and rules to Sree/workflow from the desktop.

Validate `rg -n 'noctalia' modules/desktops` returns zero. Inspect generated
Lua, layer rules, panel behavior, and Hyprland package evaluation. Risks:
missing launcher/IPC or altered module merge order. Recovery: keep integration
changes additive until session text comparison passes. Commands: formatting,
diff check, flake check, targeted Lua/config evals, and both builds. Acceptance:
integration is the sole pair behavior authority and base Hyprland can be
selected with a future non-Noctalia shell without Noctalia references.

What must not change: generic Hyprland bindings, animations, HDR policy’s
eventual owner, or session state versions. Reviewer checks every grep match.

Checkpoint: Approve Phase 4 — Make Chapel desktop-neutral.

Phase 3 completion record: moved Noctalia Lua theme loading, startup, IPC/menu
variables and bindings, layer rules, and the Starship palette activation into
`retr0astic.integrations.hyprland-noctalia.home`. Base Hyprland now retains
generic settings and OpenRGB startup only; startup evaluation confirms the
ordering Noctalia, OpenRGB, then the Phase 2 Sree Spotify/Vesktop hook. The
Starship activation is conditional on `programs.starship.enable`. Base desktop
Noctalia references are absent. `nix flake check`, targeted generated Lua,
startup, binding, activation, parse, and diff checks passed without activation,
reboot, commit, deployment, or switch. The next phase remains pending explicit
approval.

### Phase 4 — Make Chapel desktop-neutral

Objective: remove desktop selection and machine policy from reusable desktop
modules.

Expected files: `hosts/chapel/default.nix`, `hosts/chapel/mounts.nix`,
`hosts/chapel/hardware-configuration.nix` only if import path changes,
`modules/hosts/chapel.nix`, `modules/features/graphics.nix`,
`modules/features/services.nix`, and extracted host/hardware modules.

Steps: remove `defaultSession = "hyprland"` from Chapel; add session ownership
to the selected desktop or an explicit desktop/display-manager integration.
Keep SDDM enablement host/service-owned but make session selection derive from
the desktop record. Move Samsung identity and HDR values to Chapel monitor
hardware; move NVIDIA driver, environment, and power limit to the Chapel GPU
feature; separate OpenRGB motherboard and I2C policy from reusable services.
Keep LUKS, kernel, EFI, mounts, hostname, and generated hardware in Chapel.

Do not rewrite generated hardware. Verify the final import is private and the
generated file remains an exception. Risks are boot/login/display failure and
NVIDIA mismatch. Recovery: preserve the current host helper and known-working
Hyprland session as an explicit temporary fallback until evaluation/builds
pass; no switch or reboot. Commands include all host/DM/GPU evals, flake check,
both builds, and `rg 'defaultSession.*hyprland'`. Acceptance: Chapel contains no
desktop choice while the canonical output still selects Hyprland and SDDM
starts it through selected composition.

Reviewer checks boot/storage diff, GPU ownership, session option, and generated
hardware integrity.

Checkpoint: Approve Phase 5 — Normalize themes and assets.

Phase 4 completion record: Chapel no longer selects a desktop; Hyprland owns
`defaultSession`. Chapel-specific NVIDIA, monitor/HDR, and OpenRGB features now
own the machine policy, while generic graphics, services, and Hyprland remain
desktop-neutral. I2C and the NVIDIA environment variables are preserved under
the Chapel feature, and the obsolete `services-home` feature was removed.
Generated hardware, mounts, boot, and storage remain unchanged. Validation
included `git diff --check`, path-based `nix flake check`, targeted display
manager, GPU/OpenRGB, Hyprland environment, and I2C evaluations, both no-link
Chapel toplevel builds, and the generated hardware SHA-256 hash. No activation,
reboot, commit, deployment, or switch was performed. Runtime graphics/login
behavior remains an unverified residual gap.

### Phase 5 — Normalize themes and assets

Objective: make Noctalia assets reproducible and theme selection user-neutral.

Expected files: `modules/themes/noctalia-theme.nix`, all files under
`modules/noctalia/`, `modules/shells/noctalia-shell.nix`, and Starship/theme
consumers only where required.

Steps: decide immutable source as the default; use a flake-owned source path or
`builtins.path` for `.config/noctalia` and preserve plugin manifests/settings
as synchronized data. If live editing is required, expose it as an explicit
Sree-only opt-in instead of hiding it in the reusable theme. Remove
`/home/sree/nixos` from the theme. Keep Kitty include and Noctalia palette
behavior in their owning theme/integration boundaries.

Risks: store paths may prevent live edits or alter generated config timing.
Recovery: retain the old link behind a temporary profile option until copied
assets and evaluated paths match; do not activate. Commands: path searches,
flake check, config-file eval, and plugin manifest consistency checks.
Acceptance: reusable theme has no username/repository path; all required
plugins/QML/scripts/assets are in the immutable closure or explicitly owned
live-edit path.

Reviewer checks no missing asset and no accidental generated-log files.

Checkpoint: Approve Phase 6 — Normalize remaining feature ownership.

### Phase 6 — Normalize remaining feature ownership

Objective: make services, packages, audio, fonts, gaming, NVF, Starship,
Spicetify, terminals, XDG, and applications independently selectable.

Expected files: current `modules/features/*.nix`, `modules/home/*.nix`, and
the new owning paths from the inventory.

Steps: split service/audio/hardware policy; decide whether each feature exposes
`system`, `home`, or both; move Spicetify and personal applications to the
appropriate selected profile; retain NVF as a package output without recursive
module evaluation; ensure adding a new feature requires only one registration.
Make Starship’s Noctalia palette hook integration-aware without making the
base feature depend on a shell.

Risks: package closure growth and option conflicts. Recovery: phase-local
revert, preserving registrations and state versions. Commands: feature
registry eval, flake check, no-link builds, package/NVF output evals, and
targeted option checks. Acceptance: every responsibility has one owner, both
feature sides compose automatically, and no generator feature list exists.

Reviewer checks inputs, package helper exclusion, feature records, and no
duplicate services.

Checkpoint: Approve Phase 7 — Strict dendritic cleanup.

### Phase 7 — Strict dendritic cleanup

Objective: finish naming, tree, and import invariants after behavior is stable.

Expected files: `modules/default.nix`, `modules/schema.nix`,
`modules/configurations.nix`, all moved registration paths, `modules/hosts`,
`hosts/chapel`, README/docs references.

Steps: convert `aliases` to `configurationAliases` (or remove any temporary
bridge); ensure every recursively discovered `.nix` under `modules/` is a
flake-parts registration; exclude `_` private helpers, `nvf-package.nix`, and
non-module data; move or inline private host helpers; remove only wrappers
proven obsolete by `rg` consumers. Keep generated hardware. Update README
examples to output `. #chapel` and `. #chapel-hyprland-noctalia` accurately.

Risks: accidental recursive import, stale relative paths, alias divergence.
Recovery: restore imports/path names within the phase and compare output names.
Commands: tree/inventory scans, prohibited legacy searches, `nix fmt`, diff
check, flake show/check, and alias derivation comparison. Acceptance: no
obsolete implementation tree, justified lower-level exceptions, and no
ordinary module imported through another module.

Reviewer checks every inventory row and import predicate.

Checkpoint: Approve Phase 8 — Final validation and review.

### Phase 8 — Final validation and review

Objective: establish objective completion and obtain Terra review.

Expected files: none unless review finds a focused correction.

Run the complete matrix, both no-link builds, derivation-path comparison,
alias/canonical option comparisons, prohibited-coupling searches, and runtime
behavior checklist. Ask Terra to review the final diff and resolve every
medium/high finding before completion.

Acceptance: all completion criteria in section 12 pass, Terra has no unresolved
medium/high findings, and the final worktree contains only intended changes.
No activation, switch, deployment, or reboot is part of this phase.

Checkpoint: Approve completion of the final architecture migration.

## 7. Detailed phase protocol

Every implementation agent must implement exactly one phase, run that phase’s
validation, inspect the diff, and stop. Its report must list files changed,
settings moved, commands/results, failures, deviations, and remaining risks.
The next phase begins only after an explicit user approval message. Do not use
Git commits as checkpoints unless separately requested.

## 8. Validation matrix

| Requirement | Validation |
|---|---|
| Formatting and whitespace | `nix fmt`; `git diff --check` |
| Outputs exist | `nix flake show`; `nix eval --json .#nixosConfigurations --apply builtins.attrNames` |
| Host identity | `nix eval .#nixosConfigurations.chapel.config.networking.hostName`; same for `chapel-hyprland-noctalia` |
| Desktop selection | `nix eval .#nixosConfigurations.chapel.config.programs.hyprland.enable`; same canonical output |
| HM users | JSON eval of both `config.home-manager.users` attr names |
| Evaluation/checks | `nix flake check` |
| Closures | `nix build .#nixosConfigurations.chapel.config.system.build.toplevel --no-link`; same canonical output |
| Reproducible derivations | `nix eval --raw` each `system.build.toplevel.drvPath`; aliases must equal canonical |
| No Hyprland/Noctalia coupling | `rg -n 'noctalia' modules/desktops` (zero; document legitimate data matches elsewhere) |
| Neutral Chapel | `rg -n 'defaultSession.*hyprland' modules/hosts hosts` (zero) |
| No reusable Sree path | `rg -n '/home/sree|~/nixos|/home/[^/]+/nixos' modules` (zero except explicitly documented user-owned files) |
| Legacy imports | `rg -n 'modules/nixos|modules/home' .` (classify legitimate docs/paths) |
| Input exposure | `rg -n 'specialArgs|extraSpecialArgs|_module\.args' --glob '*.nix'` and review every match |
| Tree/import contract | inventory `.nix` files and verify `modules/default.nix` exclusions |
| Runtime-sensitive behavior | evaluate options and compare baseline; no live switch required |

`nix fmt` may rewrite files and must therefore be run only by the authorized
implementation phase, followed by diff review. A successful evaluation does
not prove a working display session; inspect generated Hyprland/Noctalia config
and preserve a known-working fallback until final review.

## 9. Behaviour-preservation checklist

After every relevant phase, check bootloader and encrypted boot; kernel;
filesystems/mounts; generated hardware; NVIDIA; display manager; Hyprland;
Noctalia; HDR/monitor behavior; gaming; audio; networking; services; packages;
NVF; Starship; terminals; XDG; fonts; Spicetify; Noctalia plugins; and system
and Home Manager state versions. Compare evaluated values before/after moves,
not only whether the closure builds. Never use a live switch as validation.

## 10. Risk register

| Risk | Likelihood / impact | Mitigation |
|---|---|---|
| Nix option evaluation cycle | Medium / High | One-way resolver; deferred registries; no feature-to-configuration lookups; flake check each phase |
| Duplicate module application/order change | Medium / Medium | Preserve ordering; add composition tests; inspect option definitions and generated Lua |
| Home Manager user leakage | High / High | Per-user list construction; synthetic isolation check; inspect user imports |
| Missing input capture | Medium / Medium | Keep input use at registration boundary; check `inputs` references |
| Lost settings during moves | Medium / High | Inventory/ownership map; baseline option captures; focused diff review |
| Broken desktop-shell integration | Medium / High | Integration identity validation and pair-specific checks; inspect IPC/layers |
| Display-manager session failure | Medium / High | Desktop-owned session option; evaluate SDDM/session; retain fallback; no reboot |
| Mutable-to-immutable asset change | Medium / Medium | Explicit asset decision; verify closure contents and live-edit requirement |
| Staged/unstaged conflict | Low / High | status/diff before and after each phase; never reset or overwrite unrelated work |
| Generated hardware relocation damage | Low / High | Do not rewrite; preserve import and compare hardware options |
| Alias divergence | Medium / Medium | Compare alias/canonical derivation paths and key options |
| Build passes, runtime fails | Medium / High | behavior checklist, generated config inspection, Terra review; no claim of runtime proof |

## 11. Decision log

1. Compatibility is owned only by `retr0astic.integrations`; no desktop
   whitelist or parallel compatibility records.
2. Every selected feature contributes `.system` and `.home` automatically;
   absent sides use the schema default.
3. Home Manager personal modules are selected per user; shared modules are
   applied to each selected user but never substitute for personal modules.
4. Private helpers remain lower-level only when they are not registrations;
   generated hardware remains a documented exception.
5. Package expressions, especially NVF, are excluded from recursive module
   evaluation and exposed through package registrations/outputs.
6. Samsung/HDR/NVIDIA/OpenRGB policy belongs to Chapel hardware/host features,
   not generic Hyprland or generic services.
7. Default session selection belongs to selected desktop/session composition;
   Chapel remains physically specific but desktop-neutral.
8. Immutable flake-owned Noctalia assets are recommended. A mutable link is
   acceptable only as an explicit user-profile workflow.
9. `configurationAliases` is the recommended final schema name. Temporary
   `aliases` compatibility is preferable to a flag day only if it does not
   create two authorities; remove it before Phase 8.

Unresolved decisions: exact host/hardware file names, whether SDDM integration
is a separate registration, and whether live Noctalia editing is required.
Recommendation: keep SDDM enablement with host services, put session selection
with desktop composition, and choose immutable assets unless the operator
explicitly requests live editing.

## 12. Completion criteria

The migration is complete only when:

* selected users receive isolated personal Home Manager modules;
* selected features contribute both system and home modules automatically;
* Hyprland contains no Noctalia-specific implementation;
* Chapel does not hardcode Hyprland;
* reusable modules do not hardcode Sree or `/home/sree/nixos`;
* adding a feature requires no generator edit;
* adding a desktop or shell requires no schema or host edit;
* integration records are the sole compatibility authority;
* no obsolete implementation tree remains;
* all required evaluations and checks pass;
* both Chapel system closures build;
* alias and canonical outputs resolve to the same derivation;
* Terra reports no unresolved medium- or high-severity findings;
* no activation, deployment, reboot, commit, or push has been performed as
  part of planning.
