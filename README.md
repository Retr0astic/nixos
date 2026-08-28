<div align="center">

# Retr0astic’s NixOS

Personal NixOS configuration for composing a Chapel host from reusable desktops,
graphical shells, users, and features.

[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![Nix flakes](https://img.shields.io/badge/Nix-flakes-7EBAE4?logo=nixos&logoColor=111827)](https://wiki.nixos.org/wiki/Flakes)
[![flake-parts](https://img.shields.io/badge/flake--parts-composable-6E56CF)](https://github.com/hercules-ci/flake-parts)
[![Home Manager](https://img.shields.io/badge/Home_Manager-integrated-5277C3?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)
[![CI](https://github.com/Retr0astic/nixos/actions/workflows/flake.yml/badge.svg)](https://github.com/Retr0astic/nixos/actions/workflows/flake.yml)

</div>

This is Sree’s personal machine configuration and reference implementation,
not a turnkey distribution. It currently targets one x86_64-linux Chapel
machine running NixOS unstable.

## Highlights

- **Dendritic modules:** every file publishes one aspect under
  `flake.modules.nixos.<name>` or `flake.modules.homeManager.<name>`; the
  recursive importer avoids a growing central import list.
- **Flakes + flake-parts:** `flake.nix` owns inputs and the supported system;
  every file under `modules/` is loaded by `import-tree`.
- **Home Manager integration:** selected users receive personal and shared
  Home Manager modules as part of the generated NixOS configuration.
- **Composable variants:** each configuration is a plain list of aspect
  modules, so a desktop or a shell is added or removed in one line.
- **Desktop stack:** Hyprland is paired with either Noctalia or Caelestia;
  each shell carries its own theming and its own Hyprland glue.
- **Chapel hardware and gaming:** the selected Chapel composition includes
  NVIDIA, monitor/HDR, OpenRGB, Steam, Gamescope, Gamemode, Heroic, and related
  gaming tooling.
- **CI and caches:** `.github/workflows/flake.yml` checks pull requests and
  main/testing, builds both graphical-shell variants, verifies aliases, and
  configures the chapel Cachix cache. The flake also declares trusted
  substituters for Chapel, NVF, and Noctalia.

## Available configurations

The outputs are declared in `modules/hosts/chapel.nix` and
`modules/hosts/bigrig.nix`. One name maps to one build. The flake declares no
aliases, and no default, stable, testing, or experimental variant.

| Output | Composition |
| --- | --- |
| chapel | Chapel + Hyprland + Noctalia |
| chapel-caelestia | Chapel + Hyprland + Caelestia |
| bigrig | Headless server, no compositor |

Other useful outputs include `packages.x86_64-linux.nvf`,
`devShells.x86_64-linux.default`, and `modules.nixos` / `modules.homeManager`,
which expose every aspect module by name.

## Architecture

~~~mermaid
flowchart LR
    F[flake.nix] --> P[flake-parts]
    P --> X[flakeModules.modules<br/>declares flake.modules]
    P --> I[import-tree ./modules<br/>loads every file]
    I --> A["aspect files<br/>flake.modules.nixos.&lt;name&gt;<br/>flake.modules.homeManager.&lt;name&gt;"]
    A --> H[modules/hosts/chapel.nix<br/>lists the modules it wants]
    H --> O[nixosConfigurations]
~~~

Every file under `modules/` is a flake-parts module. Each one names an aspect,
such as `gaming` or `hyprland`, and gives that aspect a NixOS side, a Home
Manager side, or both. Several files may define the same aspect name, and the
module system merges them.

`modules/hosts/chapel.nix` then builds each variant from a plain list of those
modules. Underscore-prefixed helpers stay out of recursive discovery. Generated
hardware and repository-owned Noctalia data are deliberate exceptions.

A NixOS aspect pulls in its own Home Manager half:

~~~nix
flake.modules.nixos.gaming = {pkgs, ...}: {
  home-manager.sharedModules = [config.flake.modules.homeManager.gaming];
  programs.steam.enable = true;
};

flake.modules.homeManager.gaming = {pkgs, ...}: {
  home.packages = [pkgs.mangohud];
};
~~~

### Composition model

| Concept | Responsibility | Current values |
| --- | --- | --- |
| Host | Physical machine, boot, storage, and host policy | `chapel` |
| Desktop | Compositor and desktop session | `hyprland` |
| Shell | Graphical UI stack, including its own theming | `noctalia`, `caelestia` |
| User | System account and personal Home Manager module | `sree` |
| Feature | Reusable NixOS/Home Manager capability | `core`, `gaming`, `graphics`, `fonts`, and others |

Pair-specific behavior lives inside the module that needs it, behind a
condition. The Hyprland key bindings of Noctalia, for example, apply only when
`config.wayland.windowManager.hyprland.enable` is true. No table of supported
pairs exists, and none is needed.

## Quick start

This configuration is written for Chapel. Inspect the host and hardware modules
before adapting it to another machine.

~~~bash
# Inspect outputs
nix flake show

# Build a system without linking it into the profile
nix build .#nixosConfigurations.chapel.config.system.build.toplevel --no-link

# Test activation (revertible on reboot)
sudo nixos-rebuild test --flake .#chapel

# Persist a selected configuration after testing
sudo nixos-rebuild switch --flake .#chapel

# Validate the flake and repository contracts
nix flake check

# Update every input, or one input only
nix flake update
nix flake lock --update-input nixpkgs
~~~

Use `.#chapel-caelestia` for the Caelestia composition. A persistent switch,
activation, reboot, or hardware change is not performed by this README.

## Repository layout

~~~
.
├── flake.nix                 # inputs, systems, and flake-parts entry point
├── modules/
│   ├── home-manager.nix      # shared Home Manager settings
│   ├── hosts/                # host modules and nixosConfigurations
│   ├── desktops/             # Hyprland and desktop modules
│   ├── shells/               # Noctalia and Caelestia modules
│   ├── features/             # reusable system/home capabilities
│   ├── users/                # user modules
│   └── noctalia/             # repository-owned shell assets/plugins
└── hosts/chapel/             # Chapel hardware, boot, and storage helpers
~~~

## Extending the configuration

See [`docs/GUIDE.md`](docs/GUIDE.md) for the full working manual: daily
commands, recipes, known traps, and debugging steps.

Write one file, then name it in a host. Public `.nix` files under `modules/`
are discovered recursively unless their path contains an underscore-prefixed
component.

<details>
<summary>Add a feature</summary>

Give the aspect a Home Manager side, a NixOS side, or both. A NixOS side that
carries only the link line is normal for a home-only feature.

~~~nix
{config, ...}: {
  flake.modules.nixos.example = {
    home-manager.sharedModules = [config.flake.modules.homeManager.example];
  };

  flake.modules.homeManager.example = {pkgs, ...}: {
    home.packages = [pkgs.ripgrep];
  };
}
~~~

Then add `example` to the `base` list in `modules/hosts/chapel.nix`.

</details>

<details>
<summary>Add a desktop or a desktop environment</summary>

Write `modules/desktops/niri.nix`, then add one line to the host file. Nothing
else is required. A desktop environment such as GNOME needs no shell entry and
no theme entry.

~~~nix
{...}: {
  flake.modules.nixos.niri = {
    programs.niri.enable = true;
    services.displayManager.defaultSession = "niri";
  };
}
~~~

~~~nix
# modules/hosts/chapel.nix
withNiri = mk [m.niri m.noctalia];
~~~

</details>

<details>
<summary>Add a graphical shell</summary>

Write `modules/shells/<name>.nix`. Keep the theming of that shell in the same
file. Put desktop-specific glue behind a condition, so the shell stays usable
under any other desktop.

~~~nix
wayland.windowManager.hyprland.settings =
  lib.mkIf config.wayland.windowManager.hyprland.enable {
    bind = lib.mkAfter [ /* shell key bindings */ ];
  };
~~~

</details>

<details>
<summary>Add a host or a variant</summary>

Copy `modules/hosts/chapel.nix`, point it at the new hardware module, and list
the aspects the machine needs. Every attribute of `flake.nixosConfigurations`
becomes a selector for `nixos-rebuild`.

~~~nix
flake.nixosConfigurations = {
  lantern = mk [m.hyprland m.noctalia];
};
~~~

Write `m.<name>` inside those lists. A bare name would pick up an attribute of
the same set, which yields a confusing "expected a module" error.

</details>

### Where configuration belongs

- Host-specific boot, LUKS, storage, generated hardware, monitors, NVIDIA,
  HDR, and OpenRGB policy belongs in hosts/chapel/ or modules/hosts/chapel/.
- Reusable NixOS/Home Manager capabilities belong in modules/features/.
- Compositor/session behavior belongs in modules/desktops/.
- Graphical shell behavior and shell theming belong in modules/shells/.
- Desktop-specific glue belongs in the module that needs it, behind a
  condition.
- Personal identity, aliases, packages, startup, and personal rules belong in
  modules/users/.

### Branch workflow

The configured workflow is `.github/workflows/flake.yml`. It runs for every
pull request, pushes to main and testing, and manual dispatches. The repository
therefore has two CI-covered branches, but the flake does not declare separate
stable or testing configurations.

## Caveats

- This is a personal configuration, not a general-purpose distribution.
- Chapel’s boot, LUKS, filesystems, storage, generated hardware, NVIDIA,
  monitors, HDR, and OpenRGB settings are machine-specific.
- No secrets are expected to be committed; inspect every module before reuse.
- Noctalia assets are repository-owned and installed reproducibly from the
  flake source tree.
- NixOS unstable inputs can change runtime behavior over time.
- No license has been added yet.

## Suggested repository metadata

Suggested GitHub description:

> A dendritic NixOS configuration for composable Chapel, Hyprland, Noctalia, and Caelestia setups.

Suggested topics: nixos, nix, nix-flakes, flake-parts, home-manager, hyprland,
noctalia, caelestia, dotfiles, linux-desktop.

## Acknowledgements

[NixOS](https://github.com/NixOS/nixpkgs),
[flake-parts](https://github.com/hercules-ci/flake-parts),
[Home Manager](https://github.com/nix-community/home-manager),
[Hyprland](https://github.com/hyprwm/Hyprland),
[Noctalia](https://github.com/noctalia-dev/noctalia),
[NVF](https://github.com/NotAShelf/nvf), and
[Noctalia Greeter](https://github.com/noctalia-dev/noctalia-greeter).
