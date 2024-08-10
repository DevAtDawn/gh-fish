function ghcs
    set -l FUNCNAME (status function)
    set -l TARGET "shell"
    set -l GH_DEBUG "$GH_DEBUG"
    set -l GH_HOST "$GH_HOST"
    set -l __USAGE "
Wrapper around \`gh copilot suggest\` to suggest a command based on a natural language description of the desired output effort.
Supports executing suggested commands if applicable.
USAGE
  $FUNCNAME [flags] <prompt>
FLAGS
  -d, --debug           Enable debugging
  -h, --help            Display help usage
      --hostname        The GitHub host to use for authentication
  -t, --target target   Target for suggestion; must be shell, gh, git
                        default: \"$TARGET\"
EXAMPLES
- Guided experience
  $FUNCNAME
- Git use cases
  $FUNCNAME -t git \"Undo the most recent local commits\"
  $FUNCNAME -t git \"Clean up local branches\"
  $FUNCNAME -t git \"Setup LFS for images\"
- Working with the GitHub CLI in the terminal
  $FUNCNAME -t gh \"Create pull request\"
  $FUNCNAME -t gh \"List pull requests waiting for my review\"
  $FUNCNAME -t gh \"Summarize work I have done in issues and pull requests for promotion\"
- General use cases
  $FUNCNAME \"Kill processes holding onto deleted files\"
  $FUNCNAME \"Test whether there are SSL/TLS issues with github.com\"
  $FUNCNAME \"Convert SVG to PNG and resize\"
  $FUNCNAME \"Convert MOV to animated PNG\"
"

    set -l argv_copy $argv
    for i in (seq (count $argv_copy))
        switch $argv_copy[$i]
            case '-d' '--debug'
                set -l GH_DEBUG "api"
            case '-h' '--help'
                echo "$__USAGE"
                return 0
            case '--hostname'
                set -l GH_HOST $argv_copy[(math $i + 1)]
                set -e argv_copy[(math $i + 1)]
            case '-t' '--target'
                set -l TARGET $argv_copy[(math $i + 1)]
                set -e argv_copy[(math $i + 1)]
        end
    end

    set -e argv_copy[1..(math $i - 1)]

    set -l TMPFILE (mktemp -t gh-copilotXXXXXX)
    function cleanup
        rm -f "$TMPFILE"
    end
    trap cleanup EXIT

    if env GH_DEBUG="$GH_DEBUG" GH_HOST="$GH_HOST" gh copilot suggest -t "$TARGET" $argv_copy --shell-out "$TMPFILE"
        if test -s "$TMPFILE"
            set -l FIXED_CMD (cat $TMPFILE)
            history --merge --save -- $FIXED_CMD
            echo
            eval $FIXED_CMD
        end
    else
        return 1
    end
end



function ghce
    set -l FUNCNAME (status function)
    set -l GH_DEBUG $GH_DEBUG
    set -l GH_HOST $GH_HOST
    set -l __USAGE "
Wrapper around \`gh copilot explain\` to explain a given input command in natural language.

USAGE
  $FUNCNAME [flags] <command>

FLAGS
  -d, --debug      Enable debugging
  -h, --help       Display help usage
      --hostname   The GitHub host to use for authentication

EXAMPLES

# View disk usage, sorted by size
$FUNCNAME 'du -sh | sort -h'

# View git repository history as text graphical representation
$FUNCNAME 'git log --oneline --graph --decorate --all'

# Remove binary objects larger than 50 megabytes from git history
$FUNCNAME 'bfg --strip-blobs-bigger-than 50M'
"

    set -l argv_copy $argv
    set -l optind 1
    for arg in $argv_copy
        switch $arg
            case '-d' '--debug'
                set -l GH_DEBUG api
                set argv_copy (string match -v $arg $argv_copy)
                set -l optind (math $optind + 1)
            case '-h' '--help'
                echo "$__USAGE"
                return 0
            case '--hostname=*'
                set -l GH_HOST (string split -m 1 '=' $arg)[2]
                set argv_copy (string match -v $arg $argv_copy)
                set -l optind (math $optind + 1)
            case '*'
                break
        end
    end

    set argv_copy (string sub -s (math $optind + 1) -- $argv)

    env GH_DEBUG=$GH_DEBUG GH_HOST=$GH_HOST gh copilot explain $argv_copy
end