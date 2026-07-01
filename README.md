# NixOS Configuration

This repository is Retr0astic's NixOS flake. It uses a dendritic layout: small modules are grouped by responsibility, and host outputs compose those modules instead of keeping one large configuration file.

The default machine output is `chapel`, currently composed as `hyprland + noctalia`.

## Quick Commands

Build the default Chapel system:

```bash
sudo nixos-rebuild switch --flake ~/nixos#chapel
```

Build the explicit Hyprland/Noctalia variant:

```bash
sudo nixos-rebuild switch --flake ~/nixos#chapel-hyprland-noctalia
```

Check the flake:

```bash
nix flake check
```

Update inputs and rebuild:

```bash
cd ~/nixos
nix flake update
sudo nixos-rebuild switch --flake .#chapel
```

## Layout

```text
flake.nix                     Flake inputs and flake-parts entrypoint
flake/                        Flake-parts modules loaded by lib/treeimport.nix
flake/hosts.nix               Host and variant composition
flake/packages.nix            Exported packages, currently nvf
lib/treeimport.nix            Local recursive importer for flake-parts modules
hosts/chapel/                 Chapel-specific system and hardware config
modules/nixos/                Reusable NixOS system modules
modules/home/                 Reusable Home Manager modules
modules/hyprland/             Hyprland Home Manager config
modules/noctalia/             Noctalia config and plugins linked into ~/.config/noctalia
modules/starship/             Starship Home Manager module and TOML config
home.nix                      Small Home Manager entrypoint
configuration.nix             Compatibility shim importing hosts/chapel
```

## How Composition Works

`flake.nix` delegates to `flake-parts` and imports all modules under `flake/` using `lib/treeimport.nix`.

`flake/hosts.nix` defines three important things:

- `desktops`: desktop environments/window managers and their system/home modules.
- `themes`: shell/theme layers such as Noctalia.
- `mkHost`: a helper that combines a host, desktop, theme, and optional extra modules into a NixOS output.

The default output is:

```nix
chapel = mkHost {
  hostname = "chapel";
  desktop = "hyprland";
  theme = "noctalia";
};
```

## Where To Put Things

Host-specific machine settings go in `hosts/chapel/default.nix`. Use this for hostname, boot details, LUKS, host-only kernel modules, and machine-specific imports.

Hardware scan output goes in `hosts/chapel/hardware-configuration.nix`. This should stay close to generated `nixos-generate-config` output.

System-wide NixOS config goes in `modules/nixos/`:

- `modules/nixos/core/`: base Nix settings, common system packages, environment variables.
- `modules/nixos/desktops/`: system-side desktop enablement, portals, display/session integration.
- `modules/nixos/hardware/`: GPU and hardware support.
- `modules/nixos/programs/`: system-level program groups such as gaming or Zen Browser.
- `modules/nixos/services/`: services such as PipeWire, SDDM, OpenRGB, libvirt.
- `modules/nixos/users/`: user account declarations.

Home Manager config goes in `modules/home/`:

- `modules/home/packages/`: general user packages that should exist regardless of desktop or theme.
- `modules/home/shell/`: shell, aliases, zoxide, fzf, yazi.
- `modules/home/terminals/`: Kitty, WezTerm, Ghostty and terminal packages.
- `modules/home/programs/`: application modules such as Zathura and Spicetify.
- `modules/home/appearance/`: GTK, Qt, fonts/cursors from the user side.
- `modules/home/services/`: user services such as OpenRGB autostart.
- `modules/home/xdg/`: MIME apps and XDG user directories.
- `modules/home/themes/`: theme layers such as Noctalia.

Desktop-specific Home Manager config goes outside the generic home tree. For example, Hyprland keybinds, monitor config, hypridle, and Hyprland-only packages live in `modules/hyprland/hyprland.nix`.

Theme-specific config lives in `modules/home/themes/`. Noctalia is enabled by `modules/home/themes/noctalia.nix`, which links `~/nixos/modules/noctalia` into `~/.config/noctalia`.

## Adding A New Desktop Variant

To add `niri + noctalia`:

1. Create a system module:

```text
modules/nixos/desktops/niri.nix
```

2. Create a home module:

```text
modules/niri/niri.nix
```

3. Register the desktop in `flake/hosts.nix`:

```nix
desktops = {
  hyprland = {
    system = ../modules/nixos/desktops/hyprland.nix;
    home = ../modules/hyprland/hyprland.nix;
  };

  niri = {
    system = ../modules/nixos/desktops/niri.nix;
    home = ../modules/niri/niri.nix;
  };
};
```

4. Add an output:

```nix
chapel-niri-noctalia = mkHost {
  hostname = "chapel";
  desktop = "niri";
  theme = "noctalia";
};
```

5. Build it:

```bash
sudo nixos-rebuild switch --flake ~/nixos#chapel-niri-noctalia
```

## Adding A New Theme Variant

To add `hyprland + caelestia`:

1. Create the theme module:

```text
modules/home/themes/caelestia.nix
```

2. Register it in `flake/hosts.nix`:

```nix
themes = {
  noctalia = {
    home = ../modules/home/themes/noctalia.nix;
  };

  caelestia = {
    home = ../modules/home/themes/caelestia.nix;
  };
};
```

3. Add an output:

```nix
chapel-hyprland-caelestia = mkHost {
  hostname = "chapel";
  desktop = "hyprland";
  theme = "caelestia";
};
```

4. Build it:

```bash
sudo nixos-rebuild switch --flake ~/nixos#chapel-hyprland-caelestia
```

## Branch Workflow

This refactor is intended to live on `testing` until it is proven on the machine.

Useful commands:

```bash
git status --short --branch
git commit -m "Split Home Manager config into dendritic modules"
git push github testing
```

Do not merge into `main` until `nix flake check` and a real `nixos-rebuild switch` have both succeeded for the output you plan to use.
