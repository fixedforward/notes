# Claude Code output styles

Backup of my custom Claude Code output styles. Source of truth: `~/.claude/output-styles/`.

## Files

- [`aldostyle.md`](aldostyle.md) — `aldoStyle`: succinct bullet-point answers that teach with
  concrete examples, flow traces, bad-vs-better contrasts, analogies, quizzes, and optional
  diagrams. Lives at `~/.claude/output-styles/aldostyle.md`.

## What an output style is

A Markdown file with YAML frontmatter (`name`, `description`) whose body replaces Claude
Code's default system behaviour. Selected per project or globally via `/output-style` or the
`outputStyle` key in `settings.json`.

## Restore onto a new machine

```bash
mkdir -p ~/.claude/output-styles
cp AI/claude-output-styles/aldostyle.md ~/.claude/output-styles/
```

Then activate it with `/output-style aldoStyle`, or add `"outputStyle": "aldoStyle"` to
`~/.claude/settings.json`.
