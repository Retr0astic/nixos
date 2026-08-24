# sops-nix secrets management — design

Date: 2026-08-24
Status: approved, pending implementation plan

## Purpose

`nix flake update` hits GitHub's unauthenticated API rate limit (60
requests/hour). A GitHub token raises the limit. The repo has no
secrets manager, so this design adds one (sops-nix) and uses it to
store the token. Future secrets reuse the same pipeline.

## Decisions

- Tool: sops-nix (not agenix). Reuses a single encrypted YAML file,
  has editor integration (`sops edit`), and is the more common choice
  in NixOS flake configs.
- Key: derive the age decryption key from the host's existing SSH
  host key (`/etc/ssh/ssh_host_ed25519_key`). No separate key file to
  generate or back up. Tradeoff: losing the SSH host key (e.g. host
  reinstall without backup) loses access to the secrets — acceptable,
  since this is a single-host config and the SSH key is already a
  single point of failure for other things (e.g. remote access).
- Scope: first pass stores one secret, `github_token`, consumed at
  the system level (Nix daemon config). User-session secrets (owned
  by `sree`, placed under the home directory) are supported by
  sops-nix but not set up now — no concrete secret needs it yet. Add
  later the same way this one is added.

## Components

1. **Flake input** — `sops-nix`, `inputs.nixpkgs.follows = "nixpkgs"`,
   added to `flake.nix` alongside the other inputs.
2. **NixOS module import** — the sops-nix NixOS module, wired in
   through the existing `flake-parts`/`import-tree` module
   aggregation (matches how other modules under `modules/` are
   picked up — confirmed during planning).
3. **`.sops.yaml`** at repo root — creation rules mapping secret file
   paths to the age public key(s) allowed to decrypt them. Contains
   the host's SSH-derived age public key.
4. **`secrets/secrets.yaml`** — sops-encrypted YAML, committed to
   git as ciphertext. First key: `github_token`.
5. **Secrets module** (new file, `modules/features/secrets.nix` or
   folded into `modules/features/core.nix` — decided during planning)
   — declares:
   - `sops.defaultSopsFile = ../../secrets/secrets.yaml;` (path
     relative to module)
   - `sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];`
   - `sops.secrets.github_token = {};`
6. **Wiring the token into Nix's GitHub API auth** — the decrypted
   secret lands at `/run/secrets/github_token` at boot, root-only,
   never in the Nix store. Nix needs it as
   `access-tokens = github.com=<token>` in `nix.conf`. Mechanism:
   `nix.extraOptions` referencing the secret via a generated
   snippet, or a `sops.templates` entry that renders a small
   `nix.conf`-format fragment and points `nix.extraOptions` at
   `!include <rendered path>`. Exact approach finalized in the
   implementation plan — both keep the raw token out of the Nix
   store and out of git.

## Day-to-day use

- `sops secrets/secrets.yaml` — decrypts to `$EDITOR`, re-encrypts on
  save. Requires the host SSH key readable by the invoking user (or
  `sudo`), since decryption happens against that key.
- `secrets/secrets.yaml` is safe to commit; it is ciphertext.
- Adding a secret: add a `key: value` line to the yaml via `sops
  edit`, add a matching `sops.secrets.<name> = {};` line in the
  secrets module, rebuild.

## Out of scope

- User-session secrets (home-directory-owned, per-user) — no
  concrete need yet.
- Multi-host key management — single host (`chapel`) only.
- Secret rotation automation.

## Testing

- After implementation: `sudo nixos-rebuild switch`, confirm
  `/run/secrets/github_token` exists, root-only permissions.
- Confirm `nix.conf` (or the generated fragment) contains the
  `access-tokens` line without the plaintext token appearing in
  `nix store show-derivation` output or the world-readable Nix
  store.
- Run `nix flake update` and confirm the GitHub rate-limit warnings
  are gone.
