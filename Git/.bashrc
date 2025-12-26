# ===== Git 快捷命令 =====
alias g='git'

# 状态 & 日志
alias gs='git status'
alias gss='git status -s'  # 简短状态
alias gl='git log --oneline --graph --decorate'
alias gla='git log --oneline --graph --decorate --all'

# 分支操作
alias sub='git submodule'
alias br='git branch'
alias gba='git branch -a'  # 显示所有分支（包括远程）
alias gbd='git branch -d'  # 删除分支
alias co='git checkout'
alias gcob='git checkout -b'  # 创建并切换分支

# 提交相关
alias ga='git add'
alias gaa='git add --all'  # 添加所有文件
alias gc='git commit -m'
alias gca='git commit --amend'  # 修改最后一次提交
alias gcan='git commit --amend --no-edit'  # 修改提交但不改消息

# 远程 & 推送/拉取
alias gf='git fetch'
alias gpl='git pull'
alias gps='git push'
alias gpsu='git push -u origin HEAD'  # 推送并设置上游分支

# 暂存 & 恢复
alias gst='git stash'
alias gstp='git stash pop'
alias gr='git restore'
alias grs='git restore --staged'  # 取消暂存

# 差异比较
alias gd='git diff'
alias gds='git diff --staged'  # 比较暂存区改动