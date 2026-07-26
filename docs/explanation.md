# Explanation

Why `claude-resume` is built the way it is. This is design rationale, not usage;
for commands see the [reference](reference.md).

## Why a canonical long name with a conditional short one

The command you type most is `ccr`. But `ccr` is a popular name — most visibly,
[claude-code-router](https://github.com/musistudio/claude-code-router) installs a
`ccr` binary. A tool meant for wide distribution that unconditionally defined
`ccr` would silently shadow that binary for anyone who has it, breaking their
setup the moment they source our script.

So the canonical command is `claude-resume`, and the short `ccr` is defined
**only when the name is free**:

```sh
if [ -z "${CCR_NO_SHORT:-}" ] && ! command -v ccr >/dev/null 2>&1; then
  ccr() { claude-resume "$@"; }
fi
```

Trade-off: people who already use another `ccr` don't get our shortcut — they
type `claude-resume` (or set nothing and live with the long name). We accept a
slightly worse experience for those users in exchange for never breaking anyone's
existing tooling. `CCR_NO_SHORT=1` lets anyone opt out of the shortcut explicitly.

## Why a function, not an alias, for `ccr`

An earlier version used `alias ccr='claude-resume'`. It failed a real case: bash
does **not** expand aliases in non-interactive shells, and the alias was not
reliably visible to `command -v` there either. A shell function has neither
problem — it resolves in interactive and non-interactive shells alike, and
`command -v ccr` always finds it. So the shortcut is a function that forwards
`"$@"`.

## Why the project-directory encoding is `/` and `.` → `-`

Claude Code stores each project's session logs under
`~/.claude/projects/<encoded-cwd>/`, where the encoding replaces `/` and `.` with
`-`. To answer "sessions for *this* project," `claude-resume` reproduces that
encoding from `$PWD`:

```sh
enc="${PWD//[\/.]/-}"
```

The `${var//[\/.]/-}` pattern substitution behaves identically in bash and zsh,
so one line covers both shells.

Trade-off: this couples us to Claude Code's naming scheme. If that scheme ever
changes, the current-project lookup breaks. The mitigation is `--all`, which globs
every project directory and never depends on the encoding — so even if the
per-project path stops matching, the tool still works.

## Why Node helpers instead of pure shell

Listing sessions means: read many JSONL files, parse JSON, pull the first real
user prompt and the `cwd`, and format each file's mtime as a local timestamp.
Doing that in portable shell (across bash, zsh, and different `date`/`stat`
implementations on macOS vs Linux) is fragile. Node does JSON parsing and date
formatting the same way everywhere.

Keeping that logic in `cc-session-list.js` and `cc-session-preview.js` is what
makes the tool cross-platform: the shell functions only glob directories, invoke
fzf, and run `claude -r`. No OS-specific shell commands are needed.

## Why zsh needs `no_nomatch`

By default, zsh aborts the whole command when a glob matches nothing —
`~/.claude/projects/*/` with no projects would error instead of expanding to
"nothing." bash, by default, leaves an unmatched glob as a literal string, which
the Node helper then reads, fails to open, and skips gracefully.

To get bash's forgiving behavior in zsh without changing global shell state, the
function sets the option locally:

```sh
[ -n "${ZSH_VERSION:-}" ] && setopt local_options no_nomatch
```

`local_options` scopes the change to the function; it is restored on return. The
guard on `$ZSH_VERSION` means bash never runs it.

## Why it only reads, never writes

`claude-resume` scans `~/.claude/projects/` and runs `claude -r`. It never edits
or deletes a session log. That keeps the blast radius at zero: the worst a bug
can do is fail to find a session, not corrupt your history.

The one thing to be aware of is privacy, not integrity: session logs contain your
past prompts, and the fzf preview displays them. On a shared machine, anyone who
can run `claude-resume` can read that history.

## Related

- [Reference](reference.md) — the exact commands, variables, and contracts.
- [How-to guides](how-to.md) — applying these behaviors to specific tasks.
