# 本地 LLM 测试夹具（ModelScope Qwen2.5-0.5B-Instruct GGUF）

> 用途：为后续 LLM 相关层（mizchi/llm provider 集成、skills-agent 循环、mizchi 互操作）提供**离线、可复现、零 API 成本**的本地模型测试夹具。本文件登记夹具路径与调用方式；当前 `aip/` 包（GB/Z 185.6 AIP sans-I/O）不依赖 LLM，此夹具自 W7/P2 集成期启用。

## 模型资产

| 项 | 值 |
| --- | --- |
| 路径 | `C:\Users\Administrator\.cache\modelscope\models\Qwen--Qwen2.5-0.5B-Instruct-GGUF\snapshots\master\qwen2.5-0.5b-instruct-q4_k_m.gguf` |
| 大小 | 491,400,032 字节（约 469 MB） |
| 量化 | Q4_K_M |
| 来源 | ModelScope `Qwen/Qwen2.5-0.5B-Instruct-GGUF` |

## 使用方式（集成期）

1. **llama.cpp server 模式**（推荐，OpenAI 兼容端点 → mizchi/llm 直接对接）：

```bash
llama-server -m "C:\Users\Administrator\.cache\modelscope\models\Qwen--Qwen2.5-0.5B-Instruct-GGUF\snapshots\master\qwen2.5-0.5b-instruct-q4_k_m.gguf" --port 8931
```

随后在集成测试中将 provider base_url 指向 `http://127.0.0.1:8931/v1`（模型名 `qwen2.5-0.5b-instruct-q4_k_m`）。

2. **进程内绑定**（远期，若走 wasm3/llama C 绑定路线）：纳入 W10 wasm3.mbt 绑定管线的可选验证项。

## 测试纪律

- 集成测试必须 **seed 化**（temperature=0 / 固定种子），保证 CI 可复现。
- 断言只校验**结构与协议行为**（消息往返、工具调用协议面），不校验生成文本内容（0.5B 模型输出不确定）。
- CI 无 GGUF 时跳过（tag: `requires-local-llm`）。
