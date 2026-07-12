# Retr0astic's NixOS Flake

This is a dendritic flake-parts NixOS configuration. The recursive importer
discovers registration modules under `flake/`; underscore-prefixed directories
are private implementation trees and are imported only by their owning
registration. Generated hardware and physical host leaves under `hosts/` are
also deliberate exceptions.

## Architecture

`flake.nix` only declares inputs, systems, and the recursive import. The
declared `retr0astic` schema contains typed, lazy registries for:

- open-string registries for `hosts`, `configurations`, `aliases`, `desktops`,
  `shells`, `themes`, `users`, and top-level `features`;
- pair-specific desktop/shell `integrations` with explicit compatibility;
- generated `nixosConfigurations`.

The public outputs also include `packages.x86_64-linux.nvf` and
`devShells.x86_64-linux.default`; both are registered as flake-parts modules
under `flake/`.

Feature files self-register deferred modules. A host variant explicitly selects
its hostname, desktop, graphical shell, theme, and users. Home Manager remains
a NixOS module and composes the base user configuration with those selections.
The desktop is the compositor/session implementation (currently Hyprland);
the graphical shell is a separate selectable module (currently Noctalia), and
the theme is independently selectable. This keeps variants explicit without
hardcoding Hyprland or Noctalia in the host leaf.

Generated hardware configuration and `flake.lock` are deliberate exceptions:
the former is host-generated and the latter is input state. Noctalia assets
and plugin files remain under `modules/noctalia` and are linked by its Home
Manager integration.

## Variants

The available Chapel variants are:

```text
chapel
chapel-hyprland-noctalia
```

Both currently select Chapel + Hyprland + the Noctalia graphical shell and
theme. Physical hosts live in `retr0astic.hosts`; variants live in
`retr0astic.configurations`; aliases point at variants. To add a variant,
register its desktop, shell, theme, pair integration, or feature under
`flake/`, then add explicit data to `flake/hosts/chapel.nix`. Keep host-only boot,
LUKS, filesystem, kernel, and generated hardware settings in `hosts/chapel`.

## Commands

```bash
nix flake show
nix flake check
nix eval .#nixosConfigurations.chapel.config.networking.hostName
nix eval .#nixosConfigurations.chapel-hyprland-noctalia.config.networking.hostName
nix eval .#packages.x86_64-linux.nvf.drvPath
nix eval .#devShells.x86_64-linux.default.drvPath
nix eval --json .#nixosConfigurations --apply builtins.attrNames
nix build .#nixosConfigurations.chapel.config.system.build.toplevel --no-link
nix build .#nixosConfigurations.chapel-hyprland-noctalia.config.system.build.toplevel --no-link
sudo nixos-rebuild test --flake .#chapel
```

Use `nixos-rebuild test` before a persistent switch. A switch, reboot, commit,
push, and deployment are intentionally outside this migration.

## Extending the configuration

- Add a host or variant in `flake/hosts/`; select `hostname`, `desktop`,
  `shell`, `theme`, and `users`. The host leaf stays in `hosts/<name>/`.
- Add a new physical host by registering its hostname, system, and module in
  `flake/hosts/<name>.nix`; keep boot, storage, hardware, and identity in
  `hosts/<name>/`.
- Add a desktop registration in `flake/desktops.nix` with `system` and `home`,
  then add one explicit pair record in `flake/desktops.nix` under
  `retr0astic.integrations` for every supported shell.
- Add a graphical shell in `flake/shells.nix`; shells are independent of
  desktops. A new desktop or shell changes only its registration and pair
  records, not this schema, the generator, or a central import list.
- Add a desktop-shell pairing by adding an integration record with matching
  `desktop` and `shell`; its `system` and `home` modules may be `{}`.
- Add a theme in `flake/themes.nix`; keep styling separate from shell
  services and launcher/panel behavior.
- Add a user registration under `flake/users/` with independent system and
  Home Manager modules; private user helpers belong under `flake/users/_<name>/`.
- Add a reusable feature as one coherent registration under `flake/features/`.
  Keep sizeable private implementation leaves under an underscore directory
  owned by that feature and capture only the external inputs it needs.
- Keep private implementation leaves in underscore-prefixed directories under
  `flake/`; only registration modules are discovered by flake-parts.

The integration registry is the authoritative compatibility whitelist (Policy
A). Unsupported pairs fail with the selected names, available pairs, and the
required corrective action. Every declaration under `retr0astic.configurations`
automatically produces the same-named `flake.nixosConfigurations` output.
`retr0astic.aliases` resolves to an existing configuration declaration; the
public `chapel` alias therefore reuses `chapel-hyprland-noctalia`.

Home Manager is composed in `flake/configurations.nix` from the selected user,
common home registrations, desktop, shell, theme, and pair integration. Inputs
such as Noctalia, Spicetify, Hyprland, and SilentSDDM are captured by the
registration that owns them rather than exposed to every module.

## Repository map

```text
flake.nix                 flake-parts entrypoint
flake/                    recursive registrations, schema, and variants
hosts/chapel/             Chapel leaf and generated hardware exception
flake/home/                Home Manager registrations and private modules
flake/desktops/            desktop registrations and private helpers
flake/features/            reusable feature registrations and private helpers
flake/users/               reusable user registrations and private helpers
modules/noctalia/          Noctalia settings and plugins
hosts/chapel/hardware-configuration.nix  generated hardware exception
```
