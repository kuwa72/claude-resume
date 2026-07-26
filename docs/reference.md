# Reference

Complete technical description of `claude-resume`: commands, environment
variables, installed files, the helper scripts' I/O contract, and exit codes.

## Commands

### `claude-resume`

Lists the Claude Code sessions **for the current project directory** in an fzf
picker, then `cd`s into the chosen session's working directory and runs
`claude -r <session-id>`.

"Current project" is resolved by encoding `$PWD` the way Claude Code names its
project log directories: every `/` and `.` becomes `-`. The result is looked up
under `~/.claude/projects/<encoded>/`.

- If that directory does not exist: prints a message and exits `1`.
- If you pick nothing (Esc): exits `0` without resuming.

### `claude-resume --all`

Same as above, but lists sessions from **every** project under
`~/.claude/projects/*/`. Use it when the session you want was started in a
different directory.

If there are no projects at all, the picker is empty; selecting nothing exits `0`.

### `ccr` (short alias)

A convenience wrapper that forwards to `claude-resume`. It is defined **only when
the name `ccr` is not already taken** on your system, so it never shadows another
tool that ships a `ccr` binary (for example
[claude-code-router](https://github.com/musistudio/claude-code-router)).

- bash / zsh: a shell function `ccr() { claude-resume "$@"; }` (a function, not an
  alias, so it also resolves in non-interactive shells).
- fish: a function installed by `conf.d/claude-resume-shortcut.fish`, guarded by
  `type -q ccr`.

`ccr --all` forwards its arguments, so it behaves exactly like `claude-resume --all`.

## Environment variables

| Variable | Read by | Effect |
|----------|---------|--------|
| `CCR_NO_SHORT` | `claude-resume.sh`, `claude-resume-shortcut.fish` | If set to any non-empty value, the short `ccr` wrapper is **not** defined, even when the name is free. |
| `CCR_RAW_BASE` | `install.sh` | Overrides the base URL that `curl \| sh` downloads files from. Default: `https://raw.githubusercontent.com/kuwa72/claude-resume/main`. Use it to install from a fork or internal mirror. |

## Installed files

The installer places these files:

| File | Purpose |
|------|---------|
| `~/.claude/scripts/claude-resume.sh` | bash/zsh function + conditional `ccr`. Sourced from your rc file. |
| `~/.claude/scripts/cc-session-list.js` | Node helper: lists sessions as TSV. |
| `~/.claude/scripts/cc-session-preview.js` | Node helper: renders a transcript preview for fzf. |
| `~/.config/fish/functions/claude-resume.fish` | fish autoloaded function (fish only). |
| `~/.config/fish/conf.d/claude-resume-shortcut.fish` | fish conditional `ccr` snippet (fish only). |

It also appends one guarded `source` line to `~/.zshrc` and/or `~/.bashrc`
(and `~/.bash_profile` if present). The line is idempotent — re-running the
installer never duplicates it.

## Helper: `cc-session-list.js`

```
node cc-session-list.js <projectDir> [<projectDir> ...]
```

Scans each directory for `*.jsonl` session logs, sorts them newest-first by file
mtime, and prints one tab-separated row per session:

| Column | Content |
|--------|---------|
| 1 | Absolute path to the `.jsonl` log |
| 2 | Session ID (the filename without `.jsonl`) |
| 3 | The session's `cwd` (from the first log line that carries one) |
| 4 | Modified time, formatted `YYYY-MM-DD HH:MM` (local time) |
| 5 | First real user prompt, whitespace-collapsed, truncated to 120 chars |

The "first real user prompt" skips lines whose text starts with
`<command-`, `<local-command`, `<system-reminder`, or `Caveat:`. If none is found,
the column reads `(no prompt)`. Unreadable or non-JSON lines are skipped silently;
a directory that cannot be read is skipped.

## Helper: `cc-session-preview.js`

```
node cc-session-preview.js <path-to-session.jsonl>
```

Prints a readable transcript preview for fzf's `--preview` pane:

- Includes only `user` and `assistant` messages.
- Applies the same skip-prefix filter as the list helper.
- `tool_use` blocks render as `[tool: <name>]`.
- Each line is tagged `▶ USER:` or `  claude:` and truncated to **220 chars**.
- At most the first **40** messages are shown.

## Exit codes (`claude-resume`)

| Code | Meaning |
|------|---------|
| `0` | Resumed a session, or you selected nothing (Esc). |
| `1` | No sessions for the current project (without `--all`), or the target `cwd` existed but `cd` failed. |

## Requirements

| Tool | Why |
|------|-----|
| [fzf](https://github.com/junegunn/fzf) | the picker UI |
| Node.js | runs the list + preview helpers |
| [Claude Code](https://claude.com/claude-code) | `claude -r` performs the resume |

## Platform support

| | Status |
|---|---|
| Shells | bash, zsh (`claude-resume.sh`); fish (autoloaded function) |
| OS | macOS, Linux, WSL |
| Not supported | POSIX `sh`/dash (needs arrays + pattern substitution); native Windows PowerShell |

## Related

- [Tutorial](tutorial.md) — install to first resume in three steps.
- [How-to guides](how-to.md) — specific tasks (all-projects, collisions, uninstall).
- [Explanation](explanation.md) — why the design works the way it does.
