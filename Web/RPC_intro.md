# RPC 与底层网络通信

> 类型：concept
> 一句话：RPC 是什么、gRPC 为什么选 HTTP/2、HTTP/3 为什么弃 TCP

## 是什么

RPC（Remote Procedure Call，远程过程调用）是一种交互模型：让程序跨网络调用远程服务器的代码时，语法体验上**就像调用本地函数一样**，屏蔽网络连接、协议打包、数据解析的细节。

**存根（Stub）模型**：

- `Client Stub`（客户端存根）：伪装成本地函数，把函数名和入参序列化成网络报文发出。
- `Server Stub`（服务端存根）：接收报文、反序列化，调用真实的本地函数，再把结果原路返回。

**关键认知：RPC ≠ HTTP**。RPC 只是架构思想，不绑定传输层。它可以跑在裸 TCP、本地 IPC、WebSocket、UDP 上。当今最流行的 gRPC 默认选 HTTP/2 作底层，这容易让人误以为 RPC 就是 HTTP。

### RPC 的传输载体

| 载体 | 特点 | 典型场景 |
| --- | --- | --- |
| HTTP/1.1 / HTTP/2 / HTTP/3 | 兼容性最强，穿透网关防火墙首选 | gRPC、RESTful API |
| 裸 TCP | 省略 HTTP 头，自定义二进制包体，追求极限吞吐 | Dubbo、MMO 游戏服务器 |
| 本地 IPC（Unix Domain Socket / stdio 管道） | 同机部署时绕过 TCP/IP 协议栈和网卡，微秒级延迟 | LSP、MCP、gRPC 本地模式 |
| WebSocket | 全双工、有状态持久长连接 | 事件推送（飞书机器人）、区块链订阅 |
| UDP / QUIC | 无连接、低延迟，自行实现重传 | 竞技游戏、音视频信令 |

### 现代 RPC 框架生态

- **gRPC**（Google）：工业级标准，强类型契约 + Protobuf 二进制 + HTTP/2 多路复用。
- **tRPC**：全栈 TypeScript 生态，用 TS 泛型自动生成类型，底层跑 HTTP/JSON，无需写 `.proto`。
- **Apache Dubbo**（阿里 Java 系）：裸 TCP 高并发。
- **Kitex**（字节 Go）：配合 Thrift。
- **tRPC / bRPC**（腾讯/百度 C++）：海量并发低延迟。
- **JSON-RPC 2.0**：极简 JSON 文本约定，字段为 `jsonrpc` / `method` / `params` / `id`。

## 为什么

### 为什么 gRPC 选 HTTP/2 而不是裸 TCP

裸 TCP 更快，但 Google 设计 gRPC 时坚定选择 HTTP/2，核心是**基础设施兼容性**：

1. **穿透防火墙与网关**：企业内网防火墙、云负载均衡（ALB/NLB）、反向代理（Nginx、Envoy）默认放行 HTTP；私有 TCP 协议往往需要额外配置网关转发。
2. **复用现成生态**：TLS 证书、链路追踪、鉴权 Header、多路复用机制全部现成，不用在基础设施层重复造轮子。

### 为什么 HTTP/3 抛弃 TCP 转向 UDP

TCP 面向连接、绝对可靠，但高并发弱网下有三大缺陷：

- **队头阻塞（Head-of-Line Blocking）**：HTTP/2 虽然在一条 TCP 连接上并发多请求，但底层 TCP 是单条有序字节流。丢 1 个包，后面所有已到达的包都要死等重传，整个连接卡死。
- **握手延迟高**：HTTPS 要先 TCP 三次握手、再 TLS 握手，好几个 RTT 才能发业务数据。
- **连接迁移难**：手机 Wi-Fi 切 5G 时 IP 变了，TCP 连接必须断开重连。

HTTP/3 在 UDP 之上用 **QUIC** 在用户态重新实现加密（TLS 1.3）、丢包重传、拥塞控制：多条流独立（A 流丢包不影响 B 流）、0-RTT 建连、用 Connection ID 代替 IP 实现无缝迁移。

### JSON-RPC 为什么在轻量场景不可替代

gRPC 在大型微服务中占主导，但 JSON-RPC 2.0 在三个领域是行业标准：

1. **AI 工具链与 IDE**：MCP（大模型连接本地环境）、LSP（VS Code 通过 stdio 管道与语言分析进程通信）。
2. **区块链 / Web3**：以太坊、Solana 的节点 API（如 `eth_getBalance`）。
3. **本地跨语言脚本**：Node 拉起 Python 子进程，通过 stdin/stdout 逐行互发 JSON-RPC，零环境依赖。

## 例子

### gRPC vs RESTful 选型

| 维度 | gRPC | RESTful (HTTP/JSON) |
| --- | --- | --- |
| 传输层 | 强制 HTTP/2 | 通常 HTTP/1.1 |
| 载体 | Protobuf 二进制（强契约 `.proto`） | JSON 纯文本（无静态约束） |
| 体积/开销 | 极小，JSON 的 1/3 ~ 1/10 | 较大，高并发下解析 JSON 耗 CPU |
| 通信模式 | 一元 / 服务端流 / 客户端流 / 双向流 | 请求-响应 |
| 最佳场景 | 内部微服务、高频实时流、IoT 上行 | 对外开放平台、前端 Web 请求、抓包调试 |

### TCP vs UDP

| 维度 | TCP | UDP |
| --- | --- | --- |
| 连接 | 面向连接，三次握手 / 四次挥手 | 无连接，知道 IP+端口直接发 |
| 可靠性 | ACK、超时重传、按序到达，不丢不重 | 尽力而为，可能丢包乱序 |
| 开销 | 首部 ≥20 字节，有流量/拥塞控制 | 首部 8 字节，无握手无重传 |
| 场景 | 网页、文件下载、数据库同步 | 视频通话、游戏、直播、DNS |

### HTTP 版本协商

网站不写死版本，接入层（Nginx/Envoy/CDN）开多版本支持，浏览器自动谈判：

1. **ALPN 协商**：首次 TCP+TLS 握手时协商，默认先建 HTTP/2。
2. **Alt-Svc 广告**：服务器在 HTTP/2 响应头夹带 `Alt-Svc: h3=":443"; ma=86400`，告诉浏览器"下次可以走 UDP 443 的 HTTP/3"。
3. **自动降级**：浏览器后台尝试 QUIC，若 UDP 被防火墙屏蔽则瞬间回退 HTTP/2，用户无感知。

YouTube 几乎全量 HTTP/3（QUIC 本就是 Google 为 YouTube 发明的）；B 站重点在视频 CDN 和移动端用 HTTP/3，Web API 仍走 HTTP/2（国内运营商对大流量 UDP 有 QoS 限速）。

浏览器验证：F12 → Network 面板 → 表头右键勾选 Protocol 列，看 `h3` / `h2` / `http/1.1`。

## 坑

- **RPC ≠ HTTP**：这是最常见的误解。RPC 是架构思想，HTTP 只是它的一种载体。把 RPC 等同于 HTTP 会忽略 Dubbo/Thrift 的裸 TCP 模式和 LSP/MCP 的 stdio IPC。
- **HTTP/2 的多路复用没解决队头阻塞**：HTTP/2 在应用层并发了，但底层 TCP 丢一个包所有流都卡死。真正解决要等 HTTP/3/QUIC。
- **QUIC 被防火墙挡**：很多企业/校园网限速或屏蔽 UDP 443，HTTP/3 会自动降级回 HTTP/2，不要假设所有用户都走 h3。
- **Protobuf 契约是强约束**：`.proto` 改了字段没同步生成代码，跨语言调用直接崩。CI 里要跑契约检查。
- **JSON-RPC 没有内置传输层安全**：它只是报文格式，安全靠底层（HTTPS / SSH 隧道 / 本地管道）。把 JSON-RPC 直接暴露在公网 HTTP 上等于裸奔。
- **本地 IPC 不是万能**：Unix Domain Socket 和 stdio 管道只在同机部署时可用，跨机必须走 TCP/HTTP。
