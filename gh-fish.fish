#!/usr/bin/env fish

set -l argv_copy $argv

function alias_func
    set -l GH_FISH_ALIAS_PATH "~/.local/share/gh/extensions/gh-fish/gh-copilot-alias.fish"
    set -l FISH_CONFIG_PATH ~/.config/fish/config.fish
    set -l ALIAS_EXISTS (grep -c "source $GH_FISH_ALIAS_PATH" $FISH_CONFIG_PATH)
    if test "$ALIAS_EXISTS" = "0"
        echo "source $GH_FISH_ALIAS_PATH" >> ~/.config/fish/config.fish
    else
        return 0
    end
end

function source_func
    source ~/.local/share/gh/extensions/gh-fish/gh-copilot-alias.fish
end

for i in (seq (count $argv_copy))
    switch $argv_copy[$i]
        case 'alias'
            alias_func
        case 'source'
            echo 'source ~/.local/share/gh/extensions/gh-fish/gh-fish.fish srcin'
        case 'srcin'
            source_func
    end
end