# Git 常见操作笔记

> 类型：command
> 一句话：Git 常用命令手册


## 基础配置

### 用户信息配置
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 查看配置
```bash
git config --list
git config user.name
```

## 仓库操作

### 初始化仓库
```bash
git init
```

### 克隆仓库
```bash
git clone <repository-url>
git clone <repository-url> <directory-name>
```

### 查看仓库状态
```bash
git status
```

## 暂存与提交

### 添加文件到暂存区
```bash
git add <file>
git add .
git add -A
```

### 提交更改
```bash
git commit -m "commit message"
git commit -am "commit message"
```

### 修改最后一次提交
```bash
git commit --amend
git commit --amend -m "new message"
```

## 分支操作

### 查看分支
```bash
git branch
git branch -a
git branch -r
```

### 创建分支
```bash
git branch <branch-name>
```

### 切换分支
```bash
git checkout <branch-name>
git switch <branch-name>
```

### 创建并切换分支
```bash
git checkout -b <branch-name>
git switch -c <branch-name>
```

### 删除分支
```bash
git branch -d <branch-name>
git branch -D <branch-name>
```

### 重命名分支
```bash
git branch -m <old-name> <new-name>
```

## 合并与变基

### 合并分支
```bash
git merge <branch-name>
```

### 变基
```bash
git rebase <branch-name>
```

### 终止变基
```bash
git rebase --abort
```

### 继续变基
```bash
git rebase --continue
```

## 远程操作

### 查看远程仓库
```bash
git remote -v
```

### 添加远程仓库
```bash
git remote add <name> <url>
```

### 删除远程仓库
```bash
git remote remove <name>
```

### 拉取更新
```bash
git pull
git pull origin <branch-name>
```

### 推送更改
```bash
git push
git push origin <branch-name>
git push -u origin <branch-name>
```

### 强制推送
```bash
git push -f
git push --force-with-lease
```

## 查看历史

### 查看提交历史
```bash
git log
git log --oneline
git log --graph --all
```

### 查看文件修改历史
```bash
git log -p <file>
```

### 查看某个提交的详细信息
```bash
git show <commit-hash>
```

## 撤销操作

### 撤销工作区修改
```bash
git checkout -- <file>
git restore <file>
```

### 撤销暂存区修改
```bash
git reset HEAD <file>
git restore --staged <file>
```

### 回退到指定提交
```bash
git reset --soft <commit-hash>
git reset --mixed <commit-hash>
git reset --hard <commit-hash>
```

### 撤销某个提交
```bash
git revert <commit-hash>
```

## 标签操作

### 创建标签
```bash
git tag <tag-name>
git tag -a <tag-name> -m "tag message"
```

### 查看标签
```bash
git tag
git show <tag-name>
```

### 推送标签
```bash
git push origin <tag-name>
git push origin --tags
```

### 删除标签
```bash
git tag -d <tag-name>
git push origin :refs/tags/<tag-name>
```

## 储藏操作

### 储藏当前工作
```bash
git stash
git stash save "message"
```

### 查看储藏列表
```bash
git stash list
```

### 应用储藏
```bash
git stash apply
git stash pop
```

### 删除储藏
```bash
git stash drop
git stash clear
```

## 查看差异

### 查看工作区与暂存区差异
```bash
git diff
```

### 查看暂存区与上次提交差异
```bash
git diff --staged
git diff --cached
```

### 查看两个提交之间的差异
```bash
git diff <commit1> <commit2>
```

## 清理操作

### 清理未跟踪文件
```bash
git clean -f
git clean -fd
```

## 其他常用命令

### 查看某个文件的修改者
```bash
git blame <file>
```

### 查看HEAD指向
```bash
git log --oneline -1
```

### 查看文件内容
```bash
git show HEAD:<file>
```

### 忽略文件权限变化
```bash
git config core.fileMode false
```

## 常见问题解决

### 解决合并冲突
1. 编辑冲突文件
2. 标记冲突已解决：`git add <file>`
3. 完成合并：`git commit`

### 撤销已推送的提交
```bash
git revert <commit-hash>
git push
```

### 修改提交历史（谨慎使用）
```bash
git rebase -i HEAD~n
```

### 查看配置文件位置
```bash
git config --list --show-origin
```

## 快捷 alias 对照

同目录的 `.bashrc` 提供了一组 git 快捷命令，常用 alias 与对应命令对照如下：

| alias | 对应命令 | 说明 |
| --- | --- | --- |
| `g` | `git` | git 主命令 |
| `gs` | `git status` | 查看工作区状态 |
| `gss` | `git status -s` | 简短状态 |
| `gl` | `git log --oneline --graph --decorate` | 图形化查看提交历史 |
| `gla` | `git log --oneline --graph --decorate --all` | 图形化查看所有分支历史 |
| `sub` | `git submodule` | 子模块操作 |
| `br` | `git branch` | 查看分支 |
| `gba` | `git branch -a` | 显示所有分支（包括远程） |
| `gbd` | `git branch -d` | 删除分支 |
| `co` | `git checkout` | 切换分支 |
| `gcob` | `git checkout -b` | 创建并切换分支 |
| `ga` | `git add` | 添加文件到暂存区 |
| `gaa` | `git add --all` | 添加所有文件 |
| `gc` | `git commit -m` | 提交并指定消息 |
| `gca` | `git commit --amend` | 修改最后一次提交 |
| `gcan` | `git commit --amend --no-edit` | 修改提交但不改消息 |
| `gf` | `git fetch` | 拉取远程更新 |
| `gpl` | `git pull` | 拉取并合并 |
| `gps` | `git push` | 推送 |
| `gpsu` | `git push -u origin HEAD` | 推送并设置上游分支 |
| `gst` | `git stash` | 储藏当前工作 |
| `gstp` | `git stash pop` | 应用并删除最近储藏 |
| `gr` | `git restore` | 恢复工作区文件 |
| `grs` | `git restore --staged` | 取消暂存 |
| `gd` | `git diff` | 查看工作区改动 |
| `gds` | `git diff --staged` | 比较暂存区改动 |

完整清单见同目录 `.bashrc`，可复制到 `~/.bashrc` 使用。
