export FZF_DEFAULT_COMMAND='fd --hidden --type f --exclude .git'
export FZF_DEFAULT_OPTS='--height 80% --layout=reverse --border --preview-window right:60%:wrap --bind ctrl-e:down,ctrl-u:up,ctrl-d:preview-page-down,ctrl-f:preview-page-up'
export FZF_PREVIEW_COMMAND='if file -b --mime-type -- {} | grep -qE "^(text/|application/json|application/xml)"; then bat --color=always --style=numbers {} 2>/dev/null || cat {}; else echo "binary file"; fi | head -500'
export FZF_COMPLETION_TRIGGER='\'
