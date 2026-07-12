# Dendritic flake-parts migration

The flake uses `lib/treeimport.nix` to discover every Nix file under `flake/`.
Those discovered files are flake-parts modules only. Typed registrations live
under `flake/modules/` and are consumed through `config.flake`.

## Registry conventions

- `flake.modules.nixos.<name>` contains reusable NixOS modules.
- `flake.modules.homeManager.<name>` contains reusable Home Manager modules.
- Desktop and theme implementations are typed entries such as
  `flake.modules.nixos.desktop-hyprland`,
  `flake.modules.homeManager.desktop-hyprland`, and
  `flake.modules.homeManager.theme-noctalia`.
- `flake.modules.nixos.<host>` owns reusable host imports; host leaf files
  retain hardware, boot, storage, identity, and other machine-specific state.

`flake/modules/desktops.nix` and `themes.nix` contain typed registrations only.
`flake/hosts.nix` assembles and exports the public selection metadata
`flake.lib.desktops` and `flake.lib.themes` from those registrations, defines
`mkHost`, and exports `flake.lib.mkHost` in the same `flake.lib` definition.
It also owns host outputs and aliases.

Raw NixOS and Home Manager leaf modules remain under `modules/` and are not
discovered as flake-parts modules. Noctalia assets remain unchanged.

## Verification

Run `git diff --check`, evaluate the registry and Chapel outputs, then run
`nix flake check`. When practical, build
`.#nixosConfigurations.chapel.config.system.build.toplevel`. Do not activate
or deploy the result as part of this migration.
