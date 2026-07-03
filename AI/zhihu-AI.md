


## Openclaw

1.需要安装node.js (node -v / npm -v) 
2.源码安装或者云服务器安装

```text
安全警告 — 请阅读。                                                            
                                                                                              
   OpenClaw是一个业余项目，目前仍处于测试阶段。请期待其锋芒毕露。                         
   默认情况下，OpenClaw是一个个人代理：一个受信任的操作员边界。                   
   此机器人可以读取文件，并在启用工具时执行操作。                              
  一个错误的提示可能会诱使它做出不安全的行为。                                        
                                                                                              
   OpenClaw默认情况下并非具有敌意的多租户边界。                                
  如果多个用户可以向一个启用了工具的代理发送消息，那么他们共享该委托工具  
  权威。                                                                                 
                                                                                              
   如果你对安全加固和访问控制不熟悉，就不要运行            
   OpenClaw。                                                                                  
在启用工具或将其暴露给互联网之前，请向有经验的人寻求帮助。      
                                                                                              
   推荐基线：                                                                      
   -配对/白名单 + 提及门控。                                                     
   - 多用户/共享收件箱：分离信任边界（理想情况下，应分离网关/凭证） 
     独立的操作系统用户/主机）。                                                                
   - 沙盒+最小权限工具。                                                         
   - 共享收件箱：隔离DM会话（`session.dmScope: per-channel-peer`）并保留       
     工具访问权限最小。                                                                     
   - 确保机密文件不在代理可访问的文件系统中。                                    
   - 对于任何使用工具或收件箱不受信任的机器人，请使用最强大的可用模型。           
                                                                                              
  定期跑步：                                                                             
   openclaw 安全审计 --深度                                                             
   openclaw 安全审计 --修复                                                              
                                                                                              
  必读：https://docs.openclaw.ai/gateway/security
```

### SKILL


#### 原理
 step1,选择合适的SKILL，通过metadata(name,description)
 step2,加载skill的使用文档
 本身不会全部都传入到agent，从可选集合中选中才进入agent


#### 获取SKILL
安装clawhub
```sh
  # 对应的网址 clawhub.ai
  npm install -g clawhub
  # 搜索 "PPT" 相关的
  clawhub search "PPT"
  # 安装 "PPT" 相关的  
  clawhub install ppt-generator
  # 默认安装路径 ~/.clawhub/skills/ppt-generator
  # 安装到指定路径  clawhub install 技能名 --workdir 目标根路径 --dir 技能文件夹名

  # 从本地安装技能移动到agent的可选集合中
  mv ~/.clawhub/skills/ppt-generator ~/.openclaw/skills/ppt-generator

  # 查看agent的可选集合
  openclaw skills list 

  # 下载新的SKILL后,修改json文件;另外， 一般需要重启openclaw服务
  openclaw gateway --port 18789


```






## Coze
低代码平台


# Q&A
## 1.如何进行一个应用构建？
### 1.1 需求描述：
  - 分析用户问题和场景


### 1.2 技术选型
  - 高代码（Langchain,LangGraph,Qwen-Agent,LlamaIndex）
  - 低代码(Coze,Dify)
  - Agent 还是工作流？
    * Agent 是一个基于SKILL的智能体，可以执行复杂的任务。
    * 工作流 是一个基于SKILL的流程，可以执行简单的任务。
  - 是否包含Tool？
  - 是否有RAG（知识库）

### 1.3 实现细节：
  - 高代码实现:AI 编程（Cursor Trae）
  - 低代码实现：Coze,Dify

### 1.4 整理一些测试问题：
  - 测试Agent是否能够执行复杂的任务
  - 测试工作流是否能够执行简单的任务
  - 测试Tool是否能够正常工作
  - 测试RAG是否能够正常工作


## 2.常见商用模型

- 国外
  - Claude Opus 4.6
  - GPT 5.4

- 国内
  - GLM
  - Kimi 2.5
  - MiniMax
  - Qwen3-Coder-Plus

- Coding Plan
 - GLM
 - KIMI
 - MiniMax

## 3.行业

- 金融
- 医疗
- 教育
- 法律
- 企业

##  4.Claw-code
python 实现
开源 claude code开源
