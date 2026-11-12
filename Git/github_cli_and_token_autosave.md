# GitHub CLI 与 Token 免密配置

> 类型：howto
> 一句话：服务器上用 gh / Token / SSH 三种方式免密推 GitHub

## 场景

服务器上没有浏览器，`git push` 又不能用密码（GitHub 已禁用 HTTPS 密码认证），需要配置免密拉取/推送。

GitHub CLI（命令行工具 `gh`）允许你在终端直接管理仓库、Pull Request、Issue 和 GitHub Actions，无需频繁切换浏览器。

## 步骤

### 安装 gh

* **Ubuntu / Debian**：
```bash
sudo mkdir -p -m 755 /etc/apt/keyrings
wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh -y

```


* **CentOS / RHEL / Fedora**：
```bash
sudo dnf install 'dnf-command(config-manager)'
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo dnf install gh -y

```


* **macOS**：
```bash
brew install gh

```


* **Windows**：
```powershell
winget install --id GitHub.cli

```



安装完成后运行 `gh --version` 验证。

### 登录认证

在本地有浏览器的环境直接运行交互式登录：

```bash
gh auth login

```

按提示依次选择 `GitHub.com` -> `HTTPS`（或 `SSH`）-> `Login with a web browser` 即可完成授权。若在无浏览器的纯命令行服务器上，可使用 Token 登录（见下文方案一）。

### 高频命令

* **仓库管理**：
* `gh repo clone owner/repo`：克隆仓库（无需写完整 URL）
* `gh repo create my-project --private --clone`：创建私有仓库并直接克隆到本地
* `gh repo view --web`：在浏览器中打开当前仓库


* **Pull Request (PR)**：
* `gh pr create`：为当前分支交互式创建 PR
* `gh pr list` / `gh pr status`：查看 PR 列表或与你相关的 PR 状态
* `gh pr checkout 123`：将编号为 123 的 PR 拉取到本地分支调试
* `gh pr merge 123`：合并指定 PR


* **Issue 与 Actions**：
* `gh issue list` / `gh issue create`：查看或新建 Issue
* `gh run list` / `gh run watch`：查看或实时监控 GitHub Actions 工作流运行状态



---

### 服务器免密配置（无浏览器环境）

由于 GitHub 已禁用密码验证 HTTPS 操作，在服务器上需要使用 **Personal Access Token (PAT)**。

#### 1. 生成 GitHub Token

1. 登录 GitHub 网页端，进入右上角头像 -> **Settings** -> 左侧最底部 **Developer settings**。
2. 选择 **Personal access tokens** -> **Tokens (classic)**（或 Fine-grained tokens）-> **Generate new token**。
3. 勾选 `repo`（完整仓库读写权限），生成后**立即复制保存**（`ghp_xxx` 开头，页面关闭后无法再次查看）。

#### 2. 持久化配置（任选其一）

**方案一：通过 `gh` 自动接管 Git 凭证（推荐）**

如果服务器已安装 `gh`，直接用 Token 登录并关联 Git，后续所有 `git pull` / `git push` 都会自动走 `gh` 认证：

```bash
echo "你的_GITHUB_TOKEN" | gh auth login --with-token
gh auth setup-git

```

**方案二：使用 Git 原生 `credential.helper store`（无需额外软件）**

让 Git 将凭证持久化保存在用户主目录的隐藏文件中：

1. 开启全局凭证存储：
```bash
git config --global credential.helper store

```


2. 执行一次 `git pull` 或 `git push`，按提示输入你的 **GitHub 用户名**，密码处粘贴你的 **Token**。之后凭证会自动明文写入 `~/.git-credentials`，以后再也不需要输入。
3. **（可选）直接写入文件实现自动化部署**：
```bash
echo "https://<你的用户名>:<你的TOKEN>@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials
git config --global credential.helper store

```


*(注：如果用户名中包含 `@` 等特殊字符，需替换为 URL 编码 `%40`，否则建议通过第 2 步让 Git 自动写入。)*

**方案三：配置 SSH 密钥（生产服务器最佳实践）**

如果服务器长期用于拉取或部署代码，使用 SSH 密钥比 HTTPS Token 更安全，且不会因 Token 过期而中断服务：

1. 在服务器上生成密钥对（一路回车即可）：
```bash
ssh-keygen -t ed25519 -C "server-deploy"

```


2. 查看并复制公钥内容：
```bash
cat ~/.ssh/id_ed25519.pub

```


3. 打开 GitHub 的 **Settings -> SSH and GPG keys -> New SSH key**，粘贴公钥并保存（如果仅针对单个项目部署，推荐添加到该仓库的 **Settings -> Deploy keys** 中以限制权限范围）。
4. 确保本地仓库使用 SSH 地址（而非 `https://`）：
```bash
git remote set-url origin git@github.com:用户名/仓库名.git

```



## 结果

```bash
gh auth status          # 确认 gh 登录状态
git pull && git push    # 免密成功
```

## 踩过的坑

- **`~/.git-credentials` 是明文**：方案二把 Token 明文写在主目录，多人共用的服务器必须 `chmod 600 ~/.git-credentials`，否则同机器其他用户能直接读到你的 Token。
- **用户名含 `@` 要 URL 编码**：手动写 `~/.git-credentials` 时，`https://user:token@github.com` 里的 `user` 若含 `@` 要写成 `%40`，否则解析错乱。建议让 Git 自动写入而不是手写。
- **Token 过期导致推送突然失败**：classic Token 默认 90 天过期，fine-grained Token 可设更长。生产服务器优先用方案三（SSH 密钥不过期）。
- **Token 权限给太大**：`repo` 勾选项是完整仓库读写，单个部署项目应建 fine-grained Token 只授权目标仓库，或用 SSH Deploy keys 限制为单仓库。
- **`gh auth setup-git` 只对当前仓库生效**：它配置的是 `gh` 作为 credential helper，换机器或新仓库要重新跑。
- **`winget install` 在旧 Windows 上没有**：Windows 10 1709 以下没有 winget，需用 Scoop 或下载 MSI 安装包。