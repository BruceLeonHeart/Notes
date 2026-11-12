# uv 使用笔记

> 类型：command
> 一句话：uv Python 包管理工具


uv 是由 Astral（Ruff 的作者）用 Rust 编写的 Python 包与项目管理工具，目标是替代 pip / pip-tools / poetry / pyenv / virtualenv 等一整套传统工具链。典型安装后日常操作会比 pip 快 10~100 倍。

## 基础配置

### 安装

```bash
# 官方推荐脚本（Linux / macOS）
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows PowerShell
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# 也可以用 pip 装一份（不想动系统环境时）
pip install uv
```

安装完成后可通过 `uv self update` 升级自身。

### 常用全局选项

```bash
uv --version           # 查看版本
uv python list         # 列出本机已安装 / 可安装的 Python 版本
uv cache dir           # 查看缓存目录
uv cache clean         # 清理缓存
```

## Python 版本管理

uv 可以直接下载、隔离、切换任意 Python 版本，不再依赖 pyenv。

```bash
# 安装指定版本的 Python
uv python install 3.12
uv python install 3.11 3.10          # 同时装多个

# 在当前目录固定一个 Python 版本（写入 .python-version）
uv python pin 3.12

# 查看当前目录实际使用的 Python
uv python find
```

## 项目管理（替代 poetry）

uv 使用 `pyproject.toml` + `uv.lock` 作为项目的唯一事实来源，和 poetry 习惯基本一致。

### 新建项目

```bash
# 从零创建一个新项目
uv init myproject
cd myproject

# 在已存在的目录里初始化（不创建子目录）
uv init --name myproject .
```

### 已有项目导入

```bash
# 从 requirements.txt 迁移
uv init
uv add -r requirements.txt

# 从 poetry / pipenv 项目直接装依赖
uv sync
```

### 添加 / 移除依赖

```bash
# 添加运行时依赖
uv add requests numpy

# 添加开发依赖（写入 [dependency-groups.dev]）
uv add --dev pytest ruff

# 可指定版本 / 源
uv add "django>=4.2"
uv add torch --index-url https://download.pytorch.org/whl/cu121

# 删除依赖
uv remove requests
```

### 同步环境

```bash
# 按 uv.lock 精确还原整个虚拟环境（CI 里非常好用）
uv sync

# 只装生产依赖，不装 dev
uv sync --no-dev

# 删除并重建虚拟环境
uv sync --reinstall
```

### 运行命令

```bash
# 等价于在 venv 里执行命令，不需要手动 activate
uv run python main.py
uv run pytest
uv run ruff check .

# 一次性脚本（临时依赖，不写入项目）
uv run --with pandas --with matplotlib script.py
```

## 虚拟环境

uv 默认会在项目目录下创建 `.venv`，行为和标准 venv 一致，但创建速度极快。

```bash
# 手动创建 / 指定 Python 版本
uv venv
uv venv --python 3.12

# 激活（和普通 venv 一样）
source .venv/bin/activate
```

## 直接用 pip 风格（不建项目）

如果只是想快速装包，而不是维护一个完整项目，uv 也兼容 pip 的子命令：

```bash
uv pip install requests
uv pip install -r requirements.txt
uv pip freeze
uv pip list
uv pip uninstall requests
```

这一组命令会作用于当前激活的 venv，或者 uv 自动发现的 `.venv`。

## 常见场景

### 一键运行一个 Python 脚本（类似 pipx）

```bash
# hello.py
# #!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "requests",
#   "rich",
# ]
# ///
import requests
from rich import print

print(requests.get("https://example.com").status_code)
```

直接 `./hello.py` 即可，uv 会根据脚本头部的 PEP 723 metadata 自动创建隔离环境。

### 在 CI 里使用

```yaml
# GitHub Actions 示例
- uses: astral-sh/setup-uv@v3
- run: uv sync --frozen
- run: uv run pytest
```

注：action 版本会持续更新，以 astral-sh/setup-uv 的 GitHub 主页为准。
`--frozen` 表示严格使用 lock 文件，不重新解析，保证可复现。

### 换源（国内镜像）

```bash
# 单次命令
uv pip install requests --index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 写入 pyproject.toml 的 [tool.uv] 段
# [[tool.uv.index]]
# url = "https://pypi.tuna.tsinghua.edu.cn/simple"
# default = true
```

## 与其他工具的对应关系

| 传统工具          | uv 对应命令                        |
| ----------------- | ---------------------------------- |
| pyenv             | `uv python install / pin`          |
| python -m venv    | `uv venv`                          |
| pip install       | `uv pip install` / `uv add`        |
| pip freeze        | `uv pip freeze`                    |
| poetry new / add  | `uv init` / `uv add`               |
| poetry install    | `uv sync`                          |
| poetry run        | `uv run`                           |
| pipx              | `uv tool install`                  |
| pip-compile       | `uv pip compile`                   |

## 注意事项

- `uv.lock` 应该和 `pyproject.toml` 一起提交到 git，保证团队 / CI 环境完全一致。
- `uv pip` 这一组命令不会自动读写 `pyproject.toml`，适合老项目迁移；新项目尽量用 `uv add` / `uv sync`。
- 首次运行会下载 Python 解释器和 wheel，之后全部走本地缓存，重复操作很快。
