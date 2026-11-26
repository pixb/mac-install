# macOS 系统盘治理与软件管理运维记录

> 记录日期：2026-11
> 适用范围：`/Users/pix` 系统盘（`/`）与移动硬盘（`/Volumes/data`）
> 关联文档：[[macos-data-mirroring|系统盘→移动硬盘 目录映射规范]]

---

## 一、成果概览

| 指标 | 治理前 | 第一轮后 | 第二轮后 | 第三轮后 | 变化 |
|---|---:|---:|---:|---:|---:|
| 系统盘可用空间 | 50 Gi | 80 Gi | 87 Gi | **105 Gi** | **+55 Gi** |
| `~/Library` 体积 | 50G | 27G | 24G | 22G | -28G |
| 移动硬盘可用空间 | 279 Gi | 250 Gi | 251 Gi | 254 Gi | -25 Gi |

> 说明：系统盘 228G，从"几乎满"恢复到 87G 可用，主要靠**大目录软链迁移**（数据没删，搬到硬盘）与**残留清理**（真删）两条路径。

### 第二轮新增（见第十章）

- 零风险缓存清理 2.2G（Google 更新缓存、Quark 更新包、开发编译缓存）
- 弃用软件 Quark/Qoder/Chatbox/MarginStudy 数据+App 本体清理（系统盘 0.58G + 硬盘 2.8G）
- OrbStack 9.2G 评估后**决定保留不动**（活跃 Docker 环境，风险收益不划算）

---

## 二、背景与思路

### 问题
1. macOS 卸载 App（拖废纸篓）**不会清理 `~/Library` 里的配置/缓存**，用户也记不住删过什么。
2. 系统盘空间紧张，大体积数据（模型、VM 镜像、模块缓存）不适合留在系统盘。
3. 国产快迭代软件（豆包、DuMate、QQ 音乐等）cask 版本滞后，brew 管理收益低。

### 策略
- **软件管理**：国际主流、cask 维护良好的 → 迁到 brew；国产/沙盒/特殊软件 → 保持手动，用 `app` 工具按需清残留。
- **数据管理**：建立**严格镜像映射** `~/X → /Volumes/data/X`，大目录搬到硬盘 + 软链回原位。
- **残留管理**：统一用 `app` 命令（trash / sweep / uninstall）清理，不靠记忆。

---

## 三、软件管理（brew 迁移）

### 已迁移到 brew cask

| App | 原版本 | cask | 方案 | 备注 |
|---|---|---|---|---|
| VLC | 手动 3.0.21 | `vlc` | A 彻底清理 | — |
| Obsidian | 手动 1.8.10 | `obsidian` | A 彻底清理 | vault 正文在 Library 外，未受影响；重装后需重新打开 vault |
| Ollama | 手动 0.35.1 | `ollama-app` | A 彻底清理 | 模型数据在 `~/.ollama`（软链到硬盘），未受影响 |
| OBS | 手动 32.0.2 | `obs` | A 彻底清理 | 场景/推流配置被清，需重新配置 |
| Google Chrome | 手动 158.0.8127.37 | `google-chrome` | **B 保留配置** | 1.4G 配置目录原封不动，无缝迁移 |

**两种方案的区别**：
- **A 彻底清理**：移 App → `app sweep -y` 清 `~/Library` 残留 → brew 重装。适合配置不重要或想全新开始的软件。
- **B 保留配置**：移 App → **不 sweep** → brew 重装。适合配置重要的软件（浏览器等），App 会沿用原配置。

### 决定跳过（不迁移）

| App | 原因 |
|---|---|
| V2rayU | cask 已被 Homebrew 禁用（未过 Gatekeeper）；代理配置敏感，用户要求保留 |
| QQ 音乐 | cask 版本比当前旧、版本号带 hash（维护质量差）；App Store 沙盒应用 |
| 豆包 | cask 维护滞后；9.1G 数据杂乱，brew zap 管不好；国产快迭代 |
| WorkBuddy | cask 版本号带 hash；国产 AI 应用更新快 |

> 结论：brew 适合管理**版本规范、cask 维护良好**的国际主流软件；国产快迭代应用和沙盒 App 应用有另外的管理方式。

---

## 四、数据迁移（软链到移动硬盘）

遵循严格镜像规则 `~/X → /Volumes/data/X`，详见 [[macos-data-mirroring]]。

| 原位置 | 硬盘位置 | 大小 | 说明 |
|---|---|---:|---|
| `~/.ollama` | `/Volumes/data/ollama` | 29G | Ollama 模型+配置（历史命名，未带点，是唯一例外） |
| `~/Library/Application Support/Doubao` | `/Volumes/data/Library/Application Support/Doubao` | 9.1G | 豆包数据 |
| `~/go` | `/Volumes/data/go` | 6.3G | Go 模块缓存 + 11 个 bin 工具 |
| `~/Library/Developer/Xcode/iOS DeviceSupport` | `/Volumes/data/Library/Developer/Xcode/iOS DeviceSupport` | 4.5G | iOS 真机调试符号 |
| `~/Library/Developer/CoreSimulator/Devices` | `/Volumes/data/Library/Developer/CoreSimulator/Devices` | 3.6G | iOS 模拟器设备 |

**环境变量（已在 `~/.zshrc`）**：
```
UV_CACHE_DIR=/Volumes/data/.cache/uv
HF_HOME=/Volumes/data/.cache/huggingface
GOPATH=$HOME/go          # 软链后自动指向硬盘，无需改
```

> 硬盘上原有的 `/Volumes/data/{Applications,Library,dev,work,.cache,.pnpm-store}` 已符合镜像规则，继续沿用。

---

## 五、清理释放明细

| 类别 | 项目 | 释放 |
|---|---|---:|
| 缓存 | `brew cleanup -v --prune=all` | 1.0G |
| 残留 | 雀魂 / Postman / GitKraken（App 已不在任何位置） | 1.4G |
| 缓存 | 百度网盘容器缓存（323M→32M，保留登录态） | 0.29G |
| 删除 | DuMate / qianfan-desktop-app 全部数据 + 硬盘上的 App 本体 | 4.9G |
| 删除 | 废纸篓（12 个已迁移/已卸载的 App） | 3.1G |
| 迁移 | Xcode 数据、豆包、go（见上表，数据搬到硬盘非删除） | 23.5G |

> 注：迁移项对系统盘是"释放"，对硬盘是"占用"，数据未丢失。

---

## 六、工具与脚本变更

### 1. `app` 命令（新建）
位置：`~/dev/mac-install/local/.local/bin/app`（stow 部署到 `~/.local/bin/app`）

| 子命令 | 作用 |
|---|---|
| `app list` | 列出已装 cask 及其残留路径数 |
| `app audit [--min-size]` | 扫描 `~/Library` 孤儿目录（只读） |
| `app trash` | 列出废纸篓 App 的残留（只读） |
| `app sweep [-y]` | 删除废纸篓 App 的残留 |
| `app uninstall <name> [-y]` | 统一卸载并清残留 |
| `app install <cask>` | `brew install --cask` 包装 |

**核心设计**：复用 Homebrew cask API 缓存（`~/Library/Caches/Homebrew/api/cask/*.json`）里社区维护的 `zap` 映射，无需自建台账；无 cask 的 App 退化为 bundle ID/强名称精确匹配；删除经 `safe_target` 白名单校验，默认只报告。

### 2. `install_user.sh`（修改）
- 新增：`google-chrome`、`vlc`、`obs`、`obsidian`、`ollama-app` 的安装行
- 注释：`visual-studio-code`、`dbeaver-community`（已卸载，需要时取消注释重装）

### 3. `cleanmac`（修改）
新增了 Caches、豆包日志、QQ 音乐等大目录清理项。

### 4. 文档
- `docs/macos-data-mirroring.md`：镜像映射规范
- `docs/macos-cleanup-report.md`：本文档

---

## 七、技术要点与踩坑

### 1. 只读文件删除失败
Go 模块缓存 `pkg/mod`、沙盒 Python 目录（`lightsandbox`）里的文件是 **444 只读**、目录是 **555**，直接 `rm -rf` 会大量 `Permission denied`。
```bash
chmod -R u+w <目录> && rm -rf <目录>
```

### 2. 跨盘 mv 的陷阱
`~` 和 `/Volumes/data` 是**不同文件系统**，`mv` 实际是"复制 + 删除"。复制只读文件时删除阶段失败，导致 `mv` 中断（数据已完整复制，但源没删干净）。
- 处理：先 `chmod -R u+w` 再 `mv`；或失败后 `chmod + rm -rf 源` 再建软链。
- **务必验证目标完整后再删源**。

### 3. 沙盒容器不能软链迁移
`~/Library/Containers/<bundle-id>` 内部有相对软链（`Data/Music -> ../../../../Music`），且受 `containermanagerd` 严格管理。整目录搬到硬盘会导致相对软链解析错乱、沙盒校验失败。**正确做法是只清容器内的缓存**。

### 4. du 不跟随软链
`du -sh` 默认不跟随软链，会显示 0B。验证迁移结果用 `du -shL`。模拟器内部有循环软链（revlinks），`du -L` 会报警告，无害。

### 5. GitHub 下载慢要走代理
brew cask 下载大 dmg 直连极慢，需走代理：
```bash
ALL_PROXY=http://192.168.1.200:1087 \
HTTPS_PROXY=http://192.168.1.200:1087 \
HTTP_PROXY=http://192.168.1.200:1087 \
brew install --cask <name>
```
约 0.8MB/s，200MB+ 的 dmg 需 5 分钟以上，命令超时给足。

---

## 八、待办事项

### 1. ~~同步 brew 僵尸台账~~ ✅ 已完成（2026-11）
~~以下 App 本体已手动删除，但 `brew list --cask` 仍显示已安装：~~
```
dbeaver-community  flameshot  kitty  visual-studio-code  ← 已执行 brew uninstall --cask 同步
```
执行后 brew cask 列表剩 12 个，全部与实际安装状态一致。

### 2. 清空废纸篓残留的 root 权限文件（如还在）
之前有两个 root 权限 App 需 sudo 删除：
```bash
sudo rm -rf "$HOME/.Trash/Blackmagic Disk Speed Test.app" "$HOME/.Trash/Monitor & Ctrl.app"
```

### 3. 确认移动硬盘自动挂载
`/Volumes/data` 承载了 5 处软链 + 大量数据，是应用正常工作前提。请在磁盘工具中确认该卷设为**登录时自动挂载**，否则重启后软链失效。

### 4. Obsidian 重新打开 vault
迁移后 vault 注册表被清，需重新打开：
- `/Users/pix`
- `/Users/pix/dev/pixobsidian`

### 5. OBS 重新配置
场景、推流设置被清，需重新配置。

---

## 九、日常操作指引

### 卸载软件
```bash
app uninstall <名称> -y     # brew 装的会走 --zap 一并清残留
# 若手动拖了废纸篓：
app trash                   # 先预览残留
app sweep -y                # 再清理
```

### 安装软件
```bash
app install <cask>          # 优先用 brew cask，便于日后清理
```

### 定期体检
```bash
app audit --min-size 100M   # 找出"App 不在了数据还在"的孤儿目录
brew cleanup --prune=all    # 清 Homebrew 缓存
```

### 新目录要迁移到硬盘时
按 [[macos-data-mirroring|映射规范]] 的标准步骤：
```bash
mkdir -p "/Volumes/data/$(dirname XXX)"
[ -d "$HOME/XXX" ] && chmod -R u+w "$HOME/XXX"   # 只读文件先改权限
mv "$HOME/XXX" "/Volumes/data/XXX"
ln -s "/Volumes/data/XXX" "$HOME/XXX"
du -shL "$HOME/XXX"                              # 验证
```

---

## 十、第二轮优化（2026-11，同日追加）

系统盘从 80G → **87G 可用**，主要是清理纯缓存和弃用软件，未做新的软链迁移。

### 1. 零风险缓存清理（2.2G）

| 项目 | 大小 | 说明 |
|---|---:|---|
| `Google/GoogleUpdater/crx_cache` | 780M | Google 更新器下载缓存 |
| `Application Support/Quark/updates` | 1.0G | 夸克更新包缓存（App 在硬盘） |
| `Caches/{go-build,node-gyp,ms-playwright-go,goimports,typescript,gopls}` | 450M | 开发编译缓存，会按需重建 |

> 清理前确认：无编译进程、Chrome/Quark 未运行。

### 2. 弃用软件清理（系统盘 0.58G + 硬盘 2.8G）

用户确认 Quark / Qoder / Chatbox / MarginStudy（扇贝阅读）均已弃用：

- 删除系统盘数据：`Application Support/{Quark,com.qoder.app.stable,xyz.chatboxapp.app}`、`Containers/QReader.MarginStudyMac`、各级 Caches/HTTPStorages/Preferences 等（约 580M）
- 删除硬盘 App 本体：`/Volumes/data/Applications/{Quark.app 1.7G, Qoder.app 809M, Chatbox.app 261M}`
- **保留**：`~/Library/Mobile Documents/iCloud~QReader~MarginStudy/Documents/`（9 个真实书籍文档 epub/pdf/mp4，iCloud 同步数据，非垃圾）

> 删除沙盒类数据前同样需 `chmod -R u+w` 处理只读文件。

### 3. OrbStack 评估：决定保留不动 ✅

`~/Library/Group Containers/HUAQ24HBR6.dev.orbstack/data/data.img.raw` 占 9.2G，是最后一个大头，但**决定不迁移**：

- 它是**稀疏文件**：逻辑大小 228G，实际占用 7.3G（+ swap 1G）。跨盘复制若用 `mv`/`cp` 未保留稀疏性，会变成 228G 实占撑爆硬盘，必须用 `rsync -aS`
- 它是 **Group Container**，路径受系统管理，软链兼容性有风险
- OrbStack 是**活跃开发环境**（4 个 Docker 镜像），退出迁移有损坏风险
- 系统盘已有 80G+ 可用，为省 8G 冒运行环境风险不划算

> 若将来确实要迁：完全退出 OrbStack → `rsync -aS` 复制（保留稀疏）→ 备份原目录 → 建软链 → 启动验证 → 确认后删备份。参考 https://orb.cx/data-img

### 4. 第二轮后仍有但不动的项

| 项目 | 大小 | 不动原因 |
|---|---:|---|
| OrbStack data.img.raw | 9.2G | 见上 |
| Chrome 配置 / Trae CN | 各 1.4G | 在用，配置重要 |
| 微信/QQ/QQ音乐容器 | ~2.3G | 聊天记录、音乐数据 |
| `com.apple.*` 系统服务 | ~1G | 系统自管 |
| Fonts | 1.4G | 用户字体 |
| iCloud Documents（MarginStudy） | 少量占位 | 真实文档，保留 |

---

## 十一、第三轮优化（2026-11，隐藏目录大扫除）

系统盘从 80G → **105G 可用**。本轮发现 `~/` 根目录下多个隐藏目录才是新大头（之前只盯着 `~/Library`）。

### 清理明细（约 17G）

| 项目 | 大小 | 处理方式 | 说明 |
|---|---:|---|---|
| `~/.local/share/opencode` | 11G | 完全删除 | 9.6G SQLite db + 1.2G snapshot；用户确认不用，先 kill 残留进程再删 |
| `~/.cache/whisper` 之外——`~/.V2rayU/v2ray-core.log` | 2.4G | 清空内容（`: > file`） | V2rayU 正在运行，用清空保留文件句柄，代理不受影响 |
| `~/.workbuddy/workspace/sessions` | 2.0G | 删除 | 3684 个历史会话文件 |
| `~/.cache/huggingface`（系统盘那份） | 2.4G | 删除 | 旧遗留；`HF_HOME=/Volumes/data/.cache/huggingface` 已指向硬盘（11G 完好保留） |

### 本轮发现的分布（`~/` 隐藏目录）

```
~/.local/share/opencode   11G   ← 已删
~/.cache/{whisper 5G, huggingface 2.4G, uv 1.1G, ...}  9.6G  ← huggingface 已删
~/OrbStack/docker          4G   ← 保留（OrbStack）
~/.workbuddy               3.6G  ← sessions 2G 已删
~/.rustup 2.5G / .pyenv 1.9G / .sdkman 1.6G  ← 开发工具链，保留
~/.V2rayU/v2ray-core.log   2.4G  ← 已清空
```

### 保留不动的项

- `~/.cache/whisper` 5G（语音模型，用户要求不动）
- 开发工具链 `~/.rustup`/`~/.pyenv`/`~/.sdkman`/`~/.npm` 等（删了要重装）
- `~/OrbStack/docker` 4G（随 OrbStack 保留）
