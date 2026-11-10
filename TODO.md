# TODO

Open work, highest consequence first. Each item states the problem, the fix,
and the check that proves it is done. A finished item leaves this file: the
commit history records it.

## 1. Add an offline recipient to `.sops.yaml`

**Status:** agreed, deferred. chapel's SSH host key is backed up, and
bigrig's key is already a recipient (`08f0749`, `6d47bef`).

**Problem:** both recipients are machine identities derived from
`/etc/ssh/ssh_host_ed25519_key`. Confirm bigrig's key is also backed up. An
SSH host key also grants more than sops decryption; a dedicated age key does
one job.

**Fix:**
1. `age-keygen -o ~/age-recovery.txt`
2. Add the public key to `.sops.yaml` under `keys` and to the
   `secrets/secrets.yaml` key group.
3. `sops updatekeys secrets/secrets.yaml`
4. Store the private half off both machines (Bitwarden).

**Check:** `sops -d secrets/secrets.yaml` succeeds with only
`SOPS_AGE_KEY_FILE` set and no host key available.

## 2. Send one backup off site

**Problem:** every restic repository is a local path: `/mnt/backups`,
`/mnt/Vault` and `/mnt/bigdrive`. The USB archive is manual. One fire or one
theft takes every copy.

**Fix:** add one restic repository on a remote backend for the data that
cannot be made again.

**Check:** `restic snapshots` against the remote repository lists a snapshot
from the last day.

## 3. Turn off SSH password login on chapel

**Problem:** `modules/features/services.nix` opens port 22 and keeps the
NixOS default, which permits a password. bigrig is already keys-only.
chapel is not, because every login it gets is a password login from the LAN
and no client key is recorded.

**Fix:**
1. Add the public key of each client to
   `users.users.sree.openssh.authorizedKeys.keys` in a chapel aspect.
2. Copy the `settings` block from `modules/features/server-services.nix`.

**Check:** `ssh -o PubkeyAuthentication=no chapel` is refused.

## 4. Remove the `hello` test key from `secrets/secrets.yaml`

**Fix:** `sops unset secrets/secrets.yaml '["hello"]'`, with the age key
from the host key in `SOPS_AGE_KEY`.

## 5. Folder restructure

See `docs/folder-plan.md`.
