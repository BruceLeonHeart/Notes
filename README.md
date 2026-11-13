# Notes

Reducing repeated stuff and make life easier 😍

## 笔记大纲

按顶层目录分组，文件名即主题，便于快速定位。

### AI / Agent / DL
- `AI/agent_introduction.md` — Agent 智能体概念
- `AI/ai_tools_and_models.md` — AI 工具与模型清单
- `AI/ai_trends.md` — 国内 AI 七条主线格局与 AI 辅助开发工作流
- `AI/stable_diffusion.md` — Stable Diffusion 笔记
- `AI/openclaw/deploy_openclaw_on_server.md` — OpenClaw 服务器部署
- `AI/openclaw/openclaw_ecosystem_and_skills.md` — OpenClaw 生态与 Skills
- `AI/openclaw/openclaw_how_it_works.md` — OpenClaw 运行机制（Gateway + channel）
- `AI/openclaw/openclaw_security_statement_explained.md` — OpenClaw 安全声明解读
- `Agent/Skills.md` — Agent Skills
- `DL/nv12_image_processing.md` — NV12 格式输入图像处理
- `Karpathy_LLM_WIKI.md` — Karpathy LLM 学习 Wiki

### ALGO
- `ALGO/PCA.md` — PCA 算法
- `ALGO/RANSAC.md` — RANSAC 算法

### CUDA / CXX / Embeded_dev
- `CUDA/CUDA.md` — CUDA 基础
- `CXX/static_and_const_keywords.md` — static / const 关键字
- `CXX/list_initialization.md` — 列表初始化
- `CXX/references_explained.md` — 引用的本质
- `CXX/file_io.md` — C++ 文件 IO
- `CXX/random_sampling.md` — 随机采样
- `Embeded_dev/debugging_with_valgrind_and_asan.md` — valgrind / ASan 调试

### Config / Vim
- `Config/development-env-preference/git_bash_aliases.md` — Git bash alias 清单
- `Config/development-env-preference/color_scheme_preferences.md` — 配色喜好
- `Vim/VIM.md` — Vim 配置

### Dataset / Doxygen / Makefile
- `Dataset/kitti_dataset.md` — KITTI 数据集
- `Doxygen/doxygen_comment_style.md` — Doxygen 注释规范
- `Makefile/` — 通用 Makefile 模板（exe_only / exe_and_libs）

### Docker / ROS / Web
- `Docker/docker_common_operations.md` — Docker 常见操作
- `Docker/docker_as_development_environment.md` — Docker 作为开发环境
- `Docker/access_remote_docker_with_vscode.md` — VSCode 远程连 Docker
- `ROS/ros_common_operations.md` — ROS 常用操作
- `ROS/ros2_common_operations.md` — ROS2 常用操作
- `Calibration/extrinsic_zero_reference.md` — 相机外参标定零位参考（OpenCV ↔ ISO 8855）
- `Web/fullstack_introduction.md` — 全栈技术介绍
- `Web/bff_backend_for_frontend.md` — BFF：多语言后端协同与通信规范
- `Web/Django_intro.md` — Django 入门：ORM、Admin、Auth 三大内置特性
- `Web/hybrid_desktop_app_frameworks_intro.md` — Tauri vs Electron 跨平台桌面框架对比
- `Web/RPC_intro.md` — RPC 与底层网络通信（gRPC / JSON-RPC / HTTP/3）

### Git / OS / SVN
- `Git/git_common_operations.md` — Git 常见操作
- `Git/github_cli_and_token_autosave.md` — GitHub CLI 与 Token 免密配置
- `OS/smb_protocol_introduction.md` — Smb 协议介绍
- `OS/windows_file_sharing_setup.md` — Windows 共享实战
- `OS/home_network_segment_merge.md` — 光猫 / 路由器合并网段
- `OS/zero_copy.md` — 内存 0 拷贝技术
- `SVN/SVN.md` — SVN 常用操作

### MATH
- `MATH/study_plan.md` — 数学学习计划（含全部阶段复盘摘要）
- `MATH/linear_algebra/` — 线性代数讲次（向量、矩阵、SVD、PCA）
- `MATH/multivariable_calculus/` — 高等数学讲次（偏导、梯度、Jacobian、Hessian、链式法则）
- `MATH/optimization_theory/` — 优化理论讲次（最小二乘、梯度下降、牛顿法、LM、鲁棒核）
- `MATH/probability_statistics/` — 概率统计讲次（分布、贝叶斯、高斯、条件概率）

### Python
- `Python/uv_notes.md` — uv（Rust 写的 Python 包/项目管理工具）使用笔记

### UML / DailyLife
- `UML/uml.md` — UML 概念说明
- `UML/*.puml` — Class / Sequence / State / Activity / Component / Deployment 图源码
- `UML/activity_diagram_vs_sequence_diagram.md` — 活动图 vs 序列图
- `DailyLife/social_security.md` — 社保笔记

## 按问题反查

> 按"我遇到什么问题"索引，不是按目录。只收真的会回头查的问题，不用穷举。

- 忘了某个 git / docker / ros 命令怎么写 → 对应目录下 `*_common_operations.md`
- C++ `static` / `const` 各种用法分不清 → `CXX/static_and_const_keywords.md`
- C++ 引用到底是什么、和指针区别 → `CXX/references_explained.md`
- 想做内存零拷贝优化 → `OS/zero_copy.md`
- 光猫 / 路由器网段合并不通 → `OS/home_network_segment_merge.md`
- Windows 共享 / Smb 配置 → `OS/smb_protocol_introduction.md`、`OS/windows_file_sharing_setup.md`
- 远程服务器上用 VSCode 连 Docker 开发 → `Docker/access_remote_docker_with_vscode.md`
- 用 valgrind / ASan 查内存问题 → `Embeded_dev/debugging_with_valgrind_and_asan.md`
- Python 包管理 / 虚拟环境 / 换源 → `Python/uv_notes.md`
- MATH 系列讲次学了什么、学到哪了 → `MATH/study_plan.md`（含全部阶段复盘摘要）
- 服务器上部署 OpenClaw → `AI/openclaw/deploy_openclaw_on_server.md`
- 服务器无浏览器免密推 GitHub → `Git/github_cli_and_token_autosave.md`
- gRPC vs REST 怎么选、HTTP/3 为什么用 UDP → `Web/RPC_intro.md`
- 相机外参标定输出的欧拉角为什么不是 0 而是 ±90° → `Calibration/extrinsic_zero_reference.md`
