# OpenClaw生态与SKILL

前置条件：OpenClaw 需要先安装 Node.js（用 `node -v` / `npm -v` 检查），可源码安装或使用云服务器自带环境，具体安装步骤见《服务器部署OpenClaw》。

## SKILL 原理

1. 依据 metadata（name、description）选择合适的 SKILL；
2. 加载该 SKILL 的使用文档。

SKILL 不会全部传入 agent，而是从可选集合中被选中后才进入 agent。

## 获取 SKILL（clawhub）

clawhub 是 OpenClaw 的技能市场，对应网址 clawhub.ai。

```sh
# 安装 clawhub
npm install -g clawhub

# 搜索 "PPT" 相关的技能
clawhub search "PPT"

# 安装 "PPT" 相关的技能
clawhub install ppt-generator
# 默认安装路径 ~/.clawhub/skills/ppt-generator
# 安装到指定路径：clawhub install 技能名 --workdir 目标根路径 --dir 技能文件夹名

# 把本地安装的技能移动到 agent 的可选集合中
mv ~/.clawhub/skills/ppt-generator ~/.openclaw/skills/ppt-generator

# 查看 agent 的可选集合
openclaw skills list

# 下载新的 SKILL 后需要修改对应的 json 配置文件，一般还需重启 openclaw 服务
openclaw gateway --port 18789
```
