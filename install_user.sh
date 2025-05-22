#!/usr/bin/env bash
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m'

function brew_install() {
  if brew list | grep "$1" &>/dev/null; then
    echo -e "${COLOR_GREEN}$1 is installed${COLOR_NC}"
  else
    echo -e "${COLOR_YELLOW}$1 is not install${COLOR_NC}"
    brew install "$1"
  fi
}
function brew_ui_install() {
  if brew list | grep "$1" &>/dev/null; then
    echo -e "${COLOR_GREEN}$1 is installed${COLOR_NC}"
  else
    echo -e "${COLOR_YELLOW}$1 is not install${COLOR_NC}"
    brew install --cask "$1"
  fi
}

# 关闭长按
defaults write -g ApplePressAndHoldEnabled -bool false

brew update
brew upgrade
brew_install gnu-sed
brew_install ffmpeg
brew_install htop
brew_install btop
brew_install duf
brew_install fastfetch
brew_ui_install visual-studio-code
brew_install ripgrep
brew_install the_silver_searcher
brew_install pyenv
if pyenv versions | grep "3.12.0" &>/dev/null; then
  echo -e "${COLOR_GREEN}pyenv 3.12.0 is installed${COLOR_NC}"
else
  echo -e "${COLOR_YELLOW}pyenv 3.12.0 is not install...${COLOR_NC}"
  pyenv install 3.12.0
  pyenv global 3.12.0
fi
brew_install rcm
brew_install fzf
brew_install coreutils
brew_ui_install dbeaver-community
brew_install lazygit
brew_install wget

if command -v go &>/dev/null; then
  echo -e "${COLOR_GREEN}go is installed${COLOR_NC}"
else
  echo -e "${COLOR_YELLOW}go is not install..${COLOR_NC}"
  brew install go
fi

if [ -e "$HOME"/.sdkman/bin/sdkman-init.sh ]; then
  echo -e "${COLOR_GREEN}sdkman is installed${COLOR_NC}"
  source "$HOME"/.sdkman/bin/sdkman-init.sh
else
  echo -e "${COLOR_YELLOW}sdkman not init, init...${COLOR_NC}"
  curl -s "https://get.sdkman.io" | bash
fi

if command -v java &>/dev/null; then
  echo -e "${COLOR_GREEN}java is installed${COLOR_NC}"
else
  echo -e "${COLOR_YELLOW}java is not install${COLOR_NC}"
  if command -v sdk &>/dev/null; then
    echo -e "${COLOR_GREEN}sdkman is installed${COLOR_GREEN}"
    sdk install java 11.0.23-tem
  else
    echo -e "${COLOR_YELLOW}sdknam is not install${COLOR_NC}"
  fi
fi

if [ -d "${HOME}/dev/vimrc" ]; then
  echo -e "${COLOR_GREEN}echo vimrc is exists${COLOR_NC}"
else
  echo -e "${COLOR_YELLOW}echo vimrc is not exists${COLOR_NC}"
  git clone https://github.com/pixb/vimrc.git "${HOME}/dev/vimrc"
fi

if [ -e "${HOME}/.vimrc" ]; then
  echo -e "${COLOR_GREEN}${HOME}/.vimrc is exists${COLOR_NC}"
else
  echo -e "${COLOR_GREEN}${HOME}/.vimrc is not exists${COLOR_NC}"
  ln -sf "${HOME}/dev/vimrc/vimrc" "${HOME}"/.vimrc
fi

brew_install rustup
rustup-init
brew_install tmux

if [ ! -d "$HOME"/.tmux ]; then
  bash "$HOME"/dev/install-arch/tmux/config_tmux.sh
fi
brew_install ranger
ln -sf "${HOME}/dev/mac-install/config/ranger" "${HOME}/.config/ranger"
