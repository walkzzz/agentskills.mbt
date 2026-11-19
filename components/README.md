# WebAssembly Component（推广展示面）

本目录把 agentskills.mbt 的核心能力以 **WebAssembly Component Model**（[component-model.bytecodealliance.org](https://component-model.bytecodealliance.org/)）标准接口导出——MoonBit 是一流支持 WebAssembly 的语言，运行时以 WIT 组件形式被任意宿主（JS/Python/Rust/wasmtime）调用。

## 接口（WIT）

见 [wit/world.wit](wit/world.wit)：`walkzzz:agentskills@0.1.0` / `skill-api` 接口导出 5 个函数：

| 函数 | 语义 | 对应实现 |
| --- | --- | --- |
| `parse-name` | SKILL.md frontmatter → name | `@agentskills.skill.parse_skill_md` |
| `parse-description` | → description | 同上 |
| `validate` | `""` 合法 / 错误信息 | 同上 + `validate` |
| `can-access` | RBAC 授权判定 | 与 `verify/proof.allowed` 契约核一致 |
| `rrf-score` | `1/(k+rank)` | 与 `rag.rrf_fuse` 评分语义一致 |

## 构建（一条龙脚本）

前置工具（rust 生态）：

```bash
cargo install wit-bindgen-cli   # WIT → MoonBit 绑定生成
# wasm-tools：预编译 zip 或 cargo install wasm-tools
```

构建：

```bash
bash scripts/component_build.sh
# → components/agentskills.component.wasm
# → wasm-tools component wit 输出（接口验证）
```

流水线（脚本内自动完成）：

1. `wit-bindgen moonbit wit/world.wit --out-dir components --derive-eq --derive-show --derive-error`
2. 生成模块的 `moon.mod` 注入 `walkzzz/agentskills.mbt@0.1.0` 依赖，stub 由脚本写入真实实现（薄包装，调用已发布的运行时）
3. `moon build --target wasm`（`gen/moon.pkg` 的 wasm `link.exports` 由 wit-bindgen 生成）
4. `wasm-tools component embed wit ... --encoding utf16` → `wasm-tools component new` → 组件
5. `wasm-tools component wit agentskills.component.wasm`——**接口自证**（输出 package/world/interface）

## CI 验证

`ci.yml` 的 `components` job（ubuntu）安装工具链、执行上述脚本并上传 `agentskills.component.wasm` artifact——组件可被复审者直接下载用 wasmtime/示例宿主调用，如：

```bash
wasmtime run --invoke 'can-access(2, 2)' agentskills.component.wasm   # true（Admin 可达机密）
wasmtime run --invoke 'rrf-score(0, 60)' agentskills.component.wasm   # 0.016666...
```

## 说明

- 组件模型是目前 MoonBit → WebAssembly 的**标准跨语言集成方式**（替代各宿主私有 FFI 封装）。
- 本目录的生成物（`gen/` `ffi/` `world/`）不入库（`.gitignore`），由脚本按 WIT 重建——**WIT 是唯一真相源**。