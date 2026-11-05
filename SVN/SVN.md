# SVN (Subversion) 快速上手笔记

SVN (Subversion) 是一个**集中式**的版本控制系统，用于管理文件和目录的修改历史。它允许团队成员协作开发，追踪每次更改，并在需要时回溯到旧版本。

## 一、SVN 基本工作流程

1. **检出 (Checkout)**：从服务器获取一份项目副本到本地。
2. **更新 (Update)**：同步本地副本与服务器最新版本。
3. **修改 (Modify)**：在本地工作副本中进行编辑、添加、删除等操作。
4. **查看状态/差异 (Status/Diff)**：检查本地修改情况和具体内容。
5. **解决冲突 (Resolve Conflicts)**：如果更新时发生冲突，需要先解决。
6. **提交 (Commit)**：将本地的修改上传到服务器。
7. **(可选) 合并分支 (Merge)**：将一个分支的修改合并到另一个分支。

## 二、核心命令速查

以下命令均在命令行中执行。

### A. 获取代码 / 初始化

#### 1. svn checkout (co) - 检出项目

- **作用**：从 SVN 服务器下载一个项目的最新版本到本地工作副本。
- **语法**：

```bash
svn checkout <URL> [本地路径]
```

- **示例**：

```bash
svn co https://svn.example.com/repos/my_project my_project_local
```

- **说明**：`[本地路径]` 可选，如果省略，则在当前目录下创建以项目名称命名的文件夹。

#### 2. svn import - 导入项目（首次上传）

- **作用**：将一个本地的、未被版本控制的目录结构，首次导入到 SVN 仓库中。
- **语法**：

```bash
svn import <本地路径> <URL> -m "提交信息"
```

- **示例**：

```bash
svn import C:\my_local_code https://svn.example.com/repos/new_project -m "Initial import of new project"
```

- **注意**：import 操作不会创建本地工作副本，需要再 checkout 一次才能在本地进行修改。

### B. 日常工作 / 修改

#### 1. svn update (up) - 更新工作副本

- **作用**：将本地工作副本与仓库中的最新版本同步，获取其他人的提交。**建议在开始工作前和提交前都执行此命令。**
- **语法**：

```bash
svn update [文件/目录路径]
```

- **示例**：

```bash
svn up               # 更新整个工作副本
svn up main.cpp      # 只更新指定文件
```

- **输出状态码解释**：
  - `U` (Updated)：文件已更新到新版本。
  - `A` (Added)：新增了文件或目录。
  - `D` (Deleted)：删除了文件或目录。
  - `G` (Merged)：本地修改与仓库更新成功合并。
  - `C` (Conflict)：文件发生冲突，需要手动解决。

#### 2. svn add - 添加新文件/目录

- **作用**：将新创建的文件或目录添加到 SVN 的版本控制中。
- **语法**：

```bash
svn add <文件/目录路径>
```

- **示例**：

```bash
svn add new_feature.cpp
svn add new_folder
```

- **注意**：add 后只是标记为"待添加"，需要 commit 才能真正上传到服务器。

#### 3. svn delete (del) - 删除文件/目录

- **作用**：从版本控制中删除文件或目录。
- **语法**：

```bash
svn delete <文件/目录路径>
```

- **示例**：

```bash
svn del old_file.txt
svn del obsolete_folder
```

- **注意**：delete 后只是标记为"待删除"，需要 commit 才能真正从服务器删除。

#### 4. svn move (mv) / svn rename (ren) - 移动/重命名文件/目录

- **作用**：在版本控制下移动或重命名文件/目录，同时保留其历史记录。
- **语法**：

```bash
svn mv <旧路径> <新路径>
```

- **示例**：

```bash
svn mv old_name.h new_name.h
svn mv src/old_folder src/new_folder
```

- **注意**：同样需要 commit 才能生效。

#### 5. svn copy (cp) - 复制文件/目录

- **作用**：在版本控制下复制文件或目录，通常用于创建分支或标签。
- **语法**：

```bash
# 复制本地工作副本中的文件/目录
svn cp <源路径> <目标路径>
```

- **示例**：

```bash
svn cp main.cpp main_backup.cpp
```

```bash
# 复制仓库中的文件/目录（用于创建分支/标签）
svn cp <源URL> <目标URL> -m "提交信息"
```

- **示例**：

```bash
svn cp https://svn.example.com/repos/trunk https://svn.example.com/repos/branches/my_feature_branch -m "Create feature branch"
```

- **说明**：仓库间的复制会立即提交。

#### 6. svn commit (ci) - 提交修改

- **作用**：将本地工作副本中的所有修改（添加、删除、修改、移动等）上传到服务器。
- **语法**：

```bash
svn commit -m "提交信息" [文件/目录路径]
```

- **示例**：

```bash
svn ci -m "Implemented login feature and fixed bug 123"  # 提交所有已暂存的修改
svn ci main.cpp -m "Fixed typo in main.cpp"               # 只提交对指定文件的修改
```

- **注意**：提交前务必 update，解决冲突后再提交。提交信息要清晰明了。

### C. 查看状态 / 历史

#### 1. svn status (st) - 查看工作副本状态

- **作用**：显示本地工作副本中所有已修改、新增、删除、冲突等文件的状态。
- **语法**：

```bash
svn status [文件/目录路径]
```

- **示例**：

```bash
svn st           # 查看当前目录下的所有修改
svn st main.cpp  # 查看指定文件的状态
```

- **状态码解释（常见）**：
  - `M`：文件已被修改 (Modified)
  - `A`：文件已被添加 (Added)
  - `D`：文件已被删除 (Deleted)
  - `?`：文件未被版本控制 (Unknown)
  - `C`：文件发生冲突 (Conflicted)
  - `!`：文件丢失或不完整 (Missing/Incomplete)
  - `R`：文件已被替换 (Replaced)
  - `L`：文件被锁定 (Locked)

#### 2. svn diff - 查看文件差异

- **作用**：显示本地文件与工作副本中上次更新版本之间的差异，或两个版本之间的差异。
- **语法**：

```bash
svn diff [文件路径]                        # 查看本地未提交的修改
svn diff -r <版本号1>:<版本号2> [URL/文件路径]  # 查看指定版本间的差异
```

- **示例**：

```bash
svn diff main.cpp
svn diff -r 100:105 https://svn.example.com/repos/my_project/src/main.cpp
```

#### 3. svn log - 查看提交历史

- **作用**：显示文件或目录的提交历史记录，包括版本号、作者、日期和提交信息。
- **语法**：

```bash
svn log [文件/目录路径]
```

- **示例**：

```bash
svn log              # 查看当前目录的所有提交历史
svn log main.cpp     # 查看指定文件的提交历史
svn log -l 5        # 只显示最近5条日志
svn log -r 100:HEAD # 显示从版本100到最新版本之间的日志
```

### D. 解决冲突 / 回滚

#### 1. svn revert - 撤销本地修改

- **作用**：撤销对本地工作副本文件的所有修改，使其恢复到上次 update 或 checkout 时的状态。
- **语法**：

```bash
svn revert <文件/目录路径>
```

- **示例**：

```bash
svn revert main.cpp            # 撤销对main.cpp的修改
svn revert . --depth=infinity   # 递归撤销当前目录下所有修改（慎用!）
```

- **注意**：`revert` 是一个危险操作，会丢失所有未提交的本地修改，且无法恢复。

#### 2. svn resolve - 解决冲突

- **作用**：当 `svn update` 或 `svn merge` 导致文件冲突 (Conflict) 时，用来解决冲突。

冲突发生后，SVN 会在冲突文件中插入特殊标记（如 `<<<<<<< .mine`、`=======`、`>>>>>>> .rXXX`），并生成几个辅助文件。

**解决方法1：手动解决（推荐）**

1. 打开冲突文件，找到冲突标记。
2. 根据业务逻辑，手动编辑文件，删除所有冲突标记，保留或合并想要的代码。
3. 保存文件后，执行以下命令通知 SVN 冲突已解决：

```bash
svn resolved <文件路径>
```

**解决方法2：选择特定版本**

如果想完全放弃本地修改或完全保留本地修改，可以使用 `resolve` 命令：

```bash
svn resolve --accept <选项> <文件路径>
```

常用选项：

- `mine-full`：保留自己的全部修改。
- `theirs-full`：使用从服务器更新下来的全部修改。
- `working`：在手动解决后，保留当前工作副本中的内容（等同于 `svn resolved`）。

### E. 分支与合并（进阶）

#### 1. 创建分支/标签（使用 svn copy）

- **作用**：通过复制仓库中的 trunk（主干）来创建分支或标签。
- **语法**：

```bash
svn cp <源URL> <目标URL> -m "创建分支/标签信息"
```

- **示例**：

```bash
# 创建分支
svn cp https://svn.example.com/repos/my_project/trunk \
       https://svn.example.com/repos/my_project/branches/feature_X \
       -m "Creating feature_X branch"

# 创建标签（通常是特定版本的快照）
svn cp https://svn.example.com/repos/my_project/trunk \
       https://svn.example.com/repos/my_project/tags/release_1.0 \
       -m "Tagging release 1.0"
```

- **说明**：分支和标签在 SVN 中本质上都是目录复制，但约定俗成地放在 branches 和 tags 目录下。

#### 2. svn switch (sw) - 切换分支

- **作用**：将本地工作副本切换到不同的分支或标签。
- **语法**：

```bash
svn switch <URL> [本地路径]
```

- **示例**：

```bash
svn sw https://svn.example.com/repos/my_project/branches/feature_X  # 切换到 feature_X 分支
```

#### 3. svn merge - 合并分支

- **作用**：将一个分支的修改合并到另一个分支（通常是开发分支合并回主干）。
- **语法**（常见用法，在目标分支的工作副本中执行）：

```bash
svn merge <源URL> [本地路径]
```

- **示例**（在主干的工作副本中，将 feature_X 分支的修改合并过来）：

```bash
svn merge https://svn.example.com/repos/my_project/branches/feature_X
```

- **示例**（合并指定版本范围的修改）：

```bash
svn merge -r 100:150 https://svn.example.com/repos/my_project/branches/feature_X
```

- **说明**：合并后，本地工作副本会显示合并的修改，需要手动解决冲突并 commit。合并是一个相对复杂的操作，需要理解其原理。

### F. 其他常用命令

#### 1. svn info - 查看信息

- **作用**：显示文件或目录的详细信息，如 URL、版本、最后修改人等。
- **语法**：

```bash
svn info [文件/目录路径]
```

#### 2. svn cleanup - 清理工作副本

- **作用**：清理工作副本中可能存在的锁定（lock）或其他不一致状态。通常在操作中断或遇到错误时使用。
- **语法**：

```bash
svn cleanup [工作副本路径]
```

- **示例**：

```bash
svn cleanup .  # 清理当前目录
```

## 三、推荐目录结构与关键概念

1. **推荐目录结构**

   一个标准的 SVN 仓库通常包含三个顶级目录：

   - `trunk`：**主干**。用于存放项目最稳定、可随时发布的代码。日常开发主要在此进行。
   - `branches`：**分支**。用于存放各种开发分支、功能分支或 Bug 修复分支。当需要进行不稳定的、长期的开发时，可以从 `trunk` 创建一个分支，完成后再合并回 `trunk`。
   - `tags`：**标签**。用于存放特定版本的只读快照，如 `release-1.0`、`release-2.0`。标签通常用于标记发布的版本，一旦创建就不再修改。

2. **关键概念**

   - **仓库 (Repository)**：位于服务器的中央数据库，存储所有文件和目录的版本历史。
   - **工作副本 (Working Copy)**：在本地电脑上操作的、从仓库中 `checkout` 出来的项目副本。
   - **版本号 (Revision)**：每次成功 `commit` 都会生成一个新的、全局唯一的、递增的版本号。SVN 的版本号是针对整个仓库的，而不是单个文件。
   - **原子提交 (Atomic Commit)**：SVN 保证每次提交都是"全有或全无"的。要么所有修改都成功提交，要么都不提交，不会出现部分文件提交成功、部分失败的情况。

## 四、最佳实践

- **提交前先更新**：这是避免冲突和保持代码同步的基本原则。先 `svn update`，解决可能存在的冲突，然后再 `svn commit`。
- **频繁提交**：小步快跑，完成一个小的、完整的功能或修复后就提交，而不是攒一大堆修改一次性提交。这能减少冲突的复杂性。
- **编写有意义的提交信息**：清晰地描述本次提交"做了什么"以及"为什么这么做"，方便日后追溯和 Code Review。
- **一次提交只做一件事**：保持每次提交的原子性和目的单一性。例如，修复一个 Bug 和开发一个新功能应该分两次提交。
- **善用分支**：对于大型新功能或可能破坏主干稳定性的修改，应在分支上进行开发。
