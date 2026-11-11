# BFF：多语言后端协同与通信规范

> 类型：concept
> 一句话：前端与多语言后端之间的适配层规范

## 是什么

BFF（Backend For Frontend，服务于前端的后端）是介于前端（Web / App）与后端微服务之间的**适配层**。它本身不承载核心业务逻辑，只做三件事：

1. **聚合**：把前端一次页面渲染需要的多个后端服务结果（如用户信息 + 订单列表 + 推荐位）合并成一个响应返回，避免前端 N+1 次请求。
2. **裁剪**：按当前端的需要从后端数据里挑字段、改格式（时间戳转字符串、蛇形转驼峰、删除前端用不到的大字段）。
3. **协议翻译**：前端统一用 HTTP/JSON 调用 BFF，BFF 内部再按后端语言生态选用合适的协议（Java 用 gRPC、Python 用 HTTP、Go 用 thrift、服务间用消息队列）。

典型拓扑：

```
┌─────────┐   HTTP/JSON    ┌──────┐   gRPC    ┌────────────┐
│  Web/App │ ────────────> │ BFF  │ ────────> │ Java/Spring │
└─────────┘                │(Node)│           └────────────┘
                           │      │   HTTP    ┌────────────┐
                           │      │ ────────> │ Python/Django│
                           │      │           └────────────┘
                           │      │   thrift  ┌────────────┐
                           │      │ ────────> │ Go/Gin      │
                           └──────┘           └────────────┘
```

BFF 通常用与前端同构的语言写（Node.js / Nest.js），前端工程师能独立维护；多语言后端则各自按领域沉淀（Java 做交易、Python 做算法、Go 做网关）。

## 为什么

- **前端不该感知后端语言栈**：前端只认 HTTP/JSON，不应因为后端从 Java 换成 Go 就改接口调用。BFF 把这种变化限制在自己内部。
- **多语言协作的现实**：算法团队用 Python 迭代快、交易团队用 Java 稳、高并发用 Go。与其强行统一语言栈，不如用 BFF 统一对外契约。
- **性能**：BFF 就近做聚合，省掉前端串行等待；可在 BFF 层加缓存（Redis）、熔断、鉴权，后端服务保持纯粹。
- **演进解耦**：后端拆分 / 合并 / 换实现时，只要 BFF 适配层跟着改，前端零改动。

## 例子

以一个电商订单页为例，前端需要「订单列表 + 每条订单的商家名称 + 物流状态」。

**没有 BFF 时**前端要发 3 个请求、再自己 join：

```
GET /api/orders            -> Java 订单服务
GET /api/merchants/{id}    -> 循环 N 次查商家（N+1 问题）
GET /api/logistics/{oid}   -> Python 物流服务
```

**有 BFF 时**前端只发 1 个请求，BFF 内部并行调用后端并聚合：

```ts
// BFF（Node/Nest），伪代码
@Get('/order-page')
async getOrderPage(@Query('uid') uid: string) {
  const [orders, merchIds] = await Promise.all([
    this.orderSvc.listOrders(uid),          // gRPC -> Java
    this.logisticsSvc.batchStatus(uid),     // HTTP -> Python
  ]);
  const merchants = await this.merchantSvc.batchGet(
    [...new Set(orders.map(o => o.merchant_id))]
  );
  // 裁剪字段 + 格式统一后返回
  return orders.map(o => ({
    orderId: o.id,
    amount: o.paid_amount / 100,            // 分 -> 元
    createdAt: dayjs(o.created_at * 1000).format('YYYY-MM-DD HH:mm'),
    merchantName: merchants.get(o.merchant_id)?.name ?? '未知商家',
    logistics: logisticsMap.get(o.id)?.state ?? '待发货',
  }));
}
```

约定要点：

| 项 | 规范 |
| --- | --- |
| 对外协议 | 统一 HTTPS + JSON，snake_case 还是 camelCase 选一种并写进网关文档 |
| 错误格式 | `{ code: number, message: string, data: null }`，HTTP 状态码与业务 code 分离 |
| 内部协议 | 后端之间优先 gRPC（IDL 生成强类型），无 IDL 时退化为 HTTP + JSON Schema |
| 鉴权 | BFF 统一验 JWT，再把用户身份透传给后端（gRPC metadata / HTTP header） |

## 坑

- **BFF 变胖**：把业务逻辑写进 BFF 会让它变成"第二个后端"，和真正后端重复甚至产生不一致。BFF 里只允许做聚合 / 裁剪 / 转发，不写领域规则。
- **循环依赖**：BFF 调后端 A，A 又回调 BFF 取数据——架构里禁止出现，后端需要的数据应走服务间直连或消息队列。
- **契约漂移**：后端改了字段名 / 类型，BFF 没跟着改，线上才炸。解决：后端用 IDL（proto / OpenAPI）、CI 里跑契约测试（Pact / 本地 diff），BFF 类型从 IDL 自动生成，不靠人手抄。
- **N+1 残留**：BFF 里对每个订单单独发一次请求查商家——等于把 N+1 从前端搬到 BFF。后端要提供批量接口（`batchGet(ids)`），BFF 一次取完。
- **鉴权断层**：BFF 验完 JWT 就把用户身份丢了，后端以为是匿名内部调用。统一用 `X-User-Id` header 透传，网关层校验签名防伪造。
- **多端 BFF 拆分**：Web 和 App 的数据形状差异很大（App 要分页游标、Web 要整页聚合）。不要一个 BFF 服务两端，按端拆成 `bff-web` / `bff-app`，避免接口为了兼容两端越做越脏。
