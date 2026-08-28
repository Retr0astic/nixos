# TODO

Open work, highest consequence first. Each item states the problem, the fix,
and the check that proves it is done.

## 1. Add an offline recipient to `.sops.yaml`

**Status:** agreed, deferred. Lower priority than first assessed — chapel's
SSH host key is backed up, and bigrig's key is already a recipient
(`08f0749`, `6d47bef`).

**Problem:** both recipients are machine identities derived from
`/etc/ssh/ssh_host_ed25519_key`. Confirm bigrig's key is also backed up. An
SSH host key also grants more than sops decryption; a dedicated age key does
one job.

**Fix:**
1. `age-keygen -o ~/age-recovery.txt`
2. Add the public key to `.sops.yaml` under `keys` and to the
   `secrets/secrets.yaml` key group.
3. `sops updatekeys secrets/secrets.yaml`
4. Store the private half off both machines (Bitwarden).

**Check:** `sops -d secrets/secrets.yaml` succeeds with only
`SOPS_AGE_KEY_FILE` set and no host key available.

## 2. CI never builds bigrig

**Status:** done. `.github/workflows/flake.yml` carries a `bigrig` paths
filter and adds `bigrig` to the build matrix.

**Problem:** the build matrix is `["chapel"]` or
`["chapel","caelestia-hyprland"]`. bigrig appears only in the name
verification step. `nix flake check` evaluates the config but does not build
its toplevel, so eval errors are caught and build errors are not. bigrig is
not yet installed, so CI is its only test.

**Fix:** add a `bigrig` paths filter mirroring the caelestia one, and add
bigrig to the matrix when its files, the shared aspects, or the flake inputs
change.

**Check:** a PR touching `modules/hosts/bigrig/**` runs a bigrig build job.

## 3. Loosen the configuration-name check

**Problem:** `test "$actual" = "$expected"` asserts exact set equality
against seven hardcoded names in sorted order. Adding a host breaks CI on an
unrelated PR, and removing a redundant alias (item 6) requires editing this
string in the same commit.

**Fix:** assert that each name used in a real `nixos-rebuild` invocation is
present. Do not assert the set contains nothing else.

**Check:** adding a throwaway `nixosConfigurations` entry does not fail CI.

## 4. Hoist the duplicated Hyprland Lua helpers

**Problem:** `mkLuaInline`, `luaBind`, `key`, and `exec` are defined
identically in three files:

- `modules/desktops/hyprland/bindings.nix`
- `modules/shells/noctalia.nix`
- `modules/users/sree/hyprland.nix`

`modules/shells/caelestia.nix` carries its own `globalBind` variant. A change
to `key` currently needs three edits.

**Fix:** define them once as a flake-parts option — `flake.lib.hypr` — and
read `config.flake.lib.hypr` in each consumer. This is the dendritic answer
to cross-file sharing: flake-parts options, never `specialArgs`.

**Check:** `grep -c 'key = suffix:' -r modules` returns 1.

## 5. Move nvf to home packages

**Problem:** `modules/packages/nvf.nix` installs neovim into
`environment.systemPackages`. The package placement rule in `CLAUDE.md` puts
it in `home.packages`; `vim` in `core` already covers root and recovery.

**Fix:** one line. Keep the `perSystem.packages.nvf` output as is.

## 6. Remove the redundant `nixosConfigurations` aliases

**Problem:** `chapel`, `noctalia`, `noctalia-hyprland`, and
`chapel-hyprland-noctalia` all resolve to the same build. Four names, one
system, tab-completion noise.

**Fix:** keep `chapel` and `chapel-caelestia`. Do item 3 first, or CI fails.

## 7. Replace `with m;` in the host base lists

**Problem:** `modules/hosts/chapel.nix` uses `base = with m; [...]`, and its
own comment records that a bare name silently resolves to a `let` binding
instead of the intended aspect. `with` is the only thing making that
possible.

**Fix:** `builtins.attrValues (lib.getAttrs [ "core" "gaming" ... ] m)`, or
write `m.` on every entry.

## 8. Collapse the two host trees

**Problem:** chapel config lives in both `hosts/chapel/` and
`modules/hosts/chapel/`. Only `hardware-configuration.nix` genuinely has to
sit outside `modules/`, because `import-tree` would otherwise evaluate it as
a flake-parts module.

**Fix:** move `storage.module.nix`, `disko.module.nix`, and
`containers.module.nix` into `modules/hosts/<host>/`, registering into
`flake.modules.nixos.<host>` the way `nvidia.nix` already does. Leave
`hosts/` holding generated hardware files only.

## 9. Set `nixpkgs.hostPlatform` in `core`

**Problem:** `system = "x86_64-linux"` is passed to `nixosSystem` in both
host files.

**Fix:** set `nixpkgs.hostPlatform` in `core` and drop the argument. Makes a
future aarch64 host a one-line change.

## 10. Folder restructure

See `docs/folder-plan.md`. Deferred until items 2 through 9 land, because it
touches nearly every path in the repo and would bury them in move noise.

## 11. Fix stale references

- `hosts/bigrig/containers.module.nix` points at `modules/features/server.nix`.
  The file moved to `modules/hosts/bigrig/server.nix` in `c59f86c`.
- `README.md` says the repo targets one machine (bigrig exists), says CI
  builds both graphical variants (it builds chapel plus caelestia
  conditionally), and lists two outputs while the flake declares seven.
- `README.md` Highlights predates the package refactor.

## 12. Verify `bubblewrap`

Carried into `modules/features/core.nix` from the old `system-packages.nix`
with no recorded reason. Remove it and confirm nothing regresses.
