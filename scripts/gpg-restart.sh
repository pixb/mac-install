#!/usr/bin/env bash
# GPG 安全重启脚本
# 背景：gpgconf --kill（--kill all 或 --kill gpg-agent）在 use-keyboxd 模式下会
#       陷入 100% CPU 忙循环（GnuPG 2.5 / macOS Homebrew 的已知 bug）。
# 方案：用 killall 直接清理全部组件，再由 gpg 命令按需自动拉起，全程不卡。

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m'

log_info() { echo -e "${COLOR_YELLOW}[INFO]${COLOR_NC} $1"; }
log_ok() { echo -e "${COLOR_GREEN}[OK]${COLOR_NC} $1"; }
log_err() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; }

set -uo pipefail

if ! command -v gpg &>/dev/null; then
  log_err "gpg 未安装"
  exit 1
fi

log_info "清理 gpg-agent / dirmngr / gpgconf（保留 keyboxd，避免重启卡死） ..."
# 注意：不要 kill keyboxd！
# keyboxd 只是密钥库守护进程，重启 gpg-agent 不需要动它；
# 强杀后重新拉起会触发 sentinel 锁竞争，导致 gpg 命令 100% CPU 忙循环。
killall gpg-agent dirmngr gpgconf 2>/dev/null || true
sleep 1

GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"
# 强杀进程会留下 stale 锁文件（.#lk* / agent sentinel lock），
# 不清理会导致后续 gpg 命令 100% CPU 忙循环卡死。
log_info "清理 stale 锁文件 ..."
rm -f "${GNUPGHOME}"/.#lk* "${GNUPGHOME}"/gnupg_spawn_agent_sentinel.lock || true

log_info "通过 gpg 命令自动拉起所需组件 ..."
gpg --list-keys >/dev/null 2>&1 || true

log_ok "GPG 已就绪"
