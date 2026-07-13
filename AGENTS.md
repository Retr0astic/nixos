# Agent Guide

This repository is Sree's personal NixOS flake. Treat it as a live machine
configuration: keep changes focused, preserve unrelated worktree changes, and
validate with Nix before reporting success.

## Repository Model

- `flake.nix` is the minimal flake-parts entry point.
- `modules/` is recursively imported.
- Public `.nix` files under `modules/` must be self-registering flake-parts modules.
- Underscore-prefixed paths contain private helpers and are excluded from recursive discovery.
- Typed `retr0astic` registries hold deferred NixOS and Home Manager modules.
- `hosts/chapel/` contains Chapel-specific lower-level/generated files.
- `modules/noctalia/` contains Noctalia assets and plugins.
- Task-specific plans under `docs/` are authoritative only for their exact scope and current approved phase.

Core registries:

```text
retr0astic.hosts
retr0astic.users
retr0astic.desktops
retr0astic.shells
retr0astic.themes
retr0astic.features
retr0astic.integrations
retr0astic.configurations
retr0astic.configurationAliases
```

## Start Every Task

1. Read applicable `AGENTS.md` files.
2. Run `git status --short`.
3. Identify and preserve unrelated changes.
4. Find the narrowest relevant entry points.
5. Check for an applicable approved plan under `docs/`.
6. Inspect only the files needed for the task.

A request to inspect, explain, diagnose, review, or plan does not authorize implementation edits.

Never commit, push, deploy, activate, reboot, delete data, or perform an irreversible operation unless explicitly requested.

## Task Classification

### Read-only

Examples: explanation, diagnosis, architecture inspection, repository exploration, review, planning, command suggestions, or verification without tracked-file edits.

Do not use the full implementation workflow. Use a read-only subagent only when targeted exploration or independent review materially improves the result.

### Trivial edit

All must be true:

- one obvious file;
- localized, mechanical change;
- no runtime or module-graph effect;
- no security, hardware, boot, storage, networking, authentication, or data implications;
- narrow validation is sufficient.

The primary thread may perform trivial edits directly.

### Non-trivial implementation

Includes multi-file changes; runtime or user-visible behavior changes; modules, services, packages, options, dependencies, tests, plugins, outputs; architecture or ownership changes; and NixOS, Home Manager, Hyprland, Noctalia, NVIDIA, UWSM, boot, kernel, storage, networking, authentication, permissions, or hardware changes.

Use the risk-based subagent workflow below.

## Risk-Based Subagent Workflow

The primary thread orchestrates non-trivial work. The configured implementer owns repository edits.

### Use an existing plan first

If an applicable, current, decision-complete plan exists, use it. Do not spawn the planner merely to restate it.

### Spawn the planner only when needed

Use the planner when the task changes:

- architecture or ownership boundaries;
- typed schemas;
- configuration generation;
- recursive importing;
- multi-phase migration sequencing;
- high-risk boot, storage, graphics, authentication, or recovery behavior.

For isolated implementation with an obvious design, skip planning.

A planner must return relevant files and symbols, ordered steps, risks and edge cases, acceptance criteria, and exact validation commands. The planner is read-only.

### Implementer

Use the implementer for every non-trivial edit.

Provide the user request, selected plan or concise implementation steps, repository instructions, current `git status --short`, unrelated changes to preserve, and exact validation commands.

The implementer should inspect only files named by the task or plan, their direct dependencies and consumers, and validation-relevant files.

The implementer must report files changed, behavior implemented, validation results, warnings/failures/skipped checks, deviations, and remaining risks.

### Reviewer

Do not run a full reviewer after every successful low-risk change.

Spawn the reviewer when:

- required validation fails;
- implementation deviates from the plan;
- ownership is ambiguous;
- schema, configuration generation, recursive imports, aliases, per-user composition, or desktop-shell separation changed;
- boot, storage, graphics startup, authentication, permissions, networking, or recovery behavior changed;
- a migration or feature is ready for final sign-off.

For a low-risk phase that passes all deterministic checks, skip the reviewer and report the results.

A successful build does not replace review for architectural or high-risk changes.

### Corrections and final review

When the reviewer reports medium- or high-severity findings:

1. send focused findings to the implementer;
2. rerun relevant validation;
3. run a final reviewer pass.

Do not declare reviewed work complete until material findings are resolved.

### Commit-only exception

When the user requests only a commit of already-authorized changes, use the implementer for staging and committing. Planner and reviewer are unnecessary unless explicitly requested.

## Delegation Failure

Attempt the configured subagent before declaring it unavailable.

If it fails:

1. record the exact runtime/tool error;
2. try an appropriate built-in read-only or writable agent;
3. if no writable runtime exists, request explicit approval before the primary thread performs a non-trivial edit.

Never claim a subagent ran when it did not.

## Token and Context Discipline

- Treat an applicable `docs/` plan as authoritative.
- Do not repeat a full repository audit for each phase.
- Prefer `rg`, `fd`, `git grep`, and targeted reads.
- Pass concrete planner findings to the implementer.
- Pass the actual diff and focused surrounding context to the reviewer.
- Keep reports to actionable findings, files changed, validation results, deviations, and unresolved risks.
- Do not restate unchanged architecture or paste large configuration blocks.

## Worktree Safety

- Run `git status --short` before delegation, before edits, and after edits.
- Preserve unrelated tracked and untracked changes.
- Never use destructive Git cleanup commands.
- Do not stage or commit unrelated files.
- Review the final diff before completion.
- Do not edit generated hardware configuration unless explicitly requested.
- Do not change `system.stateVersion`, `home.stateVersion`, or `flake.lock` unless the task requires it.

## Placement and Ownership

- Host-specific boot, LUKS, storage, hardware, monitor, and machine workarounds: host owner.
- Reusable NixOS/Home Manager functionality: `modules/features/`.
- Window manager or desktop-session behavior: `modules/desktops/`.
- Graphical shell functionality: `modules/shells/`.
- Visual styling: `modules/themes/`.
- Desktop-shell pair behavior: `modules/integrations/`.
- Personal identity, aliases, packages, startup, and personal rules: `modules/users/`.
- Noctalia config/plugins/assets: shell owner unless strictly visual.
- Private ordinary modules/package expressions: underscore-prefixed paths.

Do not add central import lists for ordinary components. Public modules register named values through `config.retr0astic.*`; configurations select names.

## Nix Style

- Two-space indentation.
- Preserve local ordering and minimize churn.
- Prefer compact, coherent modules over unnecessary abstractions.
- Public `.nix` files under `modules/` must be valid flake-parts modules.
- Ordinary NixOS/Home Manager modules and package expressions belong in private excluded paths.
- Capture application-specific inputs in their owning top-level module; avoid broad `specialArgs` or `extraSpecialArgs`.
- Keep desktop-shell compatibility in `retr0astic.integrations`.
- Do not reformat unrelated code.

## High-Risk Changes

Always require planning and review for boot, kernel, initrd, LUKS, storage, filesystems, hardware configuration, NVIDIA, graphics/display startup, Hyprland session, UWSM, authentication, permissions, networking, firewall, secrets, recovery, destructive migrations, and activation behavior.

Plans must address execution path, failure modes, rollback and recovery, login/boot/data-loss risk, test activation, and the known-working fallback.

Do not remove a fallback without explicit approval.

## Validation

Use the narrowest sufficient checks.

Always run:

```bash
git diff --check
nix flake check
```

Use targeted `nix eval` or tests where available.

Build the Chapel toplevel when `nix flake check` is insufficient:

```bash
nix build .#nixosConfigurations.chapel.config.system.build.toplevel --no-link
```

Prefer temporary activation before persistence:

```bash
sudo nixos-rebuild test --flake .#chapel
```

Run a persistent switch only when explicitly requested:

```bash
sudo nixos-rebuild switch --flake .#chapel
```

Never claim a command passed unless it ran successfully. Report warnings, failures, skipped checks, and what remains unverified.

## Shell Compatibility

The user's interactive shell is Fish.

- Prefer commands valid in Fish and POSIX-like shells.
- Use `env VAR=value command` for command-scoped variables.
- Use `fish -lc '...'` or `bash -lc '...'` when shell-specific syntax is needed.
- Do not rely on interactive aliases or abbreviations during validation.

## Documentation

- Keep README commands aligned with real flake outputs.
- Update docs for operator-visible behavior or command changes.
- Keep examples safe to copy.
- Keep Noctalia manifests, settings, entry points, plugins, and docs consistent.
- Do not add large generated logs.

## Final Handoff

Before completing implementation:

1. run `git status --short`;
2. review the actual diff;
3. confirm only intended files changed;
4. confirm unrelated changes remain;
5. run required validation;
6. complete review when required by the risk policy;
7. report planned and actual files changed, behavior implemented, validation results, review outcome when used, warnings/failures/deviations/remaining risks, and whether activation or reboot remains necessary.

Do not commit, push, deploy, activate, reboot, or perform irreversible actions unless explicitly requested.
