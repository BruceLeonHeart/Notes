# Karpathy 的 LLM Wiki 是什么

> 类型：concept
> 一句话：Karpathy LLM Wiki 构想


这是 Andrej Karpathy 在 2026 年 4 月发布的一个 [gist 构想](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)（5000+ star），核心是一句话：**知识"编译一次、持续维护"，而不是每次提问都从原始资料里临时检索（RAG）**。

**它解决的痛点**：传统 RAG（上传文件 → 每次提问重新检索片段 → 临时拼答案）没有积累——交叉引用不会自己长出来，上次问过的结论不会沉淀，文档间的矛盾没人标记。

**核心比喻**：Obsidian 是 IDE，LLM 是程序员，wiki 是代码库。人负责找资料、提好问题；LLM 负责所有枯燥的记账工作——总结、交叉引用、归档、保持一致性。

## 三层架构

| 层 | 内容 | 谁来写 |
|---|---|---|
| **raw sources/** | 原始资料（文章、论文、截图、聊天记录），**不可变**，是事实来源 | 你投喂 |
| **wiki/** | LLM 生成并维护的 markdown 页面：概念页、实体页、对比页、综述 | LLM 全权维护 |
| **schema**（`AGENTS.md`/`CLAUDE.md`） | 告诉 LLM 这套 wiki 的结构约定和工作流 | 你和 LLM 共同演进 |

## 三个操作

1. **Ingest（摄入）**：丢入一份新资料 → LLM 阅读、和你讨论重点、写摘要页、**更新 10~15 个相关页面**、更新 index、追加 log。
2. **Query（提问）**：先查 wiki 而非原始资料；好的回答（对比、综合分析）**回写为新页面**，让探索本身也复利。
3. **Lint（体检）**：定期检查页面矛盾、过时结论、孤立页、缺失的交叉引用、该建但没建的概念页。

另外两个关键文件：[index.md 内容导向目录 + log.md 时间线日志](https://cloud.tencent.com/developer/article/2653360)。Karpathy 实测在 ~100 个来源、几百个页面的规模下，光靠 index 文件导航就够用，不需要上向量检索。

---

# 你当前文件夹的现状诊断

我扫了一遍你的 Notes（约 30 篇 md），和 LLM Wiki 模式对照：

**已有的好底子**
- 按主题分文件夹（AI / CXX / Docker / ROS / OS / ALGO…），天然就是 wiki 的分类骨架
- 笔记内容质量高，是"编译过"的知识而非原始摘抄（如 [关键字static和const.md](file:///c:/Users/Administrator/Desktop/Notes/CXX/%E5%85%B3%E9%94%AE%E5%AD%97static%E5%92%8Cconst.md) 有体系、有代码示例），相当于已有一批高质量的 **seed wiki**
- 有 LICENSE、README，附带可执行资产（Makefile 模板、.bashrc、PlantUML 图）

**与 LLM Wiki 的差距**
1. **零内部链接**：136 处链接几乎全是外链，笔记之间互不相认——图视图会是一堆散点
2. **疑似重复/冗余**：[RANSAC.md](file:///c:/Users/Administrator/Desktop/Notes/ALGO/RANSAC.md) 与 [ransac随机一致性检测.md](file:///c:/Users/Administrator/Desktop/Notes/ALGO/ransac%E9%9A%8F%E6%9C%BA%E4%B8%80%E8%87%B4%E6%80%A7%E6%A3%80%E6%B5%8B.md) 并存；`Desc.md` / `Description.md` 命名不统一
3. **无元数据**：没有 frontmatter（标签、类型、日期），无法 Dataview 查询
4. **无 index.md / log.md / schema 文件**，README 只有两行
5. **强相关的页面没有横向联系**：ROS vs ROS2 两篇、static/const ↔ 列表初始化、RANSAC ↔ PCA ↔ 随机采样、内存零拷贝 ↔ CUDA
6. **资料层和产物层混在一起**：如 [openclaw/resource/](file:///c:/Users/Administrator/Desktop/Notes/AI/openclaw/resource) 里的截图就是 raw source，但和笔记同目录摆放

**一个重要判断**：你的库以「操作手册 + 概念笔记」为主（Git/Docker/Vim cheatsheet），不是研究型资料汇编。所以**不必照搬三层架构**——操作类笔记不需要 raw source，直接让 LLM 维护即可；取模式中适合你的部分。

---

# 改造建议（按投入从小到大）

**阶段一：零搬迁，先装"导航和规则"（推荐先做）**
1. 根目录新增 `AGENTS.md`：约定命名规范、frontmatter 字段（`tags / type / created / updated / related`）、语言、代码示例规范、ingest/query/lint 工作流——让我每次打开这个库就知道怎么当"wiki 维护员"
2. 新增 `index.md`（全库目录，每页一行摘要+分类）和 `log.md`（时间线，统一前缀如 `## [2026-09-19] ingest | xxx`）
3. 去重合并：两篇 RANSAC 合一，统一命名风格
4. 批量补 frontmatter + 双向交叉链接（这一步可以直接交给我跑第一轮）

**阶段二：建立两种新页面类型**
- 每个文件夹一个 **MOC 总览页**（Map of Content），如 `CXX/index.md` 串起 static/const、引用本质、列表初始化、文件IO
- **对比/综合页**：如「ROS1 vs ROS2 迁移要点」「Docker 开发环境 vs 本地环境」——这类正是 Query 回写的产物

**阶段三：引入 raw 层（适合继续深耕的方向）**
- 新建 `raw/`（如 `raw/AI/openclaw/` 放截图和剪藏原文），现有 openclaw 截图移过去；以后用 Obsidian Web Clipper 剪藏文章 → 让我 ingest 成 wiki 页
- Makefile 模板、.bashrc、.puml 这类可执行资产归入 `assets/`，wiki 页只引用不复制

**阶段四：长期运转**
- 每月让我跑一次 lint（孤立页、过时 API、断链）
- git 提交即天然版本历史；页面规模到几百篇时再考虑 [qmd](https://github.com/tobi/qmd) 本地混合检索
- 推荐用 Obsidian 打开这个文件夹，配合 graph view 和 Dataview 插件

---

我可以立刻帮你做**阶段一**：起草 `AGENTS.md`、`index.md`、`log.md`，合并 RANSAC 重复笔记，并给全部现有笔记补 frontmatter 和交叉链接（改动前会先给你看方案）。要从哪一步开始，还是你想先调整某些建议？

参考来源：[Karpathy 原 gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)、[中文解读（腾讯云）](https://cloud.tencent.com/developer/article/2653360)、[社区实践总结](https://gist.github.com/Joi/120f86eb39758ef75deb5e6145e5a717)
