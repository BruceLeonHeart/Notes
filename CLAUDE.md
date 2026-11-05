# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库性质

这是一个个人技术笔记/知识库仓库，**不是代码项目**：没有构建、测试、lint 流程，唯一的操作就是 git。仓库内容全部由中文 Markdown 笔记和少量模板文件组成。

## 目录约定

顶层目录按技术主题划分（AI、ALGO、CUDA、CXX、Dataset、Docker、Doxygen、Git、Makefile、Matlab、OS、ROS、SVN、UML、Vim、Web）。

- 笔记文件统一为中文名的 `.md`，放入对应主题目录；主题没有合适目录时才新建顶层目录。
- 笔记风格：中文叙述 + 英文原文命令/代码，代码一律放在围栏代码块中，按「基础配置 / 仓库操作」这类二级标题分节。
- `Git/.bashrc` 是 git 快捷 alias 清单（gs/gl/gps 等），供用户复制到自己的 `~/.bashrc`，不是本仓库的运行配置。
- `Makefile/exe_only/` 与 `Makefile/exe_and_libs/` 各含一个通用 Makefile 模板 + 一份说明文档（Description.md / Desc.md），模板里的变量注释（SRC_DIR/OBJ_DIR/BIN_DIR、%.o 规则）是给人阅读的，修改模板时保持这种逐行注释风格。
- `UML/*.puml` 为 PlantUML 图源码（Class/Sequence/State/Activity/Component/Deployment），配套一个 `uml.md` 说明概念。

## 日常操作

- 提交直接在 `main` 分支进行（仓库无 PR 流程），提交信息使用中文，简洁说明添加/更新的笔记内容，例如「添加 AI课程笔记和全栈笔记」。
- 新笔记无命名冲突，直接按主题放目录即可；不要为笔记生成索引或目录文件（README.md 只维护两条简要说明，不要随意扩充）。
