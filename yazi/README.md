# Yazi 配置说明

这份配置主要面向当前这套远程开发环境：

- 本地 macOS + Ghostty
- SSH 到远程 Ubuntu
- 远程中配合 tmux / nvim 使用

建议不要直接执行 `yazi`，而是使用 shell 中定义的：

```bash
y
```

这样退出 Yazi 后，shell 当前目录会自动同步到你离开时所在的目录。

## 当前默认行为

- 显示隐藏文件
- 目录优先排序
- 默认使用自然排序
- 默认行模式：`size_and_mtime`
- 文本文件默认用 `nvim` 打开
- 图片 / PDF / 音视频默认走系统打开
- 主题改成更平直的样式，去掉状态栏和指示器的半圆角感
- 已接入 `relative-motions.yazi`，尽量靠近 nvim 的移动方式

## 更像 nvim 的移动方式

Yazi 默认只有单步 `j` / `k`，像 `2j`、`12k`、`10gg` 这种 Vim 风格计数移动，需要 `relative-motions.yazi` 额外提供。

我已经按插件 README 补上了数字键触发配置，所以安装插件后可以直接用：

| 快捷键 | 作用 |
| --- | --- |
| `j` / `k` | 上下移动 |
| `2j` / `5k` | 按计数移动 |
| `gg` | 跳到顶部 |
| `10gg` | 跳到第 10 项 |
| `G` | 跳到底部 |
| `m` | 手动进入一次 relative motion |

> `2j` 之前不生效，是因为插件 README 里明确要求在 `keymap.toml` 里给数字键 `1` 到 `9` 单独绑定 `plugin relative-motions N`。

## 相对行号

`relative-motions.yazi` 已在 `init.lua` 中配置为：

- `show_numbers = "relative_absolute"`
- `show_motion = true`

这样当前项显示绝对编号，其他项显示相对编号，更接近 nvim 的 `number + relativenumber`。

## 自定义快捷键

### 显示与排序

| 快捷键 | 作用 |
| --- | --- |
| `g .` | 切换显示/隐藏文件 |
| `g m` | 行模式切到 `size_and_mtime` |
| `g s` | 行模式切到 `size` |
| `g t` | 行模式切到 `mtime` |
| `g n` | 自然排序 + 目录优先 |
| `g e` | 按修改时间倒序排序（最新优先） |
| `g z` | 按文件大小倒序排序（最大优先） |

### 快速跳转

| 快捷键 | 作用 |
| --- | --- |
| `g p` | 跳到 `~/.config` |
| `g h` | 跳到家目录 `~` |
| `g r` | 跳到根目录 `/` |

### 打开方式

| 快捷键 | 作用 |
| --- | --- |
| `o r` | 交互式选择打开方式 |

### 复制信息

| 快捷键 | 作用 |
| --- | --- |
| `c p` | 复制当前文件完整路径 |
| `c f` | 复制当前文件名 |
| `c d` | 复制当前文件所在目录 |

## 打开规则

### 直接用 `nvim` 编辑的类型

常见文本类文件会优先用 `nvim` 打开，例如：

- `json`
- `toml`
- `yaml`
- `md`
- `txt`
- `log`
- `sh`
- `lua`
- `py`
- `rs`
- `c/cpp`
- `js/ts`
- `html/css`

### 系统打开的类型

以下文件更适合系统外部打开：

- 图片：`png/jpg/jpeg/gif/webp/svg`
- 文档：`pdf`
- 视频：`mp4/mkv/mov`
- 音频：`mp3/flac/wav`

## 相关配置文件

| 文件 | 作用 |
| --- | --- |
| `yazi.toml` | 主配置 |
| `keymap.toml` | 快捷键配置 |
| `theme.toml` | 主题配置 |
| `init.lua` | 自定义行模式 + 插件初始化 |

## 依赖

安装脚本中已经包含这些依赖：

- `yazi`
- `ffmpeg`
- `ffmpegthumbnailer`
- `jq`
- `poppler`
- `xclip`（仅 Linux）
- `relative-motions.yazi`（通过 `ya pkg add dedukun/relative-motions` 安装）

安装：

```bash
bash scripts/install/yaziInstall.sh
```

链接配置：

```bash
bash scripts/link/yaziLink.sh
```
