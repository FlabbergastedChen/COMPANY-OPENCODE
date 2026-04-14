# Mock 503 模型接口

这是一个给 OpenCode / OpenAI-compatible 客户端使用的假模型接口，固定返回 HTTP `400`（响应体仍包含 503 文案用于模拟错误信息）。

## 启动

在仓库根目录执行：

```bash
npm run mock:503
```

默认监听：`http://127.0.0.1:12580`

## 可用路由

- `POST /v1/chat/completions`
- `POST /chat/completions`
- `POST /tbe/vmodel/v1/chat/completions`

这几个路由都会返回：

- 状态码：`400`
- 响应体：

```json
{"error":{"message":"Failed to forward request: POST \"http://127.0.0.1:12580/tbe/vmodel/v1/chat/completions\": 503 Service Unavailable {\"code\":\"service_unavailable\",\"message\":\"Service is temporarily unavailable. Please try again later.\",\"type\":\"invalid_request_error\"}","type":"api_error"}}
```

## OpenCode 配置示例

在 `opencode.jsonc` 里可以配置一个 OpenAI-compatible provider（示意）：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "mock503": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Mock503",
      "options": {
        "name": "Mock503",
        "baseURL": "http://127.0.0.1:12580/v1",
        "apiKey": "dummy"
      },
      "models": {
        "mock503-chat": {}
      }
    }
  },
  "model": "mock503-chat"
}
```

如果你当前 OpenCode 配置字段有差异，只要保证请求最终打到上面的任一路由即可。
