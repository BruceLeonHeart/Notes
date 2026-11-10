# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库性质

这是一个个人技术笔记/知识库仓库，**不是代码项目**：没有构建、测试、lint 流程，唯一的操作就是 git。仓库内容全部由中文 Markdown 笔记和少量模板文件组成。

## 目录约定

顶层目录按技术主题划分（AI、ALGO、Agent、CUDA、CXX、Config、DL、DailyLife、Dataset、Docker、Doxygen、Embeded_dev、Git、Makefile、MATH、OS、Python、ROS、SVN、UML、Vim、Web）。

- 笔记文件统一为 **snake_case 英文命名**（如 `git_common_operations.md`、`lecture20_pca_principal_component_analysis.md`），中文只出现在正文里。这是 2026-11 整理后的统一约定，新增笔记请遵守，不要回退到中文文件名。
- 笔记风格：中文叙述 + 英文原文命令/代码，代码一律放在围栏代码块中，按「基础配置 / 仓库操作」这类二级标题分节。

### 笔记四类模板（新笔记请遵守，旧笔记不强求）

每篇笔记顶部用一个引用块声明类型与用途，正文按类型选结构：

```markdown
# 标题

> 类型：command | concept | howto | config
> 一句话：这篇解决什么问题（15 字以内）
```

- **command（命令手册类）**：如 `Git/git_common_operations.md`、`Docker/docker_common_operations.md`、`Python/uv_notes.md`、`ROS/*_common_operations.md`。以命令 + 一句注释为主，少写散文；按操作阶段分节（基础配置 / 仓库操作 / 远程 / 常见问题）。
- **concept（概念理解类）**：如 `OS/zero_copy.md`、`CXX/static_and_const_keywords.md`、`ALGO/RANSAC.md`。固定四节：**是什么 / 为什么 / 例子 / 坑**。避免写成教科书，重点讲清直觉和工程联系。
- **howto（实战记录类）**：如 `OS/home_network_segment_merge.md`、`Docker/access_remote_docker_with_vscode.md`。固定四节：**场景 / 步骤 / 结果 / 踩过的坑**。"踩过的坑"是这类笔记最有价值的部分，必须写。
- **config（个人偏好快照类）**：如 `Config/development-env-preference/`、`Vim/VIM.md` 中纯配置部分。不需要分节，记录"我用了什么、为什么这么选"即可。

> 已经存在的旧笔记不需要回头改格式，从下一篇新笔记开始执行即可。当前仓库已批量给现有笔记补了 `> 类型:` / `> 一句话:` 头部。
- `Git/.bashrc` 是 git 快捷 alias 清单（gs/gl/gps 等），供用户复制到自己的 `~/.bashrc`，不是本仓库的运行配置。
- `Makefile/exe_only/` 与 `Makefile/exe_and_libs/` 各含一个通用 Makefile 模板 + 一份说明文档（Description.md / Desc.md），模板里的变量注释（SRC_DIR/OBJ_DIR/BIN_DIR、%.o 规则）是给人阅读的，修改模板时保持这种逐行注释风格。
- `UML/*.puml` 为 PlantUML 图源码（Class/Sequence/State/Activity/Component/Deployment），配套一个 `uml.md` 说明概念。
- `MATH/` 下按学科分四个子目录（`linear_algebra/`、`multivariable_calculus/`、`optimization_theory/`、`probability_statistics/`），讲次文件统一命名为 `lectureNN_主题.md`，新增讲次请沿用此格式。

## 日常操作

- 提交直接在 `main` 分支进行（仓库无 PR 流程），提交信息使用中文，简洁说明添加/更新的笔记内容，例如「添加 AI课程笔记和全栈笔记」。
- 新笔记无命名冲突，直接按主题放目录即可。
- `README.md` 是笔记大纲索引（按主题分组、每行一条 `路径 — 中文说明`）；新增/重命名笔记或新建顶层目录时，同步更新 README 对应分组，避免索引与实际文件脱节。
