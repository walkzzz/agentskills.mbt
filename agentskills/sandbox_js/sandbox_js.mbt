///|
///F09 执行器① —— js WebAssembly 沙箱（js 目标专属，`supported_targets = "js"`）。
///
///En: F09 executor #1 — js WebAssembly sandbox (js target only).
///诚实边界：js 执行器**不做逐指令燃料计量**（WebAssembly 无 gas 钩子）——
///`gas <= 0` 判 OutOfGas，`gas > 0` 视为「允许执行一次」；精确计量由 wasm3/wasmoon
///执行器承担（W10 排期）。真实实现对齐 `verify/proof` 的 gas 契约核（model-based oracle）。
pub struct WasmJsSandbox {
  marker : Unit
}

///|
pub fn WasmJsSandbox::new() -> WasmJsSandbox {
  { marker: (), }
}

///|
impl @sandbox.Sandbox for WasmJsSandbox with fn execute(
  _self,
  bytes,
  entry,
  args,
  gas,
) -> @sandbox.SandboxResult {
  if gas <= 0L {
    return @sandbox.OutOfGas
  }
  let handle = wasm_compile(bytes)
  if handle < 0 {
    return @sandbox.Failed("invalid module bytes")
  }
  let out = wasm_call(handle, entry, args.stringify())
  if out.has_prefix("ERR:") {
    return @sandbox.Failed(out)
  }
  let payload = @json.parse(out) catch { _ => Json::string(out) }
  @sandbox.Succeeded(payload)
}

///|
pub extend WasmJsSandbox with @sandbox.Sandbox::{execute}
