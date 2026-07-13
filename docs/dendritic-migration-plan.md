# Dendritic architecture

`flake.nix` is the flake-parts entrypoint. `modules/default.nix` recursively
imports every `.nix` file under `modules/`; each must be a self-registering
flake-parts module. The sole Nix exception is
`modules/features/nvf-package.nix`, a package helper. Non-Nix assets are kept
alongside their owning modules but are not imported. Generated and
host-specific leaves remain in `hosts/chapel/`.

The typed `retr0astic` schema uses lazy registries and
`types.deferredModule`. Self-registering modules contribute named deferred
values for hosts, desktops, shells, themes, users, features, and integrations.
`modules/configurations.nix` resolves and validates string selections only
while generating outputs, preserving laziness and keeping registries
independent.

Desktop, graphical shell, and theme are separate selections. Pair-specific
compatibility belongs exclusively in `retr0astic.integrations`; the explicit
`hyprland-noctalia` record carries compatibility behavior without coupling the
host to a desktop or shell.

`retr0astic.configurations` generates explicit NixOS variants. The current
variant is `chapel-hyprland-noctalia`; the `chapel` output is an alias to that
same configuration. Chapel’s boot, storage, hardware, and host-only settings
remain under `hosts/chapel/`.

Home Manager composes selected user, feature, desktop, shell, theme, and
integration deferred values. To extend the system, add a self-registering
module under the appropriate `modules/` domain and, when needed, an explicit
desktop-shell integration; do not add local imports or central path maps.

Useful validation commands are `git diff --check`, `nix flake show`,
`nix flake check`, targeted `nix eval` commands, and no-link builds of both
Chapel configurations. Activation and deployment are separate operator
actions.
