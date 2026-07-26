# Tutorial: from install to your first resumed session

By the end of this tutorial you'll have `claude-resume` installed and you'll have
jumped back into a real past Claude Code session by picking it from a list — no
copying session IDs by hand.

## What you'll need

- A shell that is **bash**, **zsh**, or **fish** (macOS, Linux, or WSL).
- [Node.js](https://nodejs.org), [fzf](https://github.com/junegunn/fzf), and
  [Claude Code](https://claude.com/claude-code) installed. On macOS:
  `brew install node fzf` and `npm i -g @anthropic-ai/claude-code`.
- At least one past Claude Code session (if you've run `claude` before, you have one).

## Step 1: Install

Run the one-liner:

```sh
curl -fsSL https://raw.githubusercontent.com/kuwa72/claude-resume/main/install.sh | sh
```

You'll see it copy files into `~/.claude/scripts/`, wire a line into your shell's
rc file, and check that `node`, `fzf`, and `claude` are present. If it reports a
missing dependency, install it and re-run.

## Step 2: Open a new shell and launch the picker

Open a new terminal (so your shell loads the new function), then run:

```sh
claude-resume --all
```

You'll immediately see an fzf picker: a list of your sessions on the left (date +
first prompt), and a live transcript preview on the right.

```
resume session> ▌
  2026-07-24 15:16  Fix the login redirect bug        │ ▶ USER: the login page loops on redirect
  2026-07-23 18:02  Add CSV export to reports         │   claude: Sure — I'll add an export button…
```

That's the working result, reached in two steps. (If the list is empty, you have
no sessions yet — run `claude` once, then come back.)

## Step 3: Pick a session and resume it

Type a few characters from a prompt to filter, use the preview to confirm it's the
right one, and press **Enter**.

`claude-resume` prints where it's resuming, `cd`s into that session's working
directory, and hands off to `claude -r`:

```
Resuming 0c021473-… in /Users/you/projects/webapp
```

You're now back in that conversation, in the right directory, with full context.
That's the whole point: no hunting for session IDs.

## Try the short form

If the name `ccr` was free on your system, the installer also gave you a shortcut:

```sh
ccr          # same as claude-resume, for the current project
ccr --all    # same as claude-resume --all
```

If `ccr` already belongs to another tool, that's fine — the shortcut is skipped and
you keep using `claude-resume`. See the [explanation](explanation.md#why-a-canonical-long-name-with-a-conditional-short-one)
for why.

## What you built

You installed a small tool that turns `claude -r`'s bare session IDs into a
searchable, preview-able picker, and used it to resume real work in one keystroke.
From here:

- Use `claude-resume` (no `--all`) inside a project to see just that project's
  sessions — see the [how-to guides](how-to.md).
- Learn every flag and the helper contracts in the [reference](reference.md).
- Understand the design choices in the [explanation](explanation.md).
