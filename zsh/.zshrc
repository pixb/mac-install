source $HOME/.zprofile
###########
#  zinit  #
###########
ZINIT_FILE=$HOME/.local/share/zinit/zinit.git/zinit.zsh
if [ -e ${ZINIT_FILE} ]; then
    source ${ZINIT_FILE}
else
    bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

#################
#  zinit plugins
#################
# Ensure compinit is loaded before loading plugins
autoload -U compinit && compinit
zinit light romkatv/powerlevel10k
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma/fast-syntax-highlighting
zinit light zpm-zsh/ls

zinit snippet OMZ::plugins/extract/extract.plugin.zsh
zinit snippet OMZ::plugins/sudo/sudo.plugin.zsh
# zinit light b4b4r07/enhancd

# Install plugins if there are plugins that have not been installed
# zinit self-update
# zinit update --all

source "$HOME/.sdkman/bin/sdkman-init.sh"
### End of Zinit's installer chunk

###################
#  my 10k config  #
###################
source ~/.pl10krc

#########################
#  zsh-autosuggestions  #
#########################
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=yellow'

##############
#  homebrew  #
##############
eval "$(/opt/homebrew/bin/brew shellenv)"

# Load my custom configurations
source $HOME/dev/linux-demo/config/alias.zsh
source $HOME/dev/linux-demo/config/git.zsh
source $HOME/dev/linux-demo/config/fzf.zsh
source $HOME/dev/linux-demo/config/android.zsh

#########
#  fzf  #
#########
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)

# alias
alias ls='gls --color=auto --group-directories-first'
alias rsync="/opt/homebrew/bin/rsync"

###########
#   env   #
###########
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
export PATH=$HOME/dev/linux-demo/pix-shell:$PATH
export PATH=$HOME/dev/linux-demo/bin:$PATH
export PATH=$HOME/dev/mac-install/tool/rar:$PATH
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

###########
#  pyenv  #
###########
eval "$(pyenv init -)"

###########
#  golang #
###########
go env -w GO111MODULE=on
export GOPROXY=https://goproxy.cn,direct
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin


###########
#  rust   #
###########
. "$HOME/.cargo/env"

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk
### End of Zinit's installer chunk
eval "$(rbenv init - zsh)"

## flutter
export PATH="/Volumes/data/dev/code/flutter/sdk/bin:$PATH"

# Added by Antigravity
export PATH="/Users/pix/.antigravity/antigravity/bin:$PATH"

# 1. 设置 GPG_TTY（这一步最关键）
export GPG_TTY=$(tty)

if [ -d ${HOME}/dev/env ]; then
  . <(gpg -d ${HOME}/dev/env/env/agentmemory.env.gpg 2>/dev/null)
  . <(gpg -d ${HOME}/dev/env/env/amux.env.gpg 2>/dev/null)
fi
