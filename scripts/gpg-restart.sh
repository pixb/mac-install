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
log_warn() { echo -e "${COLOR_YELLOW}[WARN]${COLOR_NC} $1"; }
log_err() { echo -e "${COLOR_RED}[ERROR]${COLOR_NC} $1"; }

set -uo pipefail

if ! command -v gpg &>/dev/null; then
  log_err "gpg 未安装"
  exit 1
fi

# keyboxd 启动时会遍历 0..RLIMIT_NOFILE 逐个 fstat（约 0.3µs/个）；
# 上限几百万时启动即卡死或极慢（限值 2147483646 时永久挂起）。
# 这里只在本脚本内把 soft limit 压回正常值，子进程随之继承。
FD_LIMIT="$(ulimit -n 2>/dev/null || echo 0)"
if [ "${FD_LIMIT:-0}" -gt 4194304 ] 2>/dev/null; then
  log_warn "fd 上限过高（ulimit -n ${FD_LIMIT}），keyboxd 会卡死；本脚本内临时压到 524288"
  ulimit -n 524288 2>/dev/null || true
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
rm -f "${GNUPGHOME}"/.#lk* "${GNUPGHOME}"/gnupg_spawn_*_sentinel.lock || true

log_info "通过 gpg 命令自动拉起所需组件 ..."
# keyboxd spawn 偶发竞争会导致 gpg 忙循环，用 timeout 加保护，卡死则清理重试
TIMEOUT_CMD=""
if command -v gtimeout &>/dev/null; then TIMEOUT_CMD="gtimeout 10"; elif command -v timeout &>/dev/null; then TIMEOUT_CMD="timeout 10"; fi

if [ -n "$TIMEOUT_CMD" ]; then
  if ! $TIMEOUT_CMD gpg --list-keys >/dev/null 2>&1; then
    log_warn "拉起超时（keyboxd spawn 竞争），清理进程与锁后重试 ..."
    killall gpg gpg-agent keyboxd dirmngr gpgconf 2>/dev/null || true
    rm -f "${GNUPGHOME}"/.#lk* "${GNUPGHOME}"/gnupg_spawn_*_sentinel.lock || true
    sleep 1
    $TIMEOUT_CMD gpg --list-keys >/dev/null 2>&1 || true
  fi
else
  gpg --list-keys >/dev/null 2>&1 || true
fi

log_ok "GPG 已就绪"
