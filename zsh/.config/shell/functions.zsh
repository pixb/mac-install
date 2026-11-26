gcd() {
    local root
    root="$(git rev-parse --show-toplevel 2>/dev/null)" || return 1
    cd "$root" || return 1
}

colors() {
    local i
    for i in {0..15}; do
        printf '\e[48;5;%sm  \e[0m' "$i"
        [ $(((i + 1) % 8)) -eq 0 ] && printf '\n'
    done
}

hist() {
    local selection lineNumber
    case "${1:---status}" in
        -d|--disable)
            unset HISTFILE
            echo "[zsh]: history is disabled"
            ;;
        -e|--enable)
            HISTFILE="$HOME/.zsh_history"
            echo "[zsh]: history is enabled"
            ;;
        -f|--file)
            if [ -n "$HISTFILE" ]; then
                echo "[zsh]: history is saved to $HISTFILE"
            else
                echo "[zsh]: history is disabled"
            fi
            ;;
        -D|--Delete)
            if [ -z "$HISTFILE" ]; then
                echo "[zsh]: history is disabled"
                return 1
            fi
            selection="$(nl -n ln -s ' ' "$HISTFILE" | fzf --height 50% --no-preview --wrap --layout=reverse-list --color --tac)"
            [ -n "$selection" ] || return 0
            lineNumber=${selection%% *}
            printf '%s\n' "$selection"
            read "?Delete history entry? (y/n): "
            if [ "$REPLY" = y ]; then
                gsed -i "${lineNumber}d" "$HISTFILE"
                echo "deleted; restart zsh to reload (in-memory history may overwrite on exit)"
            else
                echo aborted
            fi
            ;;
        -h|--help)
            cat <<'EOF'
USAGE
        hist [OPTIONS]
OPTIONS
        -d,--disable    disable shell history for current session
        -e,--enable     enable shell history for current session
        -f,--file       print shell history file for current session
        -D,--Delete     choose a history entry to be deleted
        -h,--help       print this help info
EOF
            ;;
        *)
            if [ -z "$HISTFILE" ]; then
                echo "[zsh]: history is disabled"
            else
                echo "[zsh]: history is enabled"
            fi
            ;;
    esac
}
