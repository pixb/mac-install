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
pyenv install 3.13.0
pyenv global 3.13.0
brew_install rcm
