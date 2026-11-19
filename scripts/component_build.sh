#!/usr/bin/env bash
# component_build.sh — WIT → MoonBit 绑定 → wasm 模块 → WebAssembly Component
# 前置：wit-bindgen（cargo install wit-bindgen-cli）、wasm-tools
# 产物：components/agentskills.component.wasm（+ wasm-tools component wit 接口自证）
set -eu
cd "$(dirname "$0")/.."
COMP=components

command -v wit-bindgen >/dev/null 2>&1 || {
  echo "ERROR: wit-bindgen 未安装（cargo install wit-bindgen-cli）" >&2
  exit 1
}
HAVE_WASM_TOOLS=1
command -v wasm-tools >/dev/null 2>&1 || HAVE_WASM_TOOLS=0

# 每次从 WIT 重建生成物（WIT 是唯一真相源）
rm -rf "$COMP/gen" "$COMP/ffi" "$COMP/world" "$COMP/moon.mod" "$COMP/target" "$COMP/_build"
wit-bindgen moonbit "$COMP/wit/world.wit" --out-dir "$COMP" --derive-eq --derive-show --derive-error

# 注入已发布运行时依赖 + 写入真实 stub 实现（薄包装）
python - "$COMP" <<'PY'
import os, sys

comp = sys.argv[1]

# 1) moon.mod 注入 agentskills.mbt 依赖
mod_path = os.path.join(comp, 'moon.mod')
text = open(mod_path, encoding='utf-8').read()
if 'walkzzz/agentskills.mbt' not in text:
    if 'import {' in text:
        text = text.replace('import {', 'import {\n  "walkzzz/agentskills.mbt@0.1.0",', 1)
    else:
        text = text.rstrip() + '\n\nimport {\n  "walkzzz/agentskills.mbt@0.1.0",\n}\n'
    open(mod_path, 'w', encoding='utf-8', newline='\n').write(text)

# 2) skill-api 包的 stub 实现（包路径按 WIT package/interface 生成）
stub_dir = os.path.join(comp, 'gen', 'interface', 'walkzzz', 'agentskills', 'skill_api')
os.makedirs(stub_dir, exist_ok=True)
stub = '''// 实现由 scripts/component_build.sh 写入（薄包装 @agentskills 已发布运行时）。

///|
pub fn parse_name(skill_md : String) -> String {
  match @agentskills.parse_skill_md(skill_md) {
    Ok((m, _body)) => m.name
    Err(_) => ""
  }
}

///|
pub fn parse_description(skill_md : String) -> String {
  match @agentskills.parse_skill_md(skill_md) {
    Ok((m, _body)) => m.description
    Err(_) => ""
  }
}

///|
pub fn validate(skill_md : String) -> String {
  match @agentskills.parse_skill_md(skill_md) {
    Ok(_) => ""
    Err(e) => e
  }
}

///|
pub fn can_access(role_rank : UInt32, sens_rank : UInt32) -> Bool {
  role_rank >= sens_rank
}

///|
pub fn rrf_score(rank : UInt32, k : UInt32) -> Double {
  1.0 / (k.to_double() + rank.to_double())
}
'''
open(os.path.join(stub_dir, 'stub.mbt'), 'w', encoding='utf-8', newline='\n').write(stub)

# 3) 若生成的包结构使用 @skill 命名空间则无需改动——由 wit-bindgen 决定导出点
print('patched', comp)
PY

# 构建 wasm 模块（gen 包的 link.exports 由 wit-bindgen 生成）
cd "$COMP"
moon build --target wasm
WASM=$(_build_path=; find _build/wasm/release/build/gen -name 'gen.wasm' | head -1)
if [ -z "${WASM:-}" ]; then
  echo "ERROR: gen.wasm not found" >&2
  exit 1
fi
cd ..

# 组件化 + 接口自证
wasm-tools component embed "$COMP/wit" "$COMP/$WASM" --encoding utf16 --output "$COMP/embed.wasm"
wasm-tools component new "$COMP/embed.wasm" --output "$COMP/agentskills.component.wasm"
wasm-tools component wit "$COMP/agentskills.component.wasm"
echo "COMPONENT OK: $COMP/agentskills.component.wasm"