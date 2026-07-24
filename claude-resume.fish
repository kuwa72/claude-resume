function claude-resume --description 'fzf-select a Claude Code session and resume it (claude -r)'
    set -l scripts ~/.claude/scripts

    # Decide which project dirs to scan.
    set -l dirs
    if test "$argv[1]" = --all
        set dirs ~/.claude/projects/*/
    else
        # Encode $PWD the way Claude Code names project dirs: / and . -> -
        set -l enc (string replace -a / - -- $PWD | string replace -a . -)
        set dirs ~/.claude/projects/$enc
        if not test -d "$dirs[1]"
            echo "claude-resume: no sessions for this project ($PWD)."
            echo "               try:  claude-resume --all"
            return 1
        end
    end

    set -l tab (printf '\t')
    set -l line (node $scripts/cc-session-list.js $dirs \
        | fzf --delimiter $tab \
              --with-nth 4,5 \
              --no-hscroll \
              --preview "node $scripts/cc-session-preview.js {1}" \
              --preview-window 'right:55%:wrap' \
              --prompt 'resume session> ' \
              --header 'enter: resume  |  esc: cancel')

    test -z "$line"; and return 0

    set -l fields (string split $tab -- $line)
    set -l id $fields[2]
    set -l dir $fields[3]

    test -n "$dir"; and test -d "$dir"; and cd $dir
    echo "Resuming $id in "(pwd)
    claude -r $id
end
