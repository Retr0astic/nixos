# Agent Guide

This repository is Sree's NixOS flake. Treat it as a machine configuration
first: keep changes small, validate with Nix, preserve unrelated worktree
changes, and do not modify host- or hardware-specific settings without a clear
task requirement.

## Repository Structure

* `flake.nix` is the flake-parts entrypoint.
* `modules/` contains the recursively imported self-registering flake-parts
  modules and host composition.
* `modules/hosts/` owns host registrations, configurations, and aliases; typed
  reusable feature registrations live throughout the `modules/` tree.
* `hosts/chapel/` contains Chapel-specific NixOS and generated hardware
  configuration.
* `modules/features/`, `modules/desktops/`, `modules/home/`, and
  `modules/users/` contain coherent self-registering dendritic modules.
* `modules/noctalia/` contains Noctalia configuration and plugin files.
* `docs/dendritic-migration-plan.md` is the authoritative plan and status
  record for the dendritic architecture migration.

Every discovered `.nix` file under `modules/` is recursively imported and must
be a flake-parts registration module. Private helpers such as
`modules/packages/_nvf/package.nix` are excluded by the underscore path
convention. Typed `retr0astic`
registries hold deferred NixOS and Home Manager modules. Host-only leaves
remain in `hosts/chapel/`, including generated hardware configuration; non-Nix
assets are not imported.

## Start Every Task

Before inspecting or changing the repository:

1. Read all applicable `AGENTS.md` files.
2. Run `git status --short`.
3. Identify pre-existing and unrelated worktree changes.
4. Preserve all unrelated user changes.
5. Identify the narrowest relevant repository entrypoints.
6. Inspect existing conventions before proposing or implementing changes.

For migration work, identify the active phase and checkpoint in
`docs/dendritic-migration-plan.md` before editing. Treat its ownership map,
acceptance criteria, and validation commands as authoritative. Do not begin a
later phase until the document's checkpoint has been explicitly approved.

A request to inspect, diagnose, explain, plan, or review does not authorize
repository edits.

Do not commit, push, deploy, activate the system, delete data, or perform an
irreversible operation unless the user explicitly requests that operation.

## Task Classification

Classify every request before taking substantive action.

### Read-only task

A task is read-only when it asks only for:

* explanation;
* diagnosis;
* architecture assessment;
* repository exploration;
* code review;
* plan creation;
* command suggestions;
* documentation of existing behavior;
* verification that does not modify tracked files.

Read-only tasks do not require the full implementation workflow.

Use a read-only subagent when targeted repository exploration or independent
review would materially improve the answer.

### Trivial edit

A task is trivial only when all of the following are true:

* exactly one obvious file is affected;
* the change is localized and mechanically clear;
* no runtime behavior changes;
* no module graph, service, package, option, dependency, flake output, host
  output, test, deployment, or system behavior changes;
* no security, privacy, data integrity, recovery, hardware, boot, storage,
  networking, or authentication implications exist;
* validation is straightforward and narrowly scoped.

Examples include a spelling correction, comment correction, or formatting-only
change.

The primary thread may perform a trivial edit directly.

When uncertain whether a change is trivial, classify it as non-trivial.

### Non-trivial implementation task

A task is non-trivial when it involves one or more of the following:

* changes more than one file;
* changes runtime or user-visible behavior;
* adds or changes a module, service, package, option, dependency, test, script,
  plugin, flake output, host output, desktop integration, theme integration, or
  deployment path;
* requires repository exploration beyond one obvious file;
* fixes a behavioral bug or regression;
* introduces a new abstraction or changes architecture;
* modifies NixOS, Home Manager, Hyprland, Noctalia, NVIDIA, UWSM, boot, kernel,
  storage, filesystem, LUKS, networking, authentication, permissions, security,
  hardware, recovery, or data handling;
* can affect startup, login, graphics, networking, storage, recovery, system
  activation, or data integrity.

Every non-trivial implementation task must use the required subagent workflow.

## Editing Authority

For non-trivial implementation tasks, the primary thread is
orchestration-only.

The primary thread may:

* classify the task;
* inspect repository status;
* provide context to subagents;
* reconcile findings;
* monitor progress;
* summarize results;
* request corrections;
* report validation and risks.

The primary thread must not:

* edit repository files;
* apply patches;
* perform implementation work assigned to `implementer`;
* silently replace a failed delegation attempt with direct editing;
* claim a subagent was used when no subagent thread was created.

All non-trivial repository edits must be performed by the configured
`implementer` subagent.

## Required Subagent Workflow

For every non-trivial implementation task, the primary thread must
automatically execute this workflow without waiting for the user to request
delegation.

Commit-only exception: when the user explicitly requests only a commit of
already-authorized current changes, use the `implementer` only. The implementer
handles staging and commit, and the planner, reviewer, corrections, and
final-review stages are skipped unless the user explicitly requests them.

### 1. Planner

Spawn the configured `planner` agent before any repository edit.

Provide the planner with:

* the original user request;
* applicable repository instructions;
* current `git status --short`;
* known unrelated worktree changes;
* relevant prior findings;
* any explicit user constraints.

The planner must return a decision-complete plan containing:

* task classification and rationale;
* relevant files and execution paths;
* affected modules, options, functions, or symbols;
* ordered implementation steps;
* risks and edge cases;
* rollback or recovery considerations when applicable;
* acceptance criteria;
* exact verification commands.

The planner is read-only.

Wait for the planner to finish before continuing.

### 2. Plan assessment

The primary thread must inspect the planner's result before implementation.

Resolve:

* contradictions with the user request;
* conflicts with applicable `AGENTS.md` files;
* unsafe or unnecessarily broad changes;
* missing validation;
* incorrect file placement;
* conflicts with pre-existing worktree changes.

Tell the user which files are expected to change before the first edit.

Do not implement the plan in the primary thread.

### 3. Implementer

Spawn the configured `implementer` agent.

Provide it with:

* the original user request;
* the complete planner output;
* any corrections made during plan assessment;
* applicable `AGENTS.md` instructions;
* current worktree status;
* known unrelated user changes;
* required validation commands.

Only `implementer` may edit files for a non-trivial task.

The implementer must:

* follow the approved plan;
* inspect local conventions before editing;
* preserve unrelated worktree changes;
* make focused changes;
* update tests and documentation when required;
* run the required validation;
* report files changed;
* report behavior implemented;
* report commands and tests run;
* report failures, warnings, and skipped checks;
* report deviations from the plan;
* report remaining concerns.

Wait for the implementer to finish.

### 4. Reviewer (unless skipped by the commit-only exception)

After implementation, spawn the configured `reviewer` agent.

Provide it with:

* the original user request;
* the approved plan;
* the implementer's report;
* the actual repository diff;
* validation output;
* applicable repository instructions.

The reviewer must inspect:

* the actual diff;
* relevant surrounding code;
* compliance with the original request;
* compliance with the approved plan;
* compliance with applicable `AGENTS.md` files;
* correctness;
* regressions;
* security and privacy;
* data integrity;
* recovery and rollback implications;
* error handling;
* test coverage;
* validation quality;
* unnecessary scope or churn.

The reviewer is read-only.

Findings must include:

* severity;
* concrete file path and location;
* failure mode or impact;
* evidence;
* recommended correction.

Wait for the reviewer to finish.

### 5. Corrections (when a reviewer was used)

When the reviewer reports material findings:

1. Reuse or spawn `implementer` with the reviewer findings.
2. Require focused corrections only.
3. Require repeated relevant validation.
4. Preserve unrelated worktree changes.
5. Wait for implementation to finish.

The primary thread must not apply reviewer corrections directly.

### 6. Final review (when a reviewer was used)

After corrections, spawn `reviewer` again.

The final reviewer must verify:

* all material findings were resolved;
* no regressions were introduced;
* validation is sufficient;
* the final diff still matches the approved scope.

For tasks using the reviewer workflow, do not declare the task complete until
the final review finishes or a concrete tool or configuration error prevents
review. Commit-only tasks may complete after the implementer reports the
commit and required validation.

## Delegation Failure Handling

Do not infer that subagents are unavailable merely because delegation was not
attempted automatically.

Before using any sequential fallback:

1. Attempt to spawn the required configured subagent.
2. Confirm an actual tool, runtime, configuration, or model error occurred.
3. Report the exact failure.

When a configured custom agent fails to spawn, attempt an appropriate built-in
agent when available:

* use a read-only explorer or reviewer for planning and inspection;
* use a writable worker for implementation only when its permissions and scope
  are appropriate.

If no subagent runtime is genuinely available:

* state this clearly;
* do not claim that subagents were used;
* preserve the same planning, implementation, and review separation;
* request explicit user approval before the primary thread performs a
  non-trivial edit.

## Subagent Boundaries

* `planner` is read-only.
* `reviewer` is read-only.
* `implementer` owns all non-trivial repository edits.
* Subagents must not spawn additional subagents.
* The primary thread must orchestrate all transitions.
* Never allow multiple agents to edit concurrently.
* Subagents must return concrete file paths, relevant symbols or options,
  repository evidence, validation results, and unresolved risks.
* The primary thread must reconcile conflicting findings before implementation
  continues.
* Do not delegate secrets, credentials, private keys, destructive commands,
  live system switches, or irreversible operations.
* Do not send credentials or secret values in subagent prompts.

## Token and Context Discipline

* Read only files needed for the task.
* Do not scan the whole repository unless architecture-level understanding is
  required.
* Prefer `rg`, `fd`, `git grep`, and targeted reads over recursive dumps.
* Identify likely entrypoints from `flake.nix`, the nearest `default.nix`, or
  the relevant module path before opening many files.
* Summarize inspected code instead of pasting large blocks.
* Do not repeat unchanged configuration.
* Show only patches, commands, or small relevant excerpts.
* Keep delegated tasks narrowly scoped.
* Do not ask multiple subagents to repeat the same broad repository scan.
* Pass concrete planner findings to the implementer instead of requiring the
  implementer to rediscover the entire architecture.
* Pass the actual diff and focused surrounding context to the reviewer.

## Shell and Command Compatibility

* The user's interactive shell is Fish.
* Prefer commands that work unchanged in Fish and POSIX-like shells.
* Use Fish syntax when editing Fish configuration, functions, abbreviations, or
  interactive shell behavior.
* Do not assume Bash-only syntax such as:

  * `VAR=value command`;
  * `export VAR=value`;
  * `$(command)`;
  * `[[ ... ]]`;
  * Bash arrays;
  * process substitution.
* Prefer `env VAR=value command` for command-scoped environment variables.
* When shell-specific syntax is necessary, invoke the shell explicitly:

  * `fish -lc '...'` for Fish;
  * `bash -lc '...'` for Bash.
* Do not rely on interactive aliases, abbreviations, or functions during
  validation.
* Prefer executable scripts with an appropriate shebang for complex multi-line
  shell logic.
* Commands shown to the user should be Fish-compatible unless explicitly
  labeled for another shell.

## Worktree Safety

* Preserve all unrelated user changes.
* Never revert, overwrite, stage, or commit changes unrelated to the task.
* Do not use destructive Git commands to clean the worktree.
* Run `git status --short` before delegation, before editing, and after editing.
* Review the final diff before completion.
* Stage, commit, or push only when explicitly requested.
* Do not modify untracked files unless the task requires them.
* Do not assume an untracked file is disposable.
* Do not overwrite a user-modified file without first inspecting its current
  contents.

## Change Placement

* Put host-only boot, LUKS, hostname, kernel, and generated hardware settings in
  `hosts/chapel/`.
* Put common NixOS packages and Nix settings in the owning feature under
  `modules/features/`.
* Put system services in `modules/features/` self-registering service modules.
* Put user packages, shell, terminals, applications, and XDG settings in the
  corresponding self-registering modules under `modules/home/`.
* Put Hyprland user settings in self-registering modules under
  `modules/desktops/`.
* Put Noctalia shell and theme integrations in self-registering modules under
  `modules/shells/` and `modules/themes/`.
* Keep Noctalia plugin manifests, settings, QML entrypoints, shell scripts,
  images, JSON, and translation files synchronized.

## Nix Style

* Follow the existing compact Nix style.
* Use two-space indentation.
* Prefer grouped option sets and short modules.
* Do not import ordinary local NixOS/Home Manager modules from another module;
  make each `.nix` file under `modules/` self-register its typed deferred value.
* Register desktop implementations under `modules/desktops/` and themes under
  `modules/themes/` through the typed `retr0astic` registries. Pair-specific
  compatibility belongs in `retr0astic.integrations`; do not use parallel
  compatibility records or arbitrary `self.modules` entries.
* Alphabetize package lists only when the surrounding list is already
  alphabetized.
* Otherwise preserve local ordering and minimize churn.
* Use `with pkgs; [ ... ]` consistently where the surrounding module already
  uses it.
* Avoid unnecessary abstractions for configuration used only once.
* Do not change `system.stateVersion` or `home.stateVersion` unless explicitly
  requested.
* Do not edit `flake.lock` unless input updates are part of the task.
* Do not rewrite generated hardware configuration unless explicitly requested.

## High-Risk Changes

The following areas always require the full subagent workflow:

* boot;
* kernel;
* initrd;
* LUKS;
* storage;
* filesystems;
* hardware configuration;
* NVIDIA;
* graphics and display startup;
* Hyprland session startup;
* UWSM;
* authentication;
* permissions;
* networking;
* firewall;
* secrets;
* recovery;
* destructive migrations;
* system activation behavior.

For these changes, the planner must explicitly address:

* current execution path;
* expected failure modes;
* rollback procedure;
* recovery procedure;
* data-loss risk;
* login or boot-loss risk;
* whether a reboot is required;
* whether a test activation is possible;
* which known-working fallback must remain available.

Do not remove a known-working fallback without explicit approval.

## Validation

Run the narrowest useful validation after edits.

Start with:

```bash
nix flake check
```

Do not run heavier builds when `nix flake check` sufficiently evaluates the
affected output.

For system-level changes not sufficiently covered by `nix flake check`, build
the Chapel toplevel when practical:

```bash
nix build .#nixosConfigurations.chapel.config.system.build.toplevel
```

Before suggesting a persistent switch, prefer a test activation:

```bash
sudo nixos-rebuild test --flake .#chapel
```

Use a persistent switch only when explicitly requested:

```bash
sudo nixos-rebuild switch --flake .#chapel
```

Additional validation requirements:

* run `git diff --check`;
* use targeted evaluation or tests when available;
* do not claim a command succeeded when it was not run;
* do not hide failed validation behind successful unrelated checks;
* report warnings and failures;
* report skipped checks and why they were skipped;
* identify what remains unverified;
* do not perform a live switch merely to validate configuration.

## Documentation

* Keep README command examples aligned with actual flake outputs.
* Update documentation when operator-visible behavior or commands change.
* Keep examples safe to copy.
* Do not add large generated logs or diagnostic dumps.
* Ensure Noctalia manifests, settings, entrypoints, and documentation remain
  consistent when plugin behavior changes.

## Repository Notes

* The default host is `chapel`.
* `chapel-hyprland-noctalia` is an alias for the same host.
* The branch workflow in `README.md` references `testing`; do not assume changes
  belong on another branch.
* Prefer small, reviewable diffs.
* Do not reformat unrelated code.
* Do not introduce a new dependency when an existing repository mechanism is
  sufficient.
* Do not add tokens, passwords, credentials, private keys, or machine secrets to
  tracked files.

## Final Handoff

Before completing any implementation task:

1. Run `git status --short`.
2. Review the actual diff.
3. Confirm only intended files changed.
4. Confirm unrelated worktree changes remain intact.
5. Confirm required validation was run.
6. Confirm the final reviewer completed, unless the commit-only exception
   applies.
7. Resolve or explicitly document every material finding, when a reviewer was
   used.
8. Report:

   * planned files;
   * actual files changed;
   * behavior implemented;
   * validation commands and results;
   * review outcome;
   * failures or warnings;
   * deviations from the plan;
   * remaining risks;
   * whether activation or reboot is still required.

For migration tasks, update `docs/dendritic-migration-plan.md` after the task
has passed validation and review: record the completed phase, summarize the
actual files and behavior changed, preserve the next-phase checkpoint as
pending approval, and keep the document status consistent with the repository.

Do not commit, push, deploy, activate, reboot, or perform an irreversible action
unless explicitly requested.
