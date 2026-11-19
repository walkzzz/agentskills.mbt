///|
///F09 沙箱契约（ARCH §3.1/§7：wasmoon / @process 进程隔离 / js WebAssembly 三实现面）。
///
///En: F09 sandbox contract — executable skill boundary with gas metering.
///本包先落 Kernel 式 API 面与燃料模型；wasmoon 运行时注入随 W10 集成。

///|
///GasMeter — 燃料计量（纯逻辑：限额 / 消耗 / 耗尽判定）。
pub struct GasMeter {
  limit : Int64
  mut used : Int64
}

///|
pub fn GasMeter::new(limit : Int64) -> GasMeter {
  { limit, used: 0L, }
}

///|
///consume — 消耗燃料；超出限额或负额返回 false（used 不变）。
pub fn GasMeter::consume(self : Self, amount : Int64) -> Bool {
  if amount < 0L {
    return false
  }
  if self.used + amount > self.limit {
    return false
  }
  self.used = self.used + amount
  true
}

///|
pub fn GasMeter::exhausted(self : Self) -> Bool {
  self.used >= self.limit
}

///|
pub fn GasMeter::remaining(self : Self) -> Int64 {
  self.limit - self.used
}

///|
///SandboxResult — 执行结果分型（成功载荷 / 燃料耗尽 / 失败原因）。
pub(all) enum SandboxResult {
  Succeeded(Json)
  OutOfGas
  Failed(String)
}

///|
///Sandbox — 沙箱执行契约：模块字节 + 入口 + 参数 + 燃料限额 → 分型结果。
pub(open) trait Sandbox {
  fn execute(Self, Bytes, String, Json, Int64) -> SandboxResult
}

///|
///StubSandbox — 确定性桩实现（wasmoon 集成前的契约验证与测试用）：
///空模块拒绝；燃料 ≤0 → OutOfGas；缺入口 → 失败；否则回显参数。
pub struct StubSandbox {
  mut calls : Int32
}

///|
pub fn StubSandbox::new() -> StubSandbox {
  { calls: 0, }
}

///|
impl Sandbox for StubSandbox with fn execute(self, bytes, entry, args, gas) -> SandboxResult {
  self.calls = self.calls + 1
  if bytes.length() == 0 {
    return Failed("invalid module: empty bytes")
  }
  if gas <= 0L {
    return OutOfGas
  }
  if entry == "" {
    return Failed("missing entry")
  }
  Succeeded(args)
}

///|
pub extend StubSandbox with Sandbox::{execute}

///|
///call_count — 契约观测面（调用次数）。
pub fn StubSandbox::call_count(self : Self) -> Int32 {
  self.calls
}
