# How-to guides

Task-oriented recipes. Each assumes `claude-resume` is already installed (see the
[tutorial](tutorial.md) if not) and that `node`, `fzf`, and `claude` are on your
`PATH`.

## How to resume a session from the current project

1. `cd` into the project directory where you were working.
2. Run:

   ```sh
   claude-resume
   ```

3. In the picker, use the preview pane on the right to find the session, then
   press Enter.

`claude-resume` moves into that session's working directory and runs
`claude -r`. If there are no sessions for the current directory, it tells you and
suggests `--all`.

## How to resume a session from any project

When the session started in a different directory:

```sh
claude-resume --all
```

This lists sessions across every project under `~/.claude/projects/`. Selecting
one still `cd`s to that session's own working directory before resuming.

## How to use the short `ccr` name — or avoid it

`ccr` is installed as a shortcut **only if the name is free**:

- If `ccr` is available, `ccr` and `ccr --all` work as aliases for `claude-resume`.
- If another tool already provides `ccr` (e.g. claude-code-router), the shortcut is
  skipped and you use `claude-resume` directly.

To never define the shortcut, even when the name is free, set the variable before
your shell sources the script — put this in your `~/.zshrc` / `~/.bashrc` above the
`claude-resume` source line, or your fish `config.fish`:

```sh
export CCR_NO_SHORT=1
```

## How to install from a fork or internal mirror

The `curl | sh` installer downloads its files from a base URL. Point it elsewhere
with `CCR_RAW_BASE`:

```sh
curl -fsSL https://raw.githubusercontent.com/YOURORG/claude-resume/main/install.sh \
  | CCR_RAW_BASE=https://raw.githubusercontent.com/YOURORG/claude-resume/main sh
```

Running `./install.sh` from a local checkout needs no URL at all — it copies the
bundled files directly.

## How to uninstall

```sh
rm -f ~/.claude/scripts/claude-resume.sh \
      ~/.claude/scripts/cc-session-list.js \
      ~/.claude/scripts/cc-session-preview.js \
      ~/.config/fish/functions/claude-resume.fish \
      ~/.config/fish/conf.d/claude-resume-shortcut.fish
```

Then delete the guarded line (it ends with `# claude-resume`) from `~/.zshrc`,
`~/.bashrc`, or `~/.bash_profile`.

## Troubleshooting

**`claude-resume: command not found`.** Your shell hasn't sourced the script yet.
Open a new shell, or run `source ~/.zshrc` (or `~/.bashrc`). For fish, open a new
shell so the autoloaded function and `conf.d` snippet load.

**`ccr` runs a different tool.** That's by design — the name was already taken, so
the shortcut was skipped. Use `claude-resume`.

**`claude-resume: no sessions for this project`.** There are no logs under
`~/.claude/projects/<encoded-cwd>/`. Either you're in the wrong directory, or the
session was started elsewhere — use `claude-resume --all`.

**The picker is empty.** No `.jsonl` session logs were found. With `--all`, that
means `~/.claude/projects/` has no sessions yet. Without it, you're in a directory
that has never hosted a Claude Code session.

**`node` / `fzf` / `claude` not found.** Install the missing dependency
(`brew install fzf`, install Node.js, `npm i -g @anthropic-ai/claude-code`) and
retry. The installer's dependency check reports which ones are missing.

## Related

- [Tutorial](tutorial.md) — the guided first run.
- [Reference](reference.md) — exact flags, variables, and exit codes.
- [Explanation](explanation.md) — why `ccr` is conditional and how project lookup works.
