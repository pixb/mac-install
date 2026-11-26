# 系统盘 → 移动硬盘 目录映射规范

## 目的

系统盘（`/`，228G）空间紧张，为避免大文件占用系统盘，采用"**严格镜像**"策略：
将 `~`（即 `/Users/pix`）下的大目录整体移到移动硬盘 `/Volumes/data`，原位置留软链。

## 命名规则（核心）

```
原路径:   /Users/pix/<相对路径>
硬盘路径: /Volumes/data/<相对路径>
```

即：**去掉 `/Users/pix/` 前缀，替换为 `/Volumes/data/`**。

例子：
| 原位置 | 硬盘位置 |
|---|---|
| `~/Library/Application Support/Doubao` | `/Volumes/data/Library/Application Support/Doubao` |
| `~/Library/Developer/Xcode/iOS DeviceSupport` | `/Volumes/data/Library/Developer/Xcode/iOS DeviceSupport` |
| `~/.ollama` | `/Volumes/data/ollama` |
| `~/.cache/uv` | `/Volumes/data/.cache/uv` |

> 注意：`/Volumes/data` 自身已有一套符合此规则的目录（Applications / Library / dev / work / .cache / .pnpm-store），继续沿用，不要另起 `dev-archive` 之类的新命名。

## 标准迁移步骤

以 `~/XXX`（大目录）为例：

```bash
# 0. 确认相关 App 已退出、目录未被占用
# 1. 建硬盘上的目标目录的父目录
mkdir -p "/Volumes/data/$(dirname XXX)"

# 2. 移动数据（保留原目录名）
mv "$HOME/XXX" "/Volumes/data/XXX"

# 3. 原位置建软链
ln -s "/Volumes/data/XXX" "$HOME/XXX"

# 4. 验证（du 默认不跟随软链，需加 -L）
du -shL "$HOME/XXX"
readlink "$HOME/XXX"
```

## 当前已迁移清单

| 原位置 (~) | 硬盘位置 | 大小 | 备注 |
|---|---|---:|---|
| `.ollama` | `/Volumes/data/ollama` | 29G | Ollama 模型+配置 |
| `Library/Developer/Xcode/iOS DeviceSupport` | `/Volumes/data/Library/Developer/Xcode/iOS DeviceSupport` | 4.5G | iOS 真机调试符号 |
| `Library/Developer/CoreSimulator/Devices` | `/Volumes/data/Library/Developer/CoreSimulator/Devices` | 3.6G | iOS 模拟器设备 |
| `Library/Application Support/Doubao` | `/Volumes/data/Library/Application Support/Doubao` | 9.1G | 豆包数据（对话/沙盒/缓存） |
| `go` | `/Volumes/data/go` | 6.3G | Go 模块缓存 + 工具 bin |

## 环境变量（已在 ~/.zshrc 中配置）

```
UV_CACHE_DIR=/Volumes/data/.cache/uv
HF_HOME=/Volumes/data/.cache/huggingface
```

新迁移的目录若被某工具通过环境变量定位，也应遵循本规则改到 `/Volumes/data/...`。

## 注意事项

- 迁移前务必退出相关 App，避免运行中写数据导致不一致。
- `du -sh` 不跟随软链，验证时用 `du -shL`；模拟器内部有循环软链，`du -L` 会报警告，属正常现象。
- 移动硬盘（`/Volumes/data`）未挂载时，这些软链会失效，相关 App 可能无法启动。使用大 App 前确认硬盘已挂载。
- Homebrew cask 管理的 App 本体仍留在 `/Applications`（系统盘），只迁移数据目录；App 本体通常几百 M，占比不大。
