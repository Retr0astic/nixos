# sops-nix Secrets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add sops-nix to this NixOS flake, store a GitHub token in an
encrypted secrets file, and wire that token into Nix's `access-tokens`
config so `nix flake update` stops hitting GitHub's API rate limit.

**Architecture:** This repo uses the "dendritic" flake-parts pattern —
every module declares `flake.modules.nixos.<name>`, and
`modules/hosts/chapel.nix` lists which named modules go into the
`chapel` host's `base` module list. sops-nix is added the same way:
one new module, `modules/features/secrets.nix`, declaring
`flake.modules.nixos.secrets`, added to `base` in
`modules/hosts/chapel.nix`. Decryption uses the host's existing SSH
ed25519 key (converted to an age key), so there is no separate key
file to generate or back up.

**Tech Stack:** NixOS, flake-parts, sops-nix, age, sops CLI.

**Spec:** `docs/superpowers/specs/2026-08-24-sops-nix-secrets-design.md`

## Global Constraints

- Reuse `/etc/ssh/ssh_host_ed25519_key` as the decryption key — do not
  generate a separate age keypair.
- First secret is `github_token` only. No other secrets in this pass.
- `secrets/secrets.yaml` must be sops-encrypted before it is committed
  — never commit a plaintext secret file.
- The raw token value must never land in the Nix store or in
  `nix.conf` as a literal (it is injected via a sops-nix rendered
  template at `/run/secrets-rendered/...`, root-only).
- Host being configured: `chapel` (`hosts/chapel/`,
  `modules/hosts/chapel.nix`).

---

### Task 1: Add sops-nix flake input

**Files:**
- Modify: `flake.nix:17-70` (inputs block)

**Interfaces:**
- Produces: flake input `inputs.sops-nix`, with
  `inputs.sops-nix.nixosModules.sops` available to later tasks.

- [ ] **Step 1: Add the input**

In `flake.nix`, inside the `inputs = { ... };` block, add after the
`nvf` input (or anywhere alongside the other inputs):

```nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

- [ ] **Step 2: Lock the new input**

Run: `nix flake lock --update-input sops-nix`
Expected: command exits 0, `flake.lock` gains a `sops-nix` entry (and
its transitive inputs).

- [ ] **Step 3: Verify the flake still evaluates**

Run: `nix flake show --no-write-lock-file 2>&1 | tail -20`
Expected: no eval errors (existing `nixosConfigurations` still list,
e.g. `chapel`, `noctalia`, `caelestia`).

- [ ] **Step 4: Commit**

```bash
git add flake.nix flake.lock
git commit -m "feat: add sops-nix flake input"
```

---

### Task 2: Derive the host age key and create .sops.yaml

**Files:**
- Create: `.sops.yaml`

**Interfaces:**
- Produces: an age public key string (`age1...`) recorded in
  `.sops.yaml`, used by Task 3 to encrypt `secrets/secrets.yaml` and
  by Task 4's `sops.age.sshKeyPaths` to decrypt it at boot.

- [ ] **Step 1: Convert the host SSH public key to an age public key**

Run: `nix run nixpkgs#ssh-to-age -- -i /etc/ssh/ssh_host_ed25519_key.pub`
Expected: prints one line starting with `age1`. Copy this value — it
is referred to as `<HOST_AGE_PUBKEY>` below.

- [ ] **Step 2: Create `.sops.yaml`**

Write `.sops.yaml` at the repo root:

```yaml
keys:
  - &host_chapel <HOST_AGE_PUBKEY>
creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *host_chapel
```

Replace `<HOST_AGE_PUBKEY>` with the value from Step 1.

- [ ] **Step 3: Commit**

```bash
git add .sops.yaml
git commit -m "feat: add sops age key rule for chapel host"
```

---

### Task 3: Create the encrypted secrets file

**Files:**
- Create: `secrets/secrets.yaml` (encrypted; committed as ciphertext)

**Interfaces:**
- Produces: sops-encrypted YAML with key `github_token`, decryptable
  only by the age key from Task 2 (i.e. only by
  `/etc/ssh/ssh_host_ed25519_key` on this host).
- Consumes: `.sops.yaml` from Task 2 (sops reads this automatically
  to pick the right key/recipients for the path).

**This task requires a real GitHub token — you (the user) do this
step, not the agent.**

- [ ] **Step 1: Create a GitHub personal access token**

Go to https://github.com/settings/tokens, create a token (classic or
fine-grained, no scopes needed for public repo reads). Copy the
value.

- [ ] **Step 2: Create and encrypt the secrets file**

Run: `mkdir -p secrets && nix run nixpkgs#sops -- secrets/secrets.yaml`

This opens `$EDITOR` on an empty buffer (sops creates the file since
it doesn't exist, using the rule in `.sops.yaml`). Enter:

```yaml
github_token: <paste your token here>
```

Save and exit. sops encrypts the file in place.

- [ ] **Step 3: Verify it's encrypted**

Run: `cat secrets/secrets.yaml`
Expected: YAML with `github_token: ENC[AES256_GCM,data:...]` — not the
plaintext token. If you see the plaintext token, stop and re-run Step
2; do not commit.

- [ ] **Step 4: Commit**

```bash
git add secrets/secrets.yaml
git commit -m "feat: add encrypted github_token secret"
```

---

### Task 4: Wire sops-nix into the NixOS config

**Files:**
- Create: `modules/features/secrets.nix`
- Modify: `modules/hosts/chapel.nix:9-27` (the `base` list)

**Interfaces:**
- Consumes: `inputs.sops-nix.nixosModules.sops` (Task 1),
  `secrets/secrets.yaml` (Task 3).
- Produces: `flake.modules.nixos.secrets`, added to `base` in
  `modules/hosts/chapel.nix` so it applies to every `chapel` build
  variant (`withNoctalia`, `withCaelestia`).
- At activation, produces `/run/secrets/github_token` (raw secret,
  root-only, mode 0400) and a rendered template file containing a
  `nix.conf`-format `access-tokens` line (path exposed as
  `config.sops.templates."nix-access-tokens.conf".path`).

- [ ] **Step 1: Write the secrets module**

Create `modules/features/secrets.nix`:

```nix
{inputs, ...}: {
  flake.modules.nixos.secrets = {config, ...}: {
    imports = [inputs.sops-nix.nixosModules.sops];

    sops.defaultSopsFile = ../../secrets/secrets.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

    sops.secrets.github_token = {};

    sops.templates."nix-access-tokens.conf".content = ''
      access-tokens = github.com=${config.sops.placeholder.github_token}
    '';

    nix.extraOptions = ''
      !include ${config.sops.templates."nix-access-tokens.conf".path}
    '';
  };
}
```

- [ ] **Step 2: Add `secrets` to the host's base module list**

In `modules/hosts/chapel.nix`, in the `base = with m; [ ... ];` list,
add `secrets` (alphabetically near `services` is fine, order doesn't
matter functionally):

```nix
  base = with m; [
    chapel
    home-manager
    sree
    core
    secrets
    services
    graphics
    gaming
    zen
    fonts
    appearance
    system-packages
    packages
    programs
    shell
    terminals
    xdg
    starship
    audio
    nvf
    spicetify
    opends5
    overlays
  ];
```

- [ ] **Step 3: Build (not switch) to verify it evaluates and builds**

Run: `sudo nixos-rebuild build --flake .#chapel 2>&1 | tail -40`
Expected: build succeeds, no eval errors about `sops` options or
missing `secrets/secrets.yaml`.

- [ ] **Step 4: Commit**

```bash
git add modules/features/secrets.nix modules/hosts/chapel.nix
git commit -m "feat: wire sops-nix and github_token into nix.conf"
```

---

### Task 5: Activate and verify

**Files:** none (verification only)

**Interfaces:**
- Consumes: everything from Tasks 1-4.

- [ ] **Step 1: Switch to the new configuration**

Run: `sudo nixos-rebuild switch --flake .#chapel 2>&1 | tail -40`
Expected: activation succeeds.

- [ ] **Step 2: Verify the raw secret exists and is root-only**

Run: `sudo ls -la /run/secrets/github_token`
Expected: file exists, mode `-r--------` (0400), owner `root`.

- [ ] **Step 3: Verify the rendered nix.conf fragment**

Run: `sudo cat /run/secrets-rendered/nix-access-tokens.conf`
Expected: one line, `access-tokens = github.com=<your real token>`.
Confirm this path is NOT under `/nix/store` (it shouldn't be — sops
templates render to `/run`, not the store).

- [ ] **Step 4: Confirm the token isn't in the Nix store**

Run: `grep -r "github_pat\|ghp_" /nix/store 2>/dev/null | head -5`
(adjust the grep pattern to match your token's prefix)
Expected: no output.

- [ ] **Step 5: Confirm the rate limit warnings are gone**

Run: `nix flake update 2>&1 | grep -i "rate limit\|403"`
Expected: no output (previously this printed multiple `403` /
`rate limit exceeded` warnings — see the design spec's Purpose
section).

- [ ] **Step 6: Commit the updated flake.lock from the verification run**

If Step 5's `nix flake update` changed `flake.lock` (it runs as a
real update), commit it:

```bash
git add flake.lock
git commit -m "chore: flake.lock update after sops-nix verification"
```

If nothing changed, skip this step.
