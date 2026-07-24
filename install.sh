#!/usr/bin/env sh
# claude-resume installer.
# Works two ways:
#   - Local:   run ./install.sh from a checkout of the repo.
#   - Remote:  curl -fsSL <raw>/install.sh | sh
# POSIX sh on purpose so it runs anywhere. The installed command itself needs bash or zsh (or fish).
set -eu

# Where to fetch files from when running via `curl | sh` (no local checkout).
# Overridable:  CCR_RAW_BASE=... sh install.sh
RAW_BASE="${CCR_RAW_BASE:-https://raw.githubusercontent.com/kuwa72/claude-resume/main}"

CC_SCRIPTS="$HOME/.claude/scripts"
FISH_FNS="$HOME/.config/fish/functions"
FISH_CONFD="$HOME/.config/fish/conf.d"

say()  { printf '%s\n' "$*"; }
warn() { printf '%s\n' "$*" >&2; }

# Directory of this script if we are running from a local checkout ("" if piped).
here=""
if [ -n "${0:-}" ] && [ -f "${0:-}" ]; then
  here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
fi

# fetch <relpath> <dest>: copy from the local checkout if present, else download.
fetch() {
  _rel="$1"; _dest="$2"
  if [ -n "$here" ] && [ -f "$here/$_rel" ]; then
    cp "$here/$_rel" "$_dest"
  elif command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_BASE/$_rel" -o "$_dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$_dest" "$RAW_BASE/$_rel"
  else
    warn "claude-resume: need curl or wget to download files."; exit 1
  fi
}

say "Installing claude-resume into $CC_SCRIPTS ..."
mkdir -p "$CC_SCRIPTS"
fetch scripts/cc-session-list.js    "$CC_SCRIPTS/cc-session-list.js"
fetch scripts/cc-session-preview.js "$CC_SCRIPTS/cc-session-preview.js"
fetch claude-resume.sh              "$CC_SCRIPTS/claude-resume.sh"
chmod +x "$CC_SCRIPTS/cc-session-list.js" "$CC_SCRIPTS/cc-session-preview.js" 2>/dev/null || true

# Wire the bash/zsh function into rc files (idempotent; one guarded line).
SRC_LINE='[ -f "$HOME/.claude/scripts/claude-resume.sh" ] && source "$HOME/.claude/scripts/claude-resume.sh"  # claude-resume'
wire_rc() {
  _rc="$1"
  [ -e "$_rc" ] || return 0
  if grep -Fq '.claude/scripts/claude-resume.sh' "$_rc" 2>/dev/null; then
    say "  already wired: $_rc"
  else
    printf '\n%s\n' "$SRC_LINE" >> "$_rc"
    say "  wired into: $_rc"
  fi
}
# Touch the rc for the current login shell so first-time users get it even with no rc yet.
case "${SHELL:-}" in
  *zsh)  [ -e "$HOME/.zshrc" ]  || : > "$HOME/.zshrc" ;;
  *bash) [ -e "$HOME/.bashrc" ] || : > "$HOME/.bashrc" ;;
esac
wire_rc "$HOME/.zshrc"
wire_rc "$HOME/.bashrc"
[ -e "$HOME/.bash_profile" ] && wire_rc "$HOME/.bash_profile" || true

# fish: autoload function + conditional short-alias snippet (no rc edit needed).
if command -v fish >/dev/null 2>&1 || [ -d "$HOME/.config/fish" ]; then
  mkdir -p "$FISH_FNS" "$FISH_CONFD"
  fetch claude-resume.fish          "$FISH_FNS/claude-resume.fish"
  fetch claude-resume-shortcut.fish "$FISH_CONFD/claude-resume-shortcut.fish"
  say "  installed fish function + short-alias snippet"
fi

say ""
say "Dependency check:"
for dep in node fzf claude; do
  if command -v "$dep" >/dev/null 2>&1; then
    say "  ok   $dep"
  else
    warn "  MISS $dep  — install it (macOS: brew install $dep). claude-resume needs all three."
  fi
done

say ""
say "Done. Start a NEW shell (or 'source ~/.zshrc'), then run:"
say "    claude-resume         # sessions for the current project   (short: ccr, if free)"
say "    claude-resume --all   # sessions across all projects"
