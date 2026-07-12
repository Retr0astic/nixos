# Retr0astic's NixOS Flake

This is a flake-parts NixOS configuration for Chapel. The flake has one
recursive module tree: every `.nix` file under `flake/` is a flake-parts
module. Raw NixOS, Home Manager, and NVF functions remain values assigned by
those modules; they are never recursively imported as flake-parts modules.

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

Feature files self-register their modules. A host variant explicitly selects
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
- Add a desktop registration in `flake/desktops.nix` with `system`, `home`,
  and `compatibleShells`, then add pair-specific integration data.
- Add a graphical shell in `flake/shells.nix`; shells are independent of
  desktops and may provide integrations.
- Add a theme in `flake/themes.nix`; keep styling separate from shell
  services and launcher/panel behavior.
- Add a user registration under `flake/users/` with independent system and
  Home Manager modules.
- Keep reusable raw modules and assets outside `flake/`; only
  flake-parts modules belong inside the recursive boundary.
- Niri or AGS support should add registry declarations and configuration data
  (plus pair integrations); it must not require schema or generator changes.

## Repository map

```text
flake.nix                 flake-parts entrypoint
flake/                    recursive registrations, schema, and variants
hosts/chapel/             Chapel leaf and generated hardware exception
modules/nixos/             reusable NixOS modules
modules/home/              reusable Home Manager modules
modules/noctalia/          Noctalia settings and plugins
configuration.nix          compatibility import for Chapel
```
