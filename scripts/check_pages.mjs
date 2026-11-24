#!/usr/bin/env node
// 展示页自检：静态结构 + 钩子 + JS 导出 + 技能运行时语义 + 口径一致性。
// Pages self-check for agentskills.mbt.

import { readFileSync, existsSync, copyFileSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const JS_BUILD = join(
  ROOT,
  '_build/js/release/build/walkzzz/agentskills.mbt/playground/playground.js',
);
const JS_DOCS = join(ROOT, 'docs/playground.js');

let failures = 0;
let total = 0;
function check(name, ok, detail) {
  total++;
  console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}${detail ? `  (${detail})` : ''}`);
  if (!ok) failures++;
}

/* ---------- 静态资源与结构 ---------- */

for (const f of ['docs/index.html', 'docs/app.js', 'docs/style.css']) {
  check(`asset exists: ${f}`, existsSync(join(ROOT, f)));
}
const html = readFileSync(join(ROOT, 'docs/index.html'), 'utf8');
const css = readFileSync(join(ROOT, 'docs/style.css'), 'utf8');
const app = readFileSync(join(ROOT, 'docs/app.js'), 'utf8');

check('index mentions agentskills + SKILL.md', html.includes('agentskills.mbt') && html.includes('SKILL.md'));
check('loads app.js / style.css', html.includes('app.js') && html.includes('style.css'));
check('html lang=zh-CN', html.includes('<html lang="zh-CN"'));
check('light default + dark palette', html.includes('data-theme="light"') && css.includes("html[data-theme='dark']"));
check('theme persistence key', html.includes('agentskills-mbt-theme') && app.includes('agentskills-mbt-theme'));
check('sticky topbar', css.includes('.topbar { position: sticky'));
check('nav six anchors', ['#features', '#demo', '#start', '#api', '#quality', '#docs'].every((h) => html.includes(`href="${h}"`)));
check('theme toggle + github', html.includes('id="theme-toggle"') && html.includes('github.com/walkzzz/agentskills.mbt'));
check('Open Graph metadata', html.includes('property="og:title"') && html.includes('property="og:description"') && html.includes('property="og:url"'));
check('inline svg favicon', html.includes('rel="icon"'));
check('skip link', html.includes('class="skip-link"'));
check('footer mooncakes link', html.includes('mooncakes.io/docs/walkzzz/agentskills.mbt'));
check('no external script/style CDN', !/<script[^>]+src="https?:/.test(html) && !/<link[^>]+href="https?:/.test(html));
check('hero live status', html.includes('id="hero-status"') && html.includes('id="hero-json"'));
check('12 capability cards', (html.match(/class="feature"/g) || []).length === 12, `${(html.match(/class="feature"/g) || []).length}`);
check('9 demo cards', (html.match(/<article class="card">/g) || []).length === 9, `${(html.match(/<article class="card">/g) || []).length}`);
check('copy targets >= 6', (html.match(/data-copy-target="/g) || []).length >= 6);
check('mobile nav toggle present', html.includes('id="nav-toggle"') && html.includes('aria-controls="site-nav"') && html.includes('id="site-nav"'));
check('mobile nav drawer css', css.includes('.nav.open { display: flex; }'));
check('mobile nav js bound', app.includes('nav-toggle') && app.includes('closeNav'));
check('validation hints present', html.includes('k 必须 &gt; 0') && html.includes('max_chars 必须 ≥ 1'));

/* ---------- 演示钩子 ---------- */

const hookIds = [
  'skill-md', 'parse-out', 'v-name', 'v-desc', 'v-license', 'v-compat', 'validate-out',
  'reg-names', 'registry-out', 'rbac-out', 'rbac-role', 'rbac-sens', 'rbac-check-out',
  'msgs', 'keep', 'budget', 'compact-out', 'trunc-text', 'trunc-n', 'trunc-out',
  'rankings', 'rrf-k', 'rrf-top', 'rrf-out', 'tool-name', 'tool-desc', 'tool-out',
  'chars-json', 'chars-out',
];
for (const id of hookIds) {
  check(`hook: #${id}`, html.includes(`id="${id}"`));
}
const actionRunners = {
  parse: 'runParse',
  validate: 'runValidate',
  registry: 'runRegistry',
  rbac: 'runRbac',
  'rbac-check': 'runRbacCheck',
  compact: 'runCompact',
  truncate: 'runTruncate',
  rrf: 'runRrf',
  tool: 'runTool',
  chars: 'runChars',
};
for (const [run, fn] of Object.entries(actionRunners)) {
  check(`action: ${run}`, app.includes(fn));
}
check('presets bound', app.includes('PRESETS') && ['bad', 'invalid', 'reset-parse', 'reset-validate'].every((p) => html.includes(`data-preset="${p}"`)));

/* ---------- 文档链接与锚点 ---------- */

for (const doc of ['architecture', 'performance', 'comparison', 'assessment', 'proposal', 'migration', 'security', 'known-gaps', 'TEST_REPORT']) {
  check(`docs link: ${doc}.md`, html.includes(`docs/${doc}.md`));
}
for (const anchor of ['features', 'demo', 'start', 'api', 'quality', 'docs', 'how', 'top']) {
  check(`section anchor: #${anchor}`, html.includes(`id="${anchor}"`));
}

/* ---------- 版本与口径 ---------- */

const mod = readFileSync(join(ROOT, 'agentskills/moon.mod'), 'utf8');
const version = (mod.match(/version\s*=\s*"([^"]+)"/) || [])[1] || '';
check('version matches agentskills/moon.mod', version.length > 0 && html.includes(version), version);
check('version is 0.2.1', version === '0.2.1', version);
check('badges: tests 61 + portables', html.includes('61') && html.includes('62 / 61 / 61'));
check('badges: mutation 24 / 24', html.includes('24 / 24'));
check('badges: prove 8 goals', html.includes('8') && html.includes('goals proved'));
check('package count 19', html.includes('19') && html.includes('包'));

/* ---------- 构建 playground JS ---------- */

if (!existsSync(JS_BUILD)) {
  const r = spawnSync('moon build --target js --release agentskills/playground', {
    shell: true,
    encoding: 'utf8',
    cwd: ROOT,
  });
  check('build playground js', r.status === 0, (r.stderr ?? '').slice(0, 200));
}
if (existsSync(JS_BUILD)) copyFileSync(JS_BUILD, JS_DOCS);
check('docs/playground.js exists', existsSync(JS_DOCS));
if (!existsSync(JS_DOCS)) {
  console.log(`\n=== pages check: FAIL (${failures}/${total}) ===`);
  process.exit(1);
}

/* ---------- 导出与语义 ---------- */

const pg = await import(pathToFileURL(JS_DOCS).href);
const exportsList = [
  'skill_parse',
  'skill_validate',
  'registry_demo',
  'rbac_matrix',
  'rbac_check',
  'compact_demo',
  'truncate_text',
  'rrf_demo',
  'total_chars',
  'total_chars_detail',
  'tool_mcp_entry',
];
for (const name of exportsList) {
  check(`export: ${name}`, typeof pg[name] === 'function');
}

const md = '---\nname: demo\ndescription: A demo skill\nlicense: MIT\ncompatibility:\n  - moonbit\n---\n\n# Demo\n\nbody';
const parsed = JSON.parse(pg.skill_parse(md));
check('parse name/description', parsed.name === 'demo' && parsed.description === 'A demo skill');
check('parse license + compatibility', parsed.license === 'MIT' && parsed.compatibility.length === 1);
check('parse body chars > 0', parsed.body_chars > 0, String(parsed.body_chars));
check('parse rejects missing frontmatter', JSON.parse(pg.skill_parse('plain text')).ok === false);

const valid = JSON.parse(pg.skill_validate('demo', 'A demo skill', 'MIT', 'moonbit, claude'));
check('validate accepts valid manifest', valid.ok === true && valid.valid === true);
const emptyName = JSON.parse(pg.skill_validate('', 'desc', '', ''));
check('validate rejects empty name', emptyName.ok === false && emptyName.error.includes('name'));

const registry = JSON.parse(pg.registry_demo('alpha, zeta, beta'));
check('registry counts three skills', registry.count === 3);
check('registry names are shortlex', JSON.stringify(registry.names) === JSON.stringify(['beta', 'zeta', 'alpha']), JSON.stringify(registry.names));
check('registry promotes first skill', registry.levels.includes('fully-loaded'));

const matrix = JSON.parse(pg.rbac_matrix());
check('rbac matrix 3x3 shape', matrix.matrix.length === 3 && matrix.matrix[0].length === 3);
check('rbac matrix admin row all true', matrix.matrix[2].every(Boolean));
check('rbac matrix viewer row only public', matrix.matrix[0][0] === true && matrix.matrix[0][1] === false);
check('rbac ranks are ordered', JSON.stringify(matrix.role_ranks) === JSON.stringify([0, 1, 2]));
check('rbac_check admin/confidential', pg.rbac_check('admin', 'confidential') === true);
check('rbac_check viewer/internal denied', pg.rbac_check('viewer', 'internal') === false);
check('rbac_check unknown role denied', pg.rbac_check('root', 'public') === false);

const messages = JSON.stringify([
  { role: 'system', content: 'you are helpful' },
  { role: 'user', content: 'first' },
  { role: 'user', content: 'second' },
  { role: 'assistant', content: 'third' },
]);
const compacted = JSON.parse(pg.compact_demo(messages, 2, 800));
check('compact skips fold when no gain', compacted.folded === false && compacted.saved_chars === 0);
check('compact keeps original messages on skip', compacted.messages.length === 4 && compacted.output_chars === compacted.input_chars);
check('compact reports folded flag', compacted.note.includes('已跳过'));

const longMessages = JSON.stringify([
  { role: 'system', content: 'sys' },
  { role: 'user', content: 'x'.repeat(200) },
  { role: 'user', content: 'y'.repeat(200) },
  { role: 'assistant', content: 'z'.repeat(200) },
]);
const saved = JSON.parse(pg.compact_demo(longMessages, 1, 800));
check('compact folds when gain is positive', saved.folded === true && saved.saved_chars > 0);
check('compact inserts placeholder when folded', saved.messages.some((m) => m.content.includes('[compacted')));
check('compact rejects invalid json', JSON.parse(pg.compact_demo('{bad', 2, 800)).ok === false);

check('truncate keeps codepoints', pg.truncate_text('你好世界abcdef', 4) === '你好世界…');
check('truncate short text untouched', pg.truncate_text('abc', 4) === 'abc');
check('truncate non-positive bound returns empty', pg.truncate_text('abc', 0) === '' && pg.truncate_text('abc', -1) === '');

const rrf = JSON.parse(pg.rrf_demo(JSON.stringify([['a', 'b', 'c'], ['b', 'c']]), 60, 2));
check('rrf returns requested top_n', rrf.count === 2);
check('rrf top doc is b', rrf.hits[0].doc_id === 'b', rrf.hits[0].doc_id);
check('rrf scores descend', rrf.hits[0].score >= rrf.hits[1].score);
check('rrf scores are finite numbers', rrf.hits.every((h) => typeof h.score === 'number' && Number.isFinite(h.score)));
check('rrf rejects bad json', JSON.parse(pg.rrf_demo('{bad', 60, 2)).ok === false);
check('rrf rejects k=0', JSON.parse(pg.rrf_demo(JSON.stringify([['a']]), 0, 2)).ok === false);
check('rrf rejects negative k', JSON.parse(pg.rrf_demo(JSON.stringify([['a']]), -1, 2)).ok === false);

check('total_chars counts CJK + emoji', pg.total_chars(JSON.stringify([{ role: 'user', content: '你好' }, { role: 'assistant', content: '🙂🙂' }])) === 4);
check('total_chars invalid json = -1', pg.total_chars('{bad') === -1);
const detailOk = JSON.parse(pg.total_chars_detail(JSON.stringify([{ role: 'user', content: '你好' }])));
check('total_chars_detail ok + chars', detailOk.ok === true && detailOk.chars === 2);
check('total_chars_detail classifies bad json', JSON.parse(pg.total_chars_detail('{bad')).error === 'invalid messages JSON');
check('total_chars_detail classifies content type', JSON.parse(pg.total_chars_detail(JSON.stringify([{ role: 'user', content: 1 }]))).error === 'message content must be a string');
check('total_chars_detail classifies non-array', JSON.parse(pg.total_chars_detail('{}')).error === 'messages must be a JSON array');

const tool = JSON.parse(pg.tool_mcp_entry('net_fetch', 'Fetch a URL'));
check('tool mcp entry name', tool.name === 'net_fetch');
check('tool mcp entry has inputSchema', tool.inputSchema && tool.inputSchema.type === 'object');
check('tool rejects empty name', JSON.parse(pg.tool_mcp_entry('', 'd')).ok === false);
check('tool rejects empty description', JSON.parse(pg.tool_mcp_entry('t', '  ')).ok === false);
check('tool rejects long name', JSON.parse(pg.tool_mcp_entry('n'.repeat(65), 'd')).ok === false);

/* ---------- 汇总 ---------- */

console.log(`\n=== pages check: ${failures === 0 ? 'PASS' : `FAIL (${failures})`} · ${total} checks ===`);
if (failures > 0) process.exit(1);