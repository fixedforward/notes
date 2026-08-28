---
name: plan-then-execute
description: |-
  DO NOT ASSUME — CLARIFY IF ANYTHING IS NOT CLEAR.
  Use this skill when the user wants a code change carried out against a real repository in a disciplined, incremental, Agile way instead of one big edit:
  - Explores the codebase and works inside an isolated git worktree
  - Writes a step-by-step execution plan with a manual test for every step
  - Implements and commits one step at a time, logging progress into the plan file
  Trigger on:
  - "plan this out first", "plan then execute", "break this into testable steps"
  - a request for a written implementation plan or a commit per step
  - working in a separate worktree
  Skip for:
  - a single trivial edit or pure Q&A
  - a request explicitly asking for one big change with no plan
---

# Plan Then Execute

## Overview

1. Confirm/create an isolated git worktree; make sure `.worktreeinclude` files are there.
2. Explore the codebase and its docs.
3. Write the execution plan to `plans/` in the **main repo**.
4. Confirm the plan with the user.
5. Per step: implement → hand off for manual test → on sign-off, commit → log → next step.

- If the desire, scope, base branch, or anything else is unclear: ask — don't assume.

## 1. Get into an isolated worktree

```bash
git rev-parse --path-format=absolute --git-dir          # this worktree
git rev-parse --path-format=absolute --git-common-dir    # shared git dir
```

- Equal paths → you're in the **main** worktree → create one:
  ```bash
  git worktree add -b <branch> <path> [<base-branch>]
  ```
  - Branch: `plan/<slug>` (kebab-case summary of the desire).
  - Path: a sibling of the main repo, not nested inside it — e.g. `<repo-parent>/<repo-name>-worktrees/<slug>`.
  - Base branch: current `HEAD` unless ambiguous — then ask.
- Different paths → already in a linked worktree — proceed.
- All exploration and implementation from here happens **inside the worktree**.
- Record for the plan: main repo path, worktree path, branch, base branch.

`.worktreeinclude` check (new or pre-existing worktree, either way):
- If the main repo root has no `.worktreeinclude` file → nothing to check, move on.
- If it has one (one path per line, `#` comments allowed — files git doesn't track but every worktree needs, e.g. `.env`, certs, IDE config), for each path:
  - Present in worktree → fine.
  - Missing from worktree, present in main repo → copy it over.
  - Missing from both → **stop**, tell the user which paths are unresolved, don't proceed until fixed.

## 2. Explore the codebase

- README/setup docs, directory layout, conventions near the change.
- Existing test/lint/build commands — for optional sanity-checks later, not a replacement for manual testing.
- Docs describing the area you'll touch — README, `docs/`, `CLAUDE.md`, `AGENTS.md` — needed for the plan's documentation-impact field.

## 3. Write the execution plan

- File: `plans/<YYYY-MM-DD>-<slug>.md` in the **main repo** (create `plans/` if needed).
- Structure: `assets/plan-template.md`.
- Each step needs:
  - A **change** specific enough that "done" is unambiguous.
  - A **manual test**: literal, concrete instructions (command/URL, action, exact expected result) — not "make sure it works."
  - One thing verified per step; split if a step covers two.
- Order steps so each leaves things in a working, demoable state.
- **Documentation impact**: decide if the desire makes README/`docs/`/`CLAUDE.md`/`AGENTS.md` stale, record the judgment in that plan field.
  - Yes → add it as the **last step**, after all code steps (docs should describe what actually got built).
  - No → write "none."
- Leave an empty `## Log` section at the end.

## 4. Confirm the plan

- Show the user the plan, get a go-ahead before implementing anything.
- Skip only if they've already said to proceed straight to execution.

## 5. Implement one step at a time

Never run ahead — one step, then stop and wait, every time.

1. **Implement** only that step, in the worktree.
2. **Sanity-check** with any existing fast lint/build/test command, if applicable — not a substitute for the manual test.
3. **Stop and hand off.** No commit or log yet. Give the user the manual test steps and wait.
   - Fails → fix in place (nothing committed yet), hand off again.
   - Signed off → continue.
4. **Commit** (one per step):
   ```bash
   git add -A
   git commit -m "<slug>: step <n> — <short title>"
   ```
5. **Log** — append, never edit past entries:
   ```markdown
   ### Step <n> — <title> — <timestamp>
   - Commit: `<short-sha>`
   - Summary: <what actually changed>
   - Manual test: <steps that were run>
   - Result: confirmed working by user
   ```
6. Move to the next step.

- If the codebase makes a planned step wrong mid-way: stop, explain, update the plan, get confirmation before continuing — don't improvise silently.

## When done

- Mark the plan's status `done`.
- Note the worktree still exists at `<path>` — keep it for a PR, or `git worktree remove <path>` once merged.
