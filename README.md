<div align="center">

# Retr0astic’s NixOS

Personal NixOS configuration for composing a Chapel host from reusable desktops,
graphical shells, themes, users, and features.

[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org/)
[![Nix flakes](https://img.shields.io/badge/Nix-flakes-7EBAE4?logo=nixos&logoColor=111827)](https://wiki.nixos.org/wiki/Flakes)
[![flake-parts](https://img.shields.io/badge/flake--parts-composable-6E56CF)](https://github.com/hercules-ci/flake-parts)
[![Home Manager](https://img.shields.io/badge/Home_Manager-integrated-5277C3?logo=nixos&logoColor=white)](https://github.com/nix-community/home-manager)
[![CI](https://github.com/Retr0astic/nixos/actions/workflows/flake.yml/badge.svg)](https://github.com/Retr0astic/nixos/actions/workflows/flake.yml)

<!-- Place the real desktop capture at assets/desktop.webp. Do not commit a generated placeholder. -->
![Desktop overview](assets/desktop.webp)

</div>

This is Sree’s personal machine configuration and reference implementation,
not a turnkey distribution. It currently targets one x86_64-linux Chapel
machine running NixOS unstable.

## Highlights

- **Dendritic modules:** public modules self-register in typed,
  string-keyed retr0astic registries; the recursive importer avoids a growing
  central import list.
- **Flakes + flake-parts:** `flake.nix` owns inputs and the supported system;
  `modules/default.nix` is imported through flake-parts.
- **Home Manager integration:** selected users receive personal and shared
  Home Manager modules as part of the generated NixOS configuration.
- **Composable variants:** hosts, desktops, shells, themes, users, features,
  and desktop–shell integrations are selected by name.
- **Desktop stack:** Hyprland is paired with either Noctalia or Caelestia;
  their shells and themes remain separately registered.
- **Chapel hardware and gaming:** the selected Chapel composition includes
  NVIDIA, monitor/HDR, OpenRGB, Steam, Gamescope, Gamemode, Heroic, and related
  gaming tooling.
- **CI and caches:** `.github/workflows/flake.yml` checks pull requests and
  main/testing, builds both graphical-shell variants, verifies aliases, and
  configures the chapel Cachix cache. The flake also declares trusted
  substituters for Chapel, NVF, and Noctalia.

## Screenshots

<!-- Add the real screenshots at these paths when available. These references are intentionally not replaced with fake images. -->

| View | Image |
| --- | --- |
| Desktop | ![Desktop overview](assets/desktop.webp) |
| Launcher | ![Launcher](assets/launcher.webp) |
| Terminal | ![Terminal](assets/terminal.webp) |
| Lockscreen | ![Lockscreen](assets/lockscreen.webp) |

## Available configurations

The canonical outputs are declared in `modules/hosts/chapel.nix`. Aliases point
to those same configuration objects; no default, stable, testing, or
experimental configuration variant is declared by the flake.

| Output | Type | Composition |
| --- | --- | --- |
| noctalia-hyprland | Canonical | Chapel + Hyprland + Noctalia + Noctalia theme |
| caelestia-hyprland | Canonical | Chapel + Hyprland + Caelestia + Caelestia theme |
| chapel | Alias | noctalia-hyprland |
| chapel-hyprland-noctalia | Alias | noctalia-hyprland |
| noctalia | Alias | noctalia-hyprland |
| caelestia | Alias | caelestia-hyprland |

Other useful outputs include `packages.x86_64-linux.nvf`,
`devShells.x86_64-linux.default`, and the three `x86_64-linux` checks:
`composition-contract`, `registry-contract`, and `registry-failure-contract`.

## Architecture

~~~mermaid
flowchart LR
    F[flake.nix] --> P[flake-parts]
    P --> I[modules/default.nix<br/>recursive importer]
    I --> R[typed retr0astic registries]
    R --> H[modules/hosts/chapel.nix<br/>current flake/hosts role]
    R --> C[configuration selection]
    C --> HC[host composition<br/>Chapel + features]
    C --> D[desktop modules<br/>Hyprland]
    C --> T[theme modules<br/>Noctalia or Caelestia]
    C --> S[shell modules<br/>Noctalia or Caelestia]
    C --> G[desktop-shell integrations]
    C --> N[NixOS modules]
    C --> M[Home Manager modules]
    H --> HC
    D --> N
    T --> M
    S --> M
    G --> N
    G --> M
    HC --> O[nixosConfigurations]
    N --> O
    M --> O
~~~

`modules/configurations.nix` resolves the named selections, validates the
desktop–shell integration, composes each selected feature’s system and home
sides, and exposes same-named `nixosConfigurations`. Underscore-prefixed
helpers are excluded from recursive discovery; generated hardware and
repository-owned Noctalia data are deliberate non-registration exceptions.

### Composition model

| Concept | Responsibility | Current values |
| --- | --- | --- |
| Host | Physical machine, boot, storage, and host policy | Chapel |
| Desktop | Compositor and desktop session | Hyprland |
| Shell | Graphical UI stack | Noctalia, Caelestia |
| Theme | Visual styling and assets | Noctalia, Caelestia |
| User | System account and personal Home Manager module | Sree |
| Feature | Reusable NixOS/Home Manager capability | Core, gaming, graphics, fonts, and others |
| Integration | Explicitly supported desktop–shell pair | hyprland-noctalia, hyprland-caelestia |

## Quick start

This configuration is written for Chapel. Inspect the host and hardware modules
before adapting it to another machine.

~~~bash
# Inspect outputs
nix flake show

# Build a system without linking it into the profile
nix build .#nixosConfigurations.noctalia-hyprland.config.system.build.toplevel --no-link

# Test activation (revertible on reboot)
sudo nixos-rebuild test --flake .#noctalia-hyprland

# Persist a selected configuration after testing
sudo nixos-rebuild switch --flake .#noctalia-hyprland

# Validate the flake and repository contracts
nix flake check

# Update every input, or one input only
nix flake update
nix flake lock --update-input nixpkgs
~~~

Use `.#caelestia-hyprland` for the Caelestia composition. The aliases
`chapel`, `chapel-hyprland-noctalia`, `noctalia`, and `caelestia` are also valid
selectors. A persistent switch, activation, reboot, or hardware change is not
performed by this README.

## Repository layout

~~~
.
├── flake.nix                 # inputs, systems, and flake-parts entry point
├── modules/
│   ├── default.nix           # recursive registration importer
│   ├── schema.nix            # typed retr0astic registries
│   ├── configurations.nix    # selection and output generation
│   ├── checks.nix            # composition and registry contracts
│   ├── hosts/                # host and configuration registrations
│   ├── desktops/             # Hyprland and desktop modules
│   ├── shells/               # Noctalia and Caelestia modules
│   ├── themes/               # theme registrations
│   ├── integrations/         # supported desktop–shell pairs
│   ├── features/             # reusable system/home capabilities
│   ├── users/                # user registrations
│   └── noctalia/             # repository-owned shell assets/plugins
├── hosts/chapel/             # Chapel hardware, boot, and storage helpers
├── assets/                   # README screenshots (user-provided)
└── docs/                     # project plans and supporting documentation
~~~

## Extending the configuration

Additions are registrations, not edits to a central list. Public `.nix` files
under `modules/` are discovered recursively unless their path contains an
underscore-prefixed component.

<details>
<summary>Add a Home Manager module</summary>

Put a reusable Home Manager module in the owning feature, desktop, shell,
theme, or user registration and expose it through that registry’s home value.
Features may expose both system and home; a user exposes separate system and
personal home values. Shared selected modules are composed for each selected
user, while a personal user module is applied only to that user.

~~~nix
config.retr0astic.features.example.home = {pkgs, ...}: {
  home.packages = [pkgs.ripgrep];
};
~~~

</details>

<details>
<summary>Add a desktop variant</summary>

Register the desktop under modules/desktops/ with NixOS and/or Home Manager
modules, then add an explicit integration for every supported graphical shell.
The configuration generator will not accept an unregistered desktop–shell pair.

~~~nix
config.retr0astic.desktops.niri = {
  system = {programs.niri.enable = true;};
  home = {wayland.windowManager.niri.enable = true;};
};

config.retr0astic.integrations.niri-noctalia = {
  desktop = "niri";
  shell = "noctalia";
  system = {};
  home = {};
};
~~~

</details>

<details>
<summary>Add a theme variant</summary>

Register the theme under modules/themes/ and expose its Home Manager styling
and assets through home. Keep functional shell behavior in modules/shells/ and
pair-specific behavior in modules/integrations/.

~~~nix
config.retr0astic.themes.example.home = { ... }: {
  # Theme-specific Home Manager options and assets
};
~~~

</details>

<details>
<summary>Add a host or configuration variant</summary>

Register a host with its system, hostname, and host module, then declare a
configuration that selects the host, desktop, shell, theme, users, and features.
Every declaration becomes a same-named nixosConfigurations output.

~~~nix
config.retr0astic.hosts.lantern = {
  hostname = "lantern";
  system = "x86_64-linux";
  module = ./lantern/host.module.nix;
};

config.retr0astic.configurations.lantern-hyprland-noctalia = {
  host = "lantern";
  desktop = "hyprland";
  shell = "noctalia";
  theme = "noctalia";
  users = ["sree"];
  features = ["core"];
};
~~~

Add an alias only when a second public name is useful:

~~~nix
config.retr0astic.configurationAliases.lantern =
  "lantern-hyprland-noctalia";
~~~

</details>

### Where configuration belongs

- Host-specific boot, LUKS, storage, generated hardware, monitors, NVIDIA,
  HDR, and OpenRGB policy belongs in hosts/chapel/ or Chapel-specific
  registrations.
- Reusable NixOS/Home Manager capabilities belong in modules/features/.
- Compositor/session behavior belongs in modules/desktops/.
- Graphical shell behavior belongs in modules/shells/.
- Visual styling belongs in modules/themes/.
- Desktop–shell pair behavior belongs in modules/integrations/.
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
