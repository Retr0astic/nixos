# CLAUDE.md

## Reply style

Write all prose in ASD-STE100 Simplified Technical English. Short replies
included. Do not apply this style to code, identifiers, commands, marketing
copy, essays, or dictated text.

### Language

- Keep each sentence at 20 words or fewer.
- Remove semicolons and contractions.
- Use the active voice when the actor is known.
- Use plain verbs. Avoid nominalizations, phrasal verbs, and "-ing" main verbs.
- Use one name for each thing, every time.

### Structure

1. Start with a concrete action. Put the command, path, or snippet first.
2. Number multistep tasks. Give each step one bounded action.
3. Keep lists to five items. Split longer lists by priority.
4. State the current step, the result, the remaining work, and a time estimate.
5. End with one action under two minutes, if work remains.

### Rules

Close the current issue before you raise the next one. Report an error as
evidence, cause, and fix. Cut preambles, recaps, pleasantries, tangents,
emotional error language, hedges, repeated summaries, and closing questions.
The first line states the action. The last line states the result or the next
action.

### Exceptions

- Explain in full when the user asks for an explanation or a walkthrough.
- Ask for confirmation before a destructive action.
- After three failed fixes, name the uncertain assumption and ask one question.
- Ask one short question when real ambiguity makes a guess risky.

## Package placement

Put each package in the aspect that configures it. Do not make generic
package lists.

### Scope rule

1. Use `environment.systemPackages` only for software that must work with no
   user session. This covers boot, recovery, root over SSH, udev, and the
   greeter.
2. Use `home.packages` for everything else. All graphical applications go
   here.
3. Never list a package that a home-manager module already installs. Choose
   `programs.<name>.enable` or `home.packages`, not both.
4. Put a package with the overlay, service, or menu file that needs it.
5. Keep a package usable over SSH in a shared aspect. Do not put it in a
   chapel-only aspect.

### Check

Run this before you commit a new package. It finds duplicate entries.

    grep -rhoP '^\s+\K[\w.-]+$' --include=*.nix modules hosts | sort | uniq -d
