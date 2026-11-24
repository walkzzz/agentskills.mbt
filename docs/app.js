import {
  skill_parse,
  skill_validate,
  registry_demo,
  rbac_matrix,
  rbac_check,
  compact_demo,
  truncate_text,
  rrf_demo,
  total_chars,
  tool_mcp_entry,
} from "./playground.js";

const $ = (sel) => document.querySelector(sel);
const $$ = (sel) => Array.from(document.querySelectorAll(sel));

/* ---------- 输出渲染 ---------- */

function pretty(text) {
  try {
    return JSON.stringify(JSON.parse(text), null, 2);
  } catch {
    return String(text);
  }
}

function isError(text) {
  return typeof text === "string" && text.startsWith('{"ok":false');
}

function showOut(selector, text, ok) {
  const node = $(selector);
  if (!node) return;
  node.textContent = pretty(text);
  node.classList.toggle("ok", ok === true);
  node.classList.toggle("bad", ok === false);
}

const showOk = (selector, text) => showOut(selector, text, true);
const showBad = (selector, text) => showOut(selector, text, false);

function auto(selector, text) {
  (isError(text) ? showBad : showOk)(selector, text);
}

/* ---------- 主题 ---------- */

const THEME_KEY = "agentskills-mbt-theme";
const themeToggle = $("#theme-toggle");

function applyTheme(theme) {
  document.documentElement.dataset.theme = theme;
  if (themeToggle) {
    themeToggle.textContent = theme === "dark" ? "◐" : "☀";
    themeToggle.setAttribute(
      "aria-label",
      theme === "dark" ? "切换到浅色主题" : "切换到深色主题",
    );
    themeToggle.title = themeToggle.getAttribute("aria-label");
  }
}

if (themeToggle) {
  themeToggle.addEventListener("click", () => {
    const next = document.documentElement.dataset.theme === "dark" ? "light" : "dark";
    applyTheme(next);
    try {
      localStorage.setItem(THEME_KEY, next);
    } catch {
      /* 隐私模式忽略 */
    }
  });
  applyTheme(document.documentElement.dataset.theme === "light" ? "light" : "dark");
}

/* ---------- 演示动作 ---------- */

function runParse() {
  auto("#parse-out", skill_parse($("#skill-md").value));
}

function runValidate() {
  auto(
    "#validate-out",
    skill_validate(
      $("#v-name").value.trim(),
      $("#v-desc").value.trim(),
      $("#v-license").value.trim(),
      $("#v-compat").value,
    ),
  );
}

function runRegistry() {
  auto("#registry-out", registry_demo($("#reg-names").value));
}

function runRbac() {
  auto("#rbac-out", rbac_matrix());
}

function runRbacCheck() {
  const allowed = rbac_check($("#rbac-role").value, $("#rbac-sens").value);
  const payload = JSON.stringify({
    role: $("#rbac-role").value,
    sensitivity: $("#rbac-sens").value,
    allowed,
  });
  (allowed ? showOk : showBad)("#rbac-check-out", payload);
}

function runCompact() {
  auto(
    "#compact-out",
    compact_demo(
      $("#msgs").value,
      Number($("#keep").value) | 0,
      Number($("#budget").value) | 0,
    ),
  );
}

function runTruncate() {
  const text = truncate_text($("#trunc-text").value, Number($("#trunc-n").value) | 0);
  showOk("#trunc-out", JSON.stringify({ result: text, codepoints: Array.from(text).length }));
}

function runRrf() {
  auto(
    "#rrf-out",
    rrf_demo($("#rankings").value, Number($("#rrf-k").value) | 0, Number($("#rrf-top").value) | 0),
  );
}

function runTool() {
  showOk("#tool-out", tool_mcp_entry($("#tool-name").value.trim(), $("#tool-desc").value.trim()));
}

function runChars() {
  const n = total_chars($("#chars-json").value);
  if (n < 0) {
    showBad("#chars-out", '{"ok":false,"error":"invalid messages JSON"}');
  } else {
    showOk("#chars-out", JSON.stringify({ ok: true, chars: n }));
  }
}

function runHero() {
  const md = $("#skill-md").value;
  const text = skill_parse(md);
  if (isError(text)) {
    $("#hero-json").textContent = text;
    $("#hero-status").textContent = "解析失败";
    return;
  }
  let data = null;
  try {
    data = JSON.parse(text);
  } catch {
    data = null;
  }
  if (!data) return;
  $("#hero-name").textContent = data.name;
  $("#hero-compat").textContent = String((data.compatibility || []).length);
  $("#hero-body").textContent = String(data.body_chars);
  $("#hero-json").textContent = JSON.stringify(
    {
      name: data.name,
      license: data.license,
      compatibility: data.compatibility,
      has_license: data.has_license,
      body_chars: data.body_chars,
    },
    null,
    2,
  );
  $("#hero-status").textContent = "解析成功（frontmatter + 正文）";
}

const ACTIONS = {
  parse: runParse,
  validate: runValidate,
  registry: runRegistry,
  rbac: runRbac,
  "rbac-check": runRbacCheck,
  compact: runCompact,
  truncate: runTruncate,
  rrf: runRrf,
  tool: runTool,
  chars: runChars,
};

$$("button[data-run]").forEach((button) => {
  button.addEventListener("click", () => {
    const action = ACTIONS[button.dataset.run];
    if (action) action();
  });
});

const PRESETS = {
  bad: {
    selector: "#skill-md",
    value: "no frontmatter at all\n\njust body text",
    action: "parse",
  },
  invalid: {
    selector: "#v-name",
    value: "",
    action: "validate",
  },
};

$$("button[data-preset]").forEach((button) => {
  button.addEventListener("click", () => {
    const preset = PRESETS[button.dataset.preset];
    if (!preset) return;
    $(preset.selector).value = preset.value;
    const run = ACTIONS[preset.action];
    if (run) run();
  });
});

const ENTER_ACTIONS = [
  ["#v-name", "validate"],
  ["#v-desc", "validate"],
  ["#v-license", "validate"],
  ["#v-compat", "validate"],
  ["#reg-names", "registry"],
  ["#keep", "compact"],
  ["#budget", "compact"],
  ["#trunc-text", "truncate"],
  ["#trunc-n", "truncate"],
  ["#rrf-k", "rrf"],
  ["#rrf-top", "rrf"],
  ["#tool-name", "tool"],
  ["#tool-desc", "tool"],
];

ENTER_ACTIONS.forEach(([selector, action]) => {
  const field = $(selector);
  if (!field) return;
  field.addEventListener("keydown", (event) => {
    if (event.key !== "Enter") return;
    event.preventDefault();
    const button = $(`button[data-run="${action}"]`);
    if (button) button.click();
  });
});

/* ---------- 复制 ---------- */

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    await navigator.clipboard.writeText(text);
    return;
  }
  const area = document.createElement("textarea");
  area.value = text;
  area.setAttribute("readonly", "");
  area.style.position = "fixed";
  area.style.opacity = "0";
  document.body.appendChild(area);
  area.select();
  document.execCommand("copy");
  document.body.removeChild(area);
}

$$("[data-copy-target]").forEach((button) => {
  button.addEventListener("click", async () => {
    const target = document.getElementById(button.dataset.copyTarget);
    if (!target) return;
    const original = button.textContent;
    try {
      await copyText(target.textContent.trim());
      button.textContent = "已复制";
    } catch {
      button.textContent = "复制失败";
    }
    setTimeout(() => {
      button.textContent = original;
    }, 1400);
  });
});

/* ---------- 导航高亮 ---------- */

const navLinks = $$(".nav a");
const sections = navLinks
  .map((link) => document.querySelector(link.getAttribute("href")))
  .filter(Boolean);

if ("IntersectionObserver" in window && sections.length > 0) {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        navLinks.forEach((link) => {
          link.classList.toggle(
            "active",
            link.getAttribute("href") === `#${entry.target.id}`,
          );
        });
      });
    },
    { rootMargin: "-45% 0px -50% 0px", threshold: 0 },
  );
  sections.forEach((section) => observer.observe(section));
}

/* ---------- 初始化 ---------- */

runHero();
runParse();
runValidate();
runRegistry();
runRbac();
runRbacCheck();
runCompact();
runTruncate();
runRrf();
runTool();
runChars();