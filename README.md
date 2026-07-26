# claude-resume — resume a Claude Code session with fzf

`claude-resume` lists your past [Claude Code](https://claude.com/claude-code) sessions in an
[fzf](https://github.com/junegunn/fzf) picker (with a live transcript preview), then
`cd`s into the session's working directory and resumes it with `claude -r`.

```
resume session> ▌
  2026-07-24 15:16  BFFにプロシージャを追加したい     │ ▶ USER: BFFにプロシージャを追加したい
  2026-07-24 11:02  MRP工程表のクラッシュを直す        │   claude: 了解です。まず該当箇所を…
  2026-07-23 18:27  fewer-permission-prompts を回す    │ ▶ USER: /fewer-permission-prompts
```

- `claude-resume` — sessions for the **current project directory**
- `claude-resume --all` — sessions across **all projects**

### The short name `ccr`

`claude-resume` is the canonical command. A short **`ccr`** wrapper is installed
**only if the name `ccr` is not already taken** on your system — so it never clobbers
another tool that already ships a `ccr` (e.g. [claude-code-router](https://github.com/musistudio/claude-code-router)).
If `ccr` is taken, just use `claude-resume`. To never define the short name, set
`export CCR_NO_SHORT=1` before your shell sources it.

## Documentation

Full docs live in [`docs/`](docs/), organized by the
[Diataxis](https://diataxis.fr/) framework:

| Doc | Read it when you want to… |
|-----|---------------------------|
| [Tutorial](docs/tutorial.md) | go from install to your first resumed session, step by step |
| [How-to guides](docs/how-to.md) | do a specific task: all-projects, the `ccr` collision, forks, uninstall |
| [Reference](docs/reference.md) | look up exact commands, env vars, exit codes, and the helper contracts |
| [Explanation](docs/explanation.md) | understand the design: why `ccr` is conditional, why Node helpers, and more |

## Supported platforms

| | Status |
|---|---|
| Shells | **bash** and **zsh** (via `claude-resume.sh`), and **fish** (autoloaded function) |
| OS | macOS, Linux, WSL |
| Not supported | POSIX `sh`/dash (needs arrays + pattern substitution), native Windows PowerShell |

No OS-specific commands are used; the date/stat logic lives in the Node helpers, which
rely only on cross-platform APIs.

## Install (one line)

```sh
curl -fsSL https://raw.githubusercontent.com/kuwa72/claude-resume/main/install.sh | sh
```

Then open a new shell and run `claude-resume` (or `ccr`). The installer:

- copies `claude-resume.sh` + the two Node helpers into `~/.claude/scripts/`
- adds one guarded `source` line to `~/.zshrc` / `~/.bashrc` (idempotent)
- for fish: installs the autoloaded function and a conditional `ccr` snippet under `~/.config/fish/`
- checks that `node`, `fzf`, and `claude` are on your `PATH`

### From a checkout / release zip

```sh
git clone https://github.com/kuwa72/claude-resume.git && cd claude-resume && ./install.sh
# or: unzip claude-resume.zip && cd claude-resume && ./install.sh
```

The same `install.sh` works locally (copies bundled files) or piped (downloads them).

## Requirements

| Tool | Why | Get it |
|------|-----|--------|
| [fzf](https://github.com/junegunn/fzf) | picker UI | `brew install fzf` / `apt install fzf` |
| Node.js | list + preview helpers | https://nodejs.org |
| [Claude Code](https://claude.com/claude-code) | `claude -r` to resume | `npm i -g @anthropic-ai/claude-code` |

## Uninstall

```sh
rm -f ~/.claude/scripts/claude-resume.sh \
      ~/.claude/scripts/cc-session-list.js \
      ~/.claude/scripts/cc-session-preview.js \
      ~/.config/fish/functions/claude-resume.fish \
      ~/.config/fish/conf.d/claude-resume-shortcut.fish
# then remove the `# claude-resume` line from ~/.zshrc / ~/.bashrc
```

## How it works

- `cc-session-list.js` — scans the `*.jsonl` session logs under the given project dir(s),
  newest first, and prints `path / session-id / cwd / date / first-prompt` as TSV.
- `cc-session-preview.js` — renders a readable user/assistant transcript preview for fzf `--preview`.
- `claude-resume.sh` / `claude-resume.fish` — feed the list to fzf, then `cd` to the chosen
  session's `cwd` and run `claude -r <id>`. The short `ccr` wrapper is defined conditionally.

Everything is **read-only** over `~/.claude/projects/`; nothing modifies your session logs.

## Privacy note

Session logs contain your past prompts, and the picker preview displays them. On a shared
machine, be mindful that anyone who can run `claude-resume` can read your Claude Code history.

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, share it freely.
