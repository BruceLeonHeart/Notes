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

参考来源：[Karpathy 原 gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)、[中文解读（腾讯云）](https://cloud.tencent.com/developer/article/2653360)、[社区实践总结](https://gist.github.com/Joi/120f86eb39758ef75deb5e6145e5a717)
