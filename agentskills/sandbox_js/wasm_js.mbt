///|
///js WebAssembly 桥（extern "js"；模块对象经全局句柄表保留）。

///|
///wasm_compile — 编译 wasm 字节为 Module 并入全局表，返回句柄（失败 -1）。
pub extern "js" fn wasm_compile(bytes : Bytes) -> Int32 =
  #| (bytes) => {
  #|   try {
  #|     globalThis.__moonbitWasm = globalThis.__moonbitWasm || [];
  #|     globalThis.__moonbitWasm.push(new WebAssembly.Module(bytes));
  #|     return globalThis.__moonbitWasm.length - 1;
  #|   } catch (e) {
  #|     return -1;
  #|   }
  #| }

///|
///wasm_call — 实例化句柄模块并调用导出函数（返回字符串；失败 "ERR:<reason>"）。
///参数桥：arg_json 解析为 JS 数字直传，其余原样作字符串传参。
pub extern "js" fn wasm_call(
  handle : Int32,
  entry : String,
  arg_json : String,
) -> String =
  #| (handle, entry, arg) => {
  #|   try {
  #|     const mod = (globalThis.__moonbitWasm || [])[handle];
  #|     if (!mod) return "ERR:no module";
  #|     const inst = new WebAssembly.Instance(mod);
  #|     const fn = inst.exports[entry];
  #|     if (typeof fn !== "function") return "ERR:no export";
  #|     let value = arg;
  #|     try {
  #|       const parsed = JSON.parse(arg);
  #|       if (typeof parsed === "number") value = parsed;
  #|     } catch (_) {}
  #|     const out = fn(value);
  #|     return typeof out === "string" ? out : JSON.stringify(out ?? null);
  #|   } catch (e) {
  #|     return "ERR:" + e.message;
  #|   }
  #| }
