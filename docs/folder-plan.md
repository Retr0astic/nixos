# Folder plan

## What folders do and do not do here

`import-tree` loads every `.nix` file under `modules/` regardless of depth or
name. Folders carry no semantics. Moving a file between them changes nothing
about evaluation.

So this is a readability question, not a correctness one. Judge any proposal
by one test: **can you guess which folder a file is in before you look?**

Two mechanical exceptions, and they are the reason to be careful:

1. **The CI paths filter globs on directories.** `.github/workflows/flake.yml`
   references `modules/desktops/hyprland/**` and `modules/shells/caelestia.nix`.
   Any move must update those globs or the conditional build silently stops
   triggering.
2. **`modules/noctalia/` is referenced by a hardcoded runtime string**, not a
   Nix path. `modules/shells/noctalia.nix` contains
   `mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos/modules/noctalia"`
   plus two more occurrences in the `noctalia-config` fish function. Move that
   directory and `nix flake check` stays green while the live config symlink
   breaks at runtime. Grep for string paths, not just `../`.

## The current problem

`modules/features/` holds 19 of 50 files. It does not name a domain — it means
"nothing else fit". That is the only folder genuinely worth fixing.

`modules/desktops/` versus `modules/shells/` is a real distinction and should
stay: the compositor is a different layer from the Quickshell bar that runs on
it. Swapping Noctalia for Caelestia leaves Hyprland untouched, and the folder
split records that.

## The three specific questions

### Should starship live under a terminals folder?

No. `terminals.nix` configures terminal *emulators* — kitty, wezterm, ghostty.
Starship is a shell prompt. It renders inside any of them and has nothing to do
with which one is running. Put it with `shell.nix`, which is where fish and its
aliases already live.

There is a second reason to keep it away from `terminals`: `terminals` is
chapel-only, `shell` is shared, and bigrig needs a prompt.

The two prompt files are variants, not host config — chapel's is coupled to the
Noctalia palette, bigrig's is standalone. Name them for that
(`starship-noctalia.nix`, `starship-plain.nix`) rather than for the host.

### Should Noctalia and the Hyprland modules live under a desktop folder?

They effectively already do, under `desktops/` and `shells/`. Group both under
one `desktop/` parent so the relationship is visible:

    modules/desktop/hyprland/       compositor: settings, bindings, rules, ...
    modules/desktop/shells/         noctalia.nix, caelestia.nix

The real fix in this area is not the parent folder. It is that the Noctalia
*aspect* is at `modules/shells/noctalia.nix` while its *assets* — `config.toml`,
`colors.json`, the three Quickshell plugins — sit at `modules/noctalia/`. One
concern, two unrelated locations. They should be adjacent:

    modules/desktop/shells/noctalia.nix
    modules/desktop/shells/noctalia/    (assets)

This is the move that requires updating the three hardcoded runtime strings.
Do it alone, in its own commit, and verify the symlink afterwards.

### Should opends5 live under a gaming folder?

Yes. It is a DualSense controller driver; its only purpose here is games. A
`gaming/` folder holding `gaming.nix` and `opends5.nix` is more informative
than either file sitting in `features/`.

## Proposed layout

    modules/
      system/       core, secrets, services, audio, graphics,
                    hardware-tools, home-manager
      desktop/      appearance, fonts, xdg, media, file-managers,
                    terminals, core-desktop
        hyprland/   (from desktops/hyprland/)
        shells/     noctalia.nix + noctalia/, caelestia.nix
      gaming/       gaming, opends5
      apps/         zen, spicetify, programs, ai-tools, desktop-packages
      shell/        shell, starship-noctalia, starship-plain, nvf
      hosts/        chapel, bigrig, and their host-specific aspects
      users/        sree
      dev/          devshells, formatters

`features/` disappears. Every remaining folder names a domain you could guess
from a filename.

## Cost

This is churn. It changes no behaviour and fixes no bug. It costs:

- a CI glob update (mandatory, or conditional builds break silently),
- three hardcoded string paths (mandatory, or the live symlink breaks),
- `git log` on moved files needs `--follow`,
- one full rebuild to confirm nothing regressed.

Worth doing once, as **a single commit containing only moves and path
updates**, so the diff reviews as renames. Not worth doing incrementally, and
not worth doing before the correctness items in `TODO.md`.
