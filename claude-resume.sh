# claude-resume — fzf-select a Claude Code session and resume it (claude -r).
# Portable shell function for bash and zsh. Source this from ~/.bashrc / ~/.zshrc:
#   source ~/.claude/scripts/claude-resume.sh
#
#   claude-resume         resume a session from the CURRENT project directory
#   claude-resume --all   resume a session from ANY project
#
# A short `ccr` alias is defined ONLY if `ccr` is not already taken by another
# tool (e.g. claude-code-router). Set CCR_NO_SHORT=1 to never define it.

claude-resume() {
  # zsh aborts on an unmatched glob by default; make it lenient like bash.
  # local_options confines the change to this function (restored on return).
  [ -n "${ZSH_VERSION:-}" ] && setopt local_options no_nomatch

  local scripts="$HOME/.claude/scripts"
  local tab
  tab=$(printf '\t')

  # Collect the project dirs to scan (array works the same in bash and zsh).
  local -a dirs
  if [ "$1" = "--all" ]; then
    dirs=( "$HOME/.claude/projects"/*/ )
  else
    # Encode $PWD the way Claude Code names project dirs: '/' and '.' -> '-'.
    local enc="${PWD//[\/.]/-}"
    local d="$HOME/.claude/projects/$enc"
    if [ ! -d "$d" ]; then
      echo "claude-resume: no sessions for this project ($PWD)." >&2
      echo "               try:  claude-resume --all" >&2
      return 1
    fi
    dirs=( "$d" )
  fi

  local line
  line=$(node "$scripts/cc-session-list.js" "${dirs[@]}" \
    | fzf --delimiter "$tab" \
          --with-nth 4,5 \
          --no-hscroll \
          --preview "node '$scripts/cc-session-preview.js' {1}" \
          --preview-window 'right:55%:wrap' \
          --prompt 'resume session> ' \
          --header 'enter: resume  |  esc: cancel')

  [ -z "$line" ] && return 0

  # Fields: 1=jsonlPath 2=sessionId 3=cwd 4=date 5=firstPrompt
  local id dir
  id=$(printf '%s' "$line" | cut -f2)
  dir=$(printf '%s' "$line" | cut -f3)

  if [ -n "$dir" ] && [ -d "$dir" ]; then
    cd "$dir" || return 1
  fi
  echo "Resuming $id in $(pwd)"
  claude -r "$id"
}

# Short `ccr` wrapper, defined only when the name is free (no clobbering).
# A function (not an alias) so it also works in non-interactive shells.
if [ -z "${CCR_NO_SHORT:-}" ] && ! command -v ccr >/dev/null 2>&1; then
  ccr() { claude-resume "$@"; }
fi
