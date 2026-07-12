# Dendritic architecture

The flake-parts entrypoint imports the registration tree under `flake/` with
`lib/treeimport.nix`. Every discovered `.nix` file is a flake-parts module.
Directories beginning with `_` are private implementation trees: their files
are imported explicitly by one owning registration and are never discovered
independently. Generated hardware and physical host leaves under `hosts/` are
kept outside that boundary.

The typed `retr0astic` schema uses lazy registries and `types.deferredModule`.
Hosts are physical machines; configurations are rebuildable compositions of a
host, desktop, graphical shell, theme, users, features, and a desktop-shell
integration. Names are strings so adding a registry entry does not require
schema or generator edits. `flake/configurations.nix` resolves and validates
those names only for selected outputs, preserving laziness and avoiding
cross-registry circular dependencies.

The integration registry is the single compatibility whitelist. Each supported
desktop-shell pair has a record, even when its `system` and `home` modules are
empty. Unsupported pairs report the configuration selections, supported pairs,
and how to add the required integration.

`retr0astic.configurations` automatically generates
`flake.nixosConfigurations`; aliases resolve to existing declarations. The
`chapel` alias points to `chapel-hyprland-noctalia`.

Home Manager is composed from the selected user, common home registrations,
desktop, shell, theme, and pair integration. External inputs are captured by
their owning feature or registration. To add a desktop, shell, theme, user, or
feature, add a registration and, where needed, a pair record; do not edit the
schema, generator, or a central import list.

Validate with `git diff --check`, `nix flake show`, `nix flake check`, targeted
`nix eval` commands, and no-link builds of both Chapel configurations. Do not
activate or deploy as part of the migration.
