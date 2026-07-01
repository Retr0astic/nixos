# Retr0astic's NixOS Flake

[![NixOS](https://img.shields.io/badge/NixOS-unstable-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![flake-parts](https://img.shields.io/badge/flake--parts-enabled-7C3AED)](https://flake.parts)
[![Home Manager](https://img.shields.io/badge/Home%20Manager-enabled-0EA5E9)](https://github.com/nix-community/home-manager)
[![Default](https://img.shields.io/badge/default-chapel%20%3D%20hyprland%20%2B%20noctalia-F59E0B)](#outputs)

A dendritic NixOS configuration built around small composable modules. The default host is `chapel`, currently composed as `hyprland + noctalia`.

```text
flake.nix
  -> flake-parts
    -> flake/hosts.nix
      -> hosts/chapel
      -> modules/nixos/*
      -> modules/home/*
      -> modules/hyprland
      -> modules/home/themes/noctalia.nix
```

## Commands

| Task | Command |
| --- | --- |
| Switch to default Chapel | `sudo nixos-rebuild switch --flake ~/nixos#chapel` |
| Test without making boot default | `sudo nixos-rebuild test --flake ~/nixos#chapel` |
| Build only | `nix build ~/nixos#nixosConfigurations.chapel.config.system.build.toplevel` |
| Check flake | `nix flake check` |
| Run NVF package | `nix run ~/nixos#nvf` |
| Update inputs and switch | `cd ~/nixos && nix flake update && sudo nixos-rebuild switch --flake .#chapel` |

## Outputs

| Output | Purpose |
| --- | --- |
| `chapel` | Default system, currently `hyprland + noctalia` |
| `chapel-hyprland-noctalia` | Explicit alias for the current default variant |
| `packages.x86_64-linux.nvf` | Neovim package built from `modules/nvf.nix` |

## Repository Map

```text
.
├── flake.nix                  # inputs and flake-parts entrypoint
├── flake.lock                 # pinned input revisions
├── flake/                     # flake-parts modules
│   ├── hosts.nix              # host/desktop/theme composition
│   └── packages.nix           # package outputs
├── hosts/
│   └── chapel/                # Chapel-specific system config
├── lib/
│   └── treeimport.nix         # recursive importer for flake/*
├── modules/
│   ├── nixos/                 # reusable NixOS modules
│   ├── home/                  # reusable Home Manager modules
│   ├── hyprland/              # Hyprland Home Manager config
│   ├── noctalia/              # Noctalia config and plugins
│   ├── starship/              # Starship config
│   ├── lucidglyph.nix         # font rendering config
│   ├── nvf.nix                # NVF config
│   └── zen.nix                # Zen Browser wrapper
└── configuration.nix          # compatibility shim importing hosts/chapel
```

## How It Works

`flake.nix` does not manually assemble every output. It calls `flake-parts.lib.mkFlake` and imports every module under `flake/` through `lib/treeimport.nix`.

`flake/hosts.nix` defines the composition layer:

| Name | Role |
| --- | --- |
| `desktops` | Maps desktop names to system and Home Manager modules |
| `themes` | Maps theme names to Home Manager theme modules |
| `mkHost` | Combines host, desktop, theme, and optional extra modules |

The default host is declared like this:

```nix
chapel = mkHost {
  hostname = "chapel";
  desktop = "hyprland";
  theme = "noctalia";
};
```

## Where To Put Things

| Change | File or directory |
| --- | --- |
| Hostname, boot, LUKS, host-only kernel settings | `hosts/chapel/default.nix` |
| Filesystems and generated hardware scan | `hosts/chapel/hardware-configuration.nix` |
| Common system packages and Nix settings | `modules/nixos/core/default.nix` |
| System services such as PipeWire, SDDM, OpenRGB daemon support | `modules/nixos/services/default.nix` |
| NVIDIA settings | `modules/nixos/hardware/nvidia.nix` |
| Steam, gamescope, gamemode, Heroic | `modules/nixos/programs/gaming.nix` |
| General user packages | `modules/home/packages/default.nix` |
| Shell aliases and CLI integrations | `modules/home/shell/default.nix` |
| Terminal packages and terminal config | `modules/home/terminals/default.nix` |
| GTK/Qt/cursor user styling | `modules/home/appearance/default.nix` |
| Home Manager app modules | `modules/home/programs/` |
| XDG MIME apps and user dirs | `modules/home/xdg/default.nix` |
| Hyprland-only user packages/settings | `modules/hyprland/hyprland.nix` |
| Noctalia theme integration | `modules/home/themes/noctalia.nix` |
| Font rendering and Lucidglyph | `modules/lucidglyph.nix` |

## Adding A Home Manager Module

Example: add Git user config.

Create `modules/home/programs/git.nix`:

```nix
{...}: {
  programs.git = {
    enable = true;
    userName = "Retr0astic";
    userEmail = "you@example.com";
  };
}
```

Import it from `modules/home/programs/default.nix`:

```nix
{...}: {
  imports = [
    ./documents.nix
    ./git.nix
    ./spicetify.nix
  ];
}
```

## Adding A Desktop Variant

To add `niri + noctalia`:

1. Create the system module:

```text
modules/nixos/desktops/niri.nix
```

2. Create the Home Manager module:

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

4. Add the output:

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

## Adding A Theme Variant

To add `hyprland + caelestia`:

1. Create `modules/home/themes/caelestia.nix`.

2. Register the theme in `flake/hosts.nix`:

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

3. Add the output:

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

## Notes

- `nix run .#nvf` works because `nvf` is a package output.
- NixOS systems are not run with `nix run`; use `nixos-rebuild --flake .#chapel`.
- Hyprland settings are Home Manager modules, not runnable apps.
- Lucidglyph is imported by Chapel and contributes fontconfig snippets plus Freetype environment variables.

## Branch Workflow

This refactor lives on `testing` until it is proven on the machine.

```bash
git status --short --branch
nix flake check
sudo nixos-rebuild test --flake .#chapel
git commit -m "Describe the change"
git push github testing
```
