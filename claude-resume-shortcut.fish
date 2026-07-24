# Define the short `ccr` alias for claude-resume, but only when the name is
# free (so we never clobber another tool's ccr, e.g. claude-code-router).
# Set CCR_NO_SHORT=1 to skip this entirely.
if test -z "$CCR_NO_SHORT"; and not type -q ccr
    function ccr --wraps claude-resume --description 'short alias for claude-resume'
        claude-resume $argv
    end
end
