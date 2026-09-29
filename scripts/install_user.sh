#!/usr/bin/env bash

COLOR_BLUE='\033[0;34m'
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[0;33m'
COLOR_NC='\033[0m'

# Exit when an error occurs
# Throw error when using an undefined variable
set -euo pipefail

TIME="$(date +%Y-%m-%d_%H-%M-%S)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" || exit 1
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
FILE_NAME="${SCRIPT_NAME%.*}"

log_info() { echo -e "${COLOR_BLUE}[INFO]${COLOR_NC} $1"; }
log_ok() { echo -e "${COLOR_GREEN}[OK]${COLOR_NC} $1"; }
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $1"; }
log_err() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; }

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
brew_install bat
brew_install fastfetch
brew_ui_install visual-studio-code
brew_install ripgrep
brew_install the_silver_searcher
brew_install pyenv
brew_install git-lfs
brew_install git-crypt
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
brew_install herdr
brew_install stow
brew_install gnupg

# 用 stow 还原 ~/.gnupg 配置（包位于 mac-install/gnupg，目标为 ~）
# 注意：stow 需在 mac-install 根目录执行，包内结构为 gnupg/.gnupg/*.conf
# 先建好 700 的目录，避免 stow 折叠整目录链接导致 gpg 权限报错
mkdir -p "${HOME}/.gnupg" && chmod 700 "${HOME}/.gnupg"
(cd "${SCRIPT_DIR}/.." && stow -t "${HOME}" gnupg)

if command -v go &>/dev/null; then
  echo -e "${COLOR_GREEN}go is installed${COLOR_NC}"
else
  echo -e "${COLOR_YELLOW}go is not install..${COLOR_NC}"
  brew install go
fi

if [ -e "$HOME"/.sdkman/bin/sdkman-init.sh ]; then
  echo -e "${COLOR_GREEN}sdkman is installed${COLOR_NC}"
  set +u
  source "$HOME"/.sdkman/bin/sdkman-init.sh
  set -u
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
# Homebrew 版 rustup 无 rustup-init / init 子命令，用 toolchain install 替代
if rustup toolchain list 2>/dev/null | grep -q stable; then
  echo -e "${COLOR_GREEN}rustup toolchain is installed${COLOR_NC}"
else
  rustup toolchain install stable
  rustup default stable
fi
brew_install tmux
brew_install ranger
ln -sf "${HOME}/dev/mac-install/config/ranger" "${HOME}/.config/ranger"

cd "${SCRIPT_DIR}/.." || exit 0

stow -t ~ local
stow -t ~ zsh
stow -t ~ git

cd "$SCRIPT_DIR"
