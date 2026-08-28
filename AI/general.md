# General

## Skills
- Skills are repeatable instructions you can invoke using `/`
- All AI configs is under `~/.config` in your computer
- All AI skills accessible by both OpenRouter and Copilot `~/.agents/skills` in your computer

## Agents.md vs. .instruction files
- They are the same; `agents.md` are used cross-models, while `.instruction` files are for Copilot only. These are project files.

## Hooks
- Commands that will run (deterministically i.e. for sure) on certain points during AI answering your questions
- No cross-model setup is available yet at time of writing this doc

## Best practices
- The context window is limited and answers get worse as it fills. Keep it clean.
  - Give investigations a clear scope, or the agent reads hundreds of files.
  - Delegate wide searches so those file reads don't fill your main context.
- Work in order: explore, plan, code, commit. Plan first when you're unsure of the approach or the change touches many files. Skip it for small, obvious changes.
- Be specific: name the file, the case, the constraint, and an example to copy. Fewer corrections later.
- Prefer CLI tools (`gh`, `aws`, `gcloud`); they use less context than other integrations.
- Before calling it done, review the diff against the plan with fresh eyes. Report only real bugs or missing requirements, not style.
- Common mistakes: mixing many tasks in one session, correcting in circles, an overlong instructions file, shipping without verifying, unscoped exploration.

### Prompting
- A prompt is either a **command** or a **question**.
- For a **command**, give the model a way to check its own work. Otherwise it stops when the result *looks* done and you have to catch every mistake.
  - **UI change**: give it the target design, then have it implement, screenshot, compare to the original, and keep fixing until they match.
  - **Non-UI change**: decide the check first: a test with example inputs/outputs, or a command that must succeed (build, lint, script). Have it run the check and repeat until it passes.
  - Ask for proof (test output, the command and its result, a screenshot), not just "done".
- Use `@` to point at files or logs (`@src/auth/token.ts`, `@logs/run.log`) instead of explaining where things are; the file is read first. Same idea: paste images, give doc URLs, or pipe data in.

# Claude

## Skills
- Skills must be in `~/.claude/skills`. Symlink to `~/.agents/skills` to keep one copy.
- To auto-invoke a skill on every prompt, add `~/.claude/CLAUDE.md` and tell it to run that skill every time.

## Best practices remember this
- Use @ to refer to specific file for rich context
- Use `ctrl G` to write a long prompt easily in Vim
- `/clear` between unrelated tasks.
- Keep project rules in `CLAUDE.md` (build commands, style, test runner, gotchas). Keep it short; a long one gets ignored. Occasional knowledge goes in a skill instead.
- Enforce a check, ask for it in the prompt
  - If visual change, give a desired picture, ask it to implement, then ask it to compare and redo if not the same
  - If not visual, ask it to execute a command and verify the command works
- Configure output styles to reduce verbosity and make it output in a style you understand
- Docs: https://code.claude.com/docs/en/best-practices

# Copilot

## Instruction files
- For Rider Github copilot, put your `instruction` files in `/Users/aldo.sebastian/.config/github-copilot/intellij/` so it is usable in any repo

## Hooks
- Docs: `https://docs.github.com/en/copilot/concepts/agents/cloud-agent/about-hooks`
- Example:
```copilot-example
{
  "version": 1,
  "hooks": {
    "agentStop": [
      {
        "type": "command",
        "bash": "osascript -e 'display notification \"AI is done!\" with title \"Hey\"'"
      }
    ]
  }
}

```

## Costs
- https://github.com/SachiHarshitha/copilot-usage to check your copilot usage by scanning your logs. When installing, put `README.md` on the `apps/cli` folder

### Request vs. usage based billing
- Before 1 June 2026, `$39` (for enterprise) includes 1000 requests
  - Multipliers like Opus 4.6 (3x) means each request using Opus 4.6 is counted as 3 requests
- After 1 June 2026, `$39` includes 3900 AI credits
  - 1 AI credit = `$0.01` USD
  - The usage is following this (table)[https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing#pricing-tables]
  - Example calculation: (here)[https://docs.google.com/document/d/1nyymCr3jOVCT9hE5ttGL_Q8TKBgEcs1SlqRnLSJDuvw/edit?usp=sharing]

### How to reduce costs
- Use models with cache inputs and outputs
  - Since this means that subsequent requests who uses the same resource (e.g. a follow up question to explaining a codebase) reduces the token costs for those words for that request.
  - Although, cache inputs means on the first request you need to write the context(s) to a cache, and that may incur `cache write` costs (this only applies for Anthropic harness, but may be the case for
  copilot in the future)
- Quick mental model
  - 75000 words in input (prompt + all sources used) using Claude Opus 4.6  ~ 100000 tokens => $0.5 => 50 AI credits
  - 800 to 1000 lines of code ~ 100000 tokens
  - 1 word ~ 0.75 tokens
  - 1-2 sentences ~ 30 tokens
  - 1 paragraph ~ 150 tokens
- So then if every request i have a 100000 token input then 0.5 per request at least = 50 ai credits, less than 80 requests I would've exhausted everything for enterprise plan (3900 AI Credits)
  - If you include the initial Cache Write fee ($1.125$) or any output tokens, that number drops even lower
  - Before June, you were encouraged to dump as much context as possible into the chat because it was "free."
  - Now, you are financially penalized for including large files that aren't strictly necessary.
  - So TLDR/rule of thumb: in new pricing model you must be more careful on the no. of stuff you put in as context! Only put in necessary stuff
    - This has always been the best-practice anyway (to avoid hitting the context window limit), but now we have an extra (monetary) reason, on top of performance reasons.
    - This also means though, we have to use less hooks/skills/extra helpers on our chat session to keep costs low :( .
  - Prompt Caching: This is the only way to "beat" the system. If you stay in one chat session and ask 20 questions about the same 100k file, your total cost is only about $1.60. In the old system, those 20 questions would have used 2% of your entire monthly quota.
- So, if your workflow is "One complex question per project," this new pricing (usage based vs. request based) is significantly more expensive.
- If your workflow is "Long, iterative debugging sessions on the same file," the pricing stays roughly the same or even gets slightly better thanks to caching.
