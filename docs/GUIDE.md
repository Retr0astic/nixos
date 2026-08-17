# Working guide

How to use and change this repository. Read `README.md` first for the
architecture. This file is the day-to-day manual.

---

## 1. The model in one page

Two steps decide what your machine runs.

**Step 1: a file registers an aspect.** An aspect is one named feature, such
as `gaming` or `hyprland`. `import-tree` reads every `.nix` file under
`modules/`, so no import list exists.

```nix
flake.modules.nixos.gaming = { ... };        # system side
flake.modules.homeManager.gaming = { ... };  # user side
```

Registration alone changes nothing.

**Step 2: a host applies the aspect.** `modules/hosts/chapel.nix` lists the
names it wants. Only listed aspects reach the machine.

```nix
base = with m; [chapel home-manager sree core gaming ...];
withNoctalia = mk [m.hyprland m.noctalia];
```

Three rules follow from this:

1. A new file costs nothing until a host names it.
2. Several files may define one aspect name. They merge.
3. To turn a feature off, remove the name from the list. Keep the file.

---

## 2. Daily commands

```bash
# Rebuild the default variant (Hyprland + Noctalia)
sudo nixos-rebuild switch --flake ~/nixos

# Try a change without keeping it after a reboot
sudo nixos-rebuild test --flake ~/nixos#chapel

# Build the other variant
sudo nixos-rebuild switch --flake ~/nixos#caelestia

# Build without touching the running system
nix build ~/nixos#nixosConfigurations.chapel.config.system.build.toplevel --no-link

# Check that everything still evaluates
nix flake check

# Update all inputs, then rebuild
nix flake update && sudo nixos-rebuild switch --flake ~/nixos
```

Two aliases exist in your fish shell already: `rebuild` and `update`.

**Variant names**

| Name | Builds |
| --- | --- |
| `chapel`, `noctalia`, `noctalia-hyprland`, `chapel-hyprland-noctalia` | Hyprland + Noctalia |
| `caelestia`, `caelestia-hyprland` | Hyprland + Caelestia |

A bare `nixos-rebuild --flake ~/nixos` picks `chapel`, because that is the
hostname.

---

## 3. Recipes

### Add a system package

Edit `modules/features/system-packages.nix`. Add the name to the list.

### Add a user package

Edit `modules/features/packages.nix`. Add the name to the list.

### Add a home program with settings

Pick the closest existing file, such as `modules/features/terminals.nix` for
terminals, or `modules/features/shell.nix` for shell tools. Add the block.

### Add a new feature

Create `modules/features/<name>.nix`.

Home side only:

```nix
{config, ...}: {
  flake.modules.nixos.<name> = {
    home-manager.sharedModules = [config.flake.modules.homeManager.<name>];
  };

  flake.modules.homeManager.<name> = {pkgs, ...}: {
    programs.example.enable = true;
  };
}
```

System side only:

```nix
{...}: {
  flake.modules.nixos.<name> = {pkgs, ...}: {
    services.example.enable = true;
  };
}
```

Both sides: write both blocks, and keep the `sharedModules` line in the NixOS
block.

Then add `<name>` to `base` in `modules/hosts/chapel.nix`.

### Add a window manager or a desktop environment

Create `modules/desktops/<name>.nix`.

```nix
{...}: {
  flake.modules.nixos.niri = {pkgs, ...}: {
    programs.niri.enable = true;
    services.displayManager.defaultSession = "niri";
    environment.systemPackages = [pkgs.xwayland-satellite];
  };
}
```

Then add one variant in `modules/hosts/chapel.nix`:

```nix
withNiri = mk [m.niri m.noctalia];
```

And publish it:

```nix
flake.nixosConfigurations = {
  niri = withNiri;
  ...
};
```

GNOME or Plasma needs no shell and no theme. Write the desktop file:

```nix
# modules/desktops/gnome.nix
{...}: {
  flake.modules.nixos.gnome = {
    services.xserver.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
  };
}
```

Then list the desktop alone:

```nix
withGnome = mk [m.gnome];
```

A shell-less variant is verified to evaluate. The Hyprland settings in
`modules/hosts/chapel/monitor.nix` and `modules/hosts/chapel/nvidia.nix` stay
inert when Hyprland is absent.

### Add a graphical shell

Create `modules/shells/<name>.nix`. Put three things in the one file:

1. The shell itself.
2. Its theming.
3. Its desktop glue, behind a condition.

```nix
{config, inputs, ...}: {
  flake.modules.nixos.<name> = {
    home-manager.sharedModules = [config.flake.modules.homeManager.<name>];
  };

  flake.modules.homeManager.<name> = {config, lib, ...}: {
    imports = [inputs.<name>.homeModules.default];
    programs.<name>.enable = true;

    wayland.windowManager.hyprland.settings =
      lib.mkIf config.wayland.windowManager.hyprland.enable {
        bind = lib.mkAfter [ /* shell key bindings */ ];
      };
  };
}
```

The `mkIf` is what replaces the old integration table. Under a desktop that is
not Hyprland, the block stays inert.

### Add an input (a flake dependency)

Edit `flake.nix`, `inputs` block:

```nix
niri = {
  url = "github:YaLTeR/niri";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Run `nix flake lock`. Use it in any module as `inputs.niri`.

### Add a second machine

1. Create `hosts/<name>/hardware-configuration.nix` with
   `nixos-generate-config --show-hardware-config`.
2. Create `hosts/<name>/host.module.nix` for hostname, boot, and storage.
3. Copy `modules/hosts/chapel.nix` to `modules/hosts/<name>.nix`. Point the
   host aspect at the new files, and list the aspects that machine needs.

### Turn something off

- For one variant: remove the name from that variant's list.
- For every variant: remove the name from `base`.
- To stop the file from loading at all: rename it to `_<name>.nix`.

Keep the file in all three cases. Deleting is a separate decision.

---

## 4. Four traps

**Trap 1: bare names inside the host lists.**

```nix
withNoctalia = mk [m.hyprland m.noctalia];   # correct
withNoctalia = mk (with m; [hyprland noctalia]);  # risky
```

A bare `noctalia` can pick up an attribute of `flake.nixosConfigurations`
instead of the module. The error reads `expected a module, but found a value
of type "configuration"`. Always write `m.<name>` there.

**Trap 2: the `imports` path form.**

```nix
home-manager.users.sree = {imports = [ ... ];};   # correct
home-manager.users.sree.imports = [ ... ];        # fails
```

The second form is read as an option path. It produces the same confusing
`expected a module` error.

**Trap 3: the link line, once per aspect.**

`home-manager.sharedModules = [config.flake.modules.homeManager.<name>]` must
appear exactly once for each aspect. The `chapel` aspect is defined in four
files, and only `modules/hosts/chapel.nix` carries its link line. A second copy
imports the module twice.

**Trap 4: `config` means two different things.**

```nix
{config, ...}: {                       # config = the flake
  flake.modules.nixos.example = {config, ...}: {   # config = the NixOS system
    ...
  };
}
```

If the inner function does not name `config`, the outer one applies. That is
how `config.flake.modules.homeManager.<name>` works inside a NixOS module.

---

## 5. When something breaks

**Read the last three lines first.** Nix prints the real error at the bottom.

```bash
# Full trace
nix eval .#nixosConfigurations.chapel.config.system.build.toplevel.drvPath --show-trace

# Does the whole flake still evaluate?
nix flake check

# Which aspects exist?
nix eval .#modules.nixos --apply builtins.attrNames
nix eval .#modules.homeManager --apply builtins.attrNames

# Read one option value
nix eval .#nixosConfigurations.chapel.config.networking.hostName
```

**Common messages**

| Message | Cause |
| --- | --- |
| `attribute 'x' missing` | The host lists a name no file registers. Check spelling. |
| `expected a module, but found a value of type "configuration"` | Trap 1 or Trap 2 above. |
| `option ... does not exist` | The aspect is applied to the wrong class. A Home Manager option was put in a `nixos` module, or the reverse. |
| `The option ... is defined multiple times` | Two files set one non-mergeable option. Use `lib.mkForce` or `lib.mkDefault`. |

**Bisect a bad change.** Cut the `base` list in `modules/hosts/chapel.nix` down
to `[chapel home-manager sree]`, confirm it evaluates, then add names back in
halves.

**Roll back a bad switch.** Pick the previous generation in the boot menu, or:

```bash
sudo nixos-rebuild switch --rollback
```

---

## 6. Before you commit

```bash
nix fmt          # alejandra, the repository formatter
nix flake check  # evaluates every variant
```

CI runs `nix flake check`, verifies that the four aliases resolve to their
targets, and builds both variants. It does not check formatting, so run
`nix fmt` yourself. CI fires on every pull request and on pushes to `main` and
`testing`.
