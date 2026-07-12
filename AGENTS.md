# Agent Guide

This repository is Sree's NixOS flake. Treat it as a machine configuration
first: keep changes small, validate with Nix, and do not rewrite hardware- or
host-specific settings unless the user explicitly asks.

## Repository Shape

* `flake.nix` is the flake-parts entrypoint. It imports modules under `flake/`
  through `lib/treeimport.nix`.
* `flake/hosts.nix` owns host composition. Add desktops, themes, host aliases,
  and `mkHost` changes there.
* `hosts/chapel/` contains Chapel-specific NixOS configuration and generated
  hardware configuration.
* `modules/nixos/` contains reusable system modules.
* `modules/home/` contains reusable Home Manager modules for user `sree`.
* `modules/home/desktops/` contains desktop-specific Home Manager settings.
* `modules/home/themes/` contains theme integrations.
* `modules/noctalia/` contains Noctalia configuration and plugin files.
* `configuration.nix` is only a compatibility shim importing `hosts/chapel`.

## Start Every Task

1. Read all applicable `AGENTS.md` files.
2. Run `git status --short`.
3. Preserve unrelated and pre-existing worktree changes.
4. Identify the narrowest relevant entrypoints before opening files broadly.
5. Inspect existing implementation and conventions before proposing changes.
6. Do not commit, push, deploy, switch the live system, delete data, or perform
   irreversible operations unless explicitly requested.

A request to inspect, diagnose, review, or explain does not authorize edits.

## Token and Context Discipline

* Read only files needed for the task.
* Do not scan the entire repository unless architecture-level understanding is
  genuinely required.
* Prefer `rg`, `fd`, `git grep`, and targeted reads over recursive dumps.
* Before opening many files, identify likely entrypoints from `flake.nix`, the
  nearest `default.nix`, or the relevant module path.
* Summarize inspected code instead of pasting large blocks into the response.
* Do not repeat unchanged configuration.
* Show only patches, commands, or small relevant excerpts.
* For large changes, work in narrowly scoped phases.
* Keep final responses focused on:

  * what changed;
  * why it changed;
  * validation performed;
  * failures or warnings;
  * deviations from the plan;
  * remaining risks.

## Required Subagent Workflow

For every non-trivial code or configuration change, the primary agent must
automatically use the configured subagents without waiting for the user to
request delegation.

Required sequence:

1. Run `git status --short`.
2. Spawn `planner` before any edit.
3. Wait for a decision-complete plan containing:

   * task classification and rationale;
   * relevant files and execution paths;
   * ordered implementation steps;
   * risks and edge cases;
   * acceptance criteria;
   * exact verification commands.
4. Tell the user which files are expected to change before the first edit.
5. Spawn `implementer` with:

   * the original user request;
   * the planner's completed plan;
   * applicable repository instructions;
   * known worktree constraints.
6. Wait for implementation and validation to finish.
7. Spawn `reviewer` to inspect:

   * the actual diff;
   * relevant surrounding code;
   * the original request;
   * the planner's plan;
   * applicable `AGENTS.md` instructions;
   * tests and validation output.
8. Send all material reviewer findings back to `implementer`.
9. Wait for focused corrections and repeated validation.
10. Spawn `reviewer` again for final verification.
11. The primary agent must reconcile the results and report:

    * files changed;
    * behavior implemented;
    * commands and tests run;
    * review status;
    * deviations from the plan;
    * failures or warnings;
    * unresolved risks.

The primary agent must orchestrate every transition. Subagents must not spawn
other subagents.

Never allow multiple agents to edit concurrently.

### Mandatory Delegation

The workflow is mandatory when a task:

* changes more than one file;
* changes runtime or user-visible behavior;
* adds or changes a module, service, package, test, flake output, host output,
  desktop integration, theme integration, or deployment behavior;
* requires repository exploration beyond one obvious file;
* fixes a non-obvious bug or regression;
* changes NixOS, Home Manager, Hyprland, Noctalia, NVIDIA, UWSM, boot, kernel,
  storage, filesystems, LUKS, networking, authentication, permissions, security,
  or hardware behavior;
* could affect system startup, login, graphics, networking, storage, recovery,
  or data integrity.

### Direct Work Exceptions

The primary agent may work directly only for:

* factual questions with no repository changes;
* read-only inspection or explanation;
* trivial spelling, comment, or formatting corrections confined to one file;
* one obvious line change with no behavioral, deployment, security, hardware,
  or recovery impact;
* tasks where the user explicitly requests no delegation.

When uncertain whether a change is trivial, use the subagent workflow.

### Subagent Boundaries

* `planner` is read-only and must not edit files.
* `reviewer` is read-only and must not edit files.
* Only `implementer` may edit files unless the user explicitly requests another
  arrangement.
* Subagents must return concrete file paths, relevant symbols or options,
  repository evidence, verification results, and unresolved risks.
* The primary agent must resolve conflicting findings before further edits.
* Do not delegate secrets, credentials, destructive commands, live system
  switches, or irreversible operations.
* Do not claim a subagent was used unless a real subagent thread was created.
* If subagents are unavailable, state that plainly and perform the same planning,
  implementation, and review stages sequentially in the primary thread.

## Worktree Safety

* Preserve all unrelated user changes.
* Do not revert, overwrite, stage, or commit changes that were not created for
  the current task.
* Do not use destructive Git commands to clean the worktree.
* Review `git diff` and `git status --short` before and after editing.
* Stage or commit files only when explicitly requested.
* Do not push unless separately requested.

## Change Placement

* Put host-only boot, LUKS, hostname, kernel, and generated hardware settings in
  `hosts/chapel/`.
* Put common NixOS packages and Nix settings in
  `modules/nixos/core/default.nix`.
* Put system services in `modules/nixos/services/default.nix`.
* Put user packages in `modules/home/packages/default.nix`.
* Put shell aliases and CLI integrations in
  `modules/home/shell/default.nix`.
* Put terminal packages and configuration in
  `modules/home/terminals/default.nix`.
* Put Home Manager application modules under `modules/home/programs/` and
  import them from `modules/home/programs/default.nix`.
* Put XDG MIME and user-directory settings in
  `modules/home/xdg/default.nix`.
* Put Hyprland user settings in
  `modules/home/desktops/hyprland.nix`.
* Put Noctalia Home Manager integration in
  `modules/home/themes/noctalia.nix`.
* Keep Noctalia plugin manifests, settings, QML entrypoints, scripts, images,
  JSON, and translation files synchronized when changing a plugin.

## Nix Style

* Follow the existing compact Nix style.
* Use two-space indentation.
* Prefer grouped option sets and short modules.
* Prefer explicit imports from the nearest `default.nix` for
  `modules/home/*` and `modules/nixos/*`.
* For new desktop or theme variants, register them in `flake/hosts.nix` before
  adding host outputs.
* Keep package lists alphabetized only when the surrounding list is already
  alphabetized.
* Otherwise preserve local ordering and minimize churn.
* Use `with pkgs; [ ... ]` consistently where the surrounding module already
  uses it.
* Avoid unnecessary abstractions for configuration used only once.
* Do not change `system.stateVersion` or `home.stateVersion` unless explicitly
  requested.
* Do not edit `flake.lock` unless updating inputs is part of the task.
* Do not rewrite generated hardware configuration unless explicitly requested.

## Risk-Specific Requirements

For NixOS, Hyprland, NVIDIA, UWSM, boot, kernel, LUKS, filesystem, storage, or
hardware changes:

* inspect the current configuration and relevant execution path before editing;
* identify rollback or recovery considerations in the plan;
* avoid removing known-working fallback configurations without approval;
* require an independent post-change review;
* prefer evaluation and build validation before any live activation;
* never perform a live switch unless the user explicitly asks.

For boot, storage, encryption, filesystem, or recovery-related changes, the plan
must explicitly address:

* failure mode;
* rollback path;
* data-loss risk;
* recovery environment requirements;
* whether rebooting is required.

## Validation

Run the narrowest useful validation after edits.

Start with:

```bash
nix flake check
```

Do not run a heavier build when `nix flake check` sufficiently evaluates the
affected output.

For system-level changes not sufficiently covered by `nix flake check`, build
the Chapel toplevel when practical:

```bash
nix build .#nixosConfigurations.chapel.config.system.build.toplevel
```

Before suggesting a live switch, prefer a test activation:

```bash
sudo nixos-rebuild test --flake .#chapel
```

Use a persistent live switch only when explicitly requested:

```bash
sudo nixos-rebuild switch --flake .#chapel
```

Additional validation rules:

* Run `git diff --check` after edits.
* Use targeted evaluation or tests when available.
* Do not claim validation succeeded when a command was not run.
* If a check cannot be run, state:

  * which check was skipped;
  * why it could not run;
  * what remains unverified.
* Report warnings and failures honestly.
* Do not hide a failed check behind successful unrelated checks.

## Documentation

* Keep README command examples aligned with actual flake outputs.
* Update documentation when operator-visible commands or behavior change.
* Do not add large generated output or diagnostic dumps to documentation.
* Keep examples safe to copy and consistent with the repository's real host and
  output names.

## Workflow Notes

* The default host is `chapel`.
* `chapel-hyprland-noctalia` is an alias for the same host.
* The active branch workflow in `README.md` references `testing`; do not assume
  commits belong on another branch.
* Prefer small, reviewable diffs over broad rewrites.
* Do not modify unrelated formatting merely because a file is open.
* Do not introduce a new dependency when an existing repository mechanism is
  sufficient.
* Do not add credentials, tokens, machine secrets, private keys, or environment
  values to tracked files.

## Final Handoff

Before completing an implementation task:

1. Review `git status --short`.
2. Review the actual diff.
3. Confirm only intended files changed.
4. Confirm unrelated worktree changes remain untouched.
5. Run the required validation.
6. Confirm reviewer findings were resolved or clearly documented.
7. Report:

   * expected and actual files changed;
   * behavior implemented;
   * validation commands and results;
   * review outcome;
   * warnings or failures;
   * remaining risks;
   * whether a live switch or reboot is still required.

Do not commit, push, deploy, or activate the configuration unless explicitly
requested.

