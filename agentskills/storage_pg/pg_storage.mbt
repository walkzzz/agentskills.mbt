///|
///F08 PostgreSQL 存储后端（async 独立 API）。
///
///En: F08 PostgreSQL storage backend (async API).
///说明：`Storage` trait 是**同步契约**（内存/文件后端），而 PG 全 async——本包提供
///async 独立 API（以任务组驱动 PoolExecutor），不硬套同步 trait（见 docs/known-gaps.md）。
///kv 表：`agentskills_kv(k text PRIMARY KEY, v text NOT NULL)`；SQL 值经单引号转义拼接
///（本地联测用途；参数化准备语句留后续）。

///|
///sql_escape — 单引号 SQL 字面量转义。
pub fn sql_escape(s : String) -> String {
  let buf = StringBuilder()
  for c in s {
    if c == '\'' {
      buf.write_string("''")
    } else {
      buf.write_string("\{c}")
    }
  }
  buf.to_string()
}

///|
///kv_where — kv 行定位子句（避免各处重复拼接与转义）。
fn kv_where(k : String) -> String {
  "k = '" + sql_escape(k) + "'"
}

///|
///with_pg_storage — 创建连接池、任务组内驱动 PoolExecutor（README 模式）、
///初始化 kv 表，然后执行 body。端口固定 5432（pgpool 的 ConnectionTarget 不暴露端口）。
pub async fn with_pg_storage(
  host~ : String,
  user~ : String,
  password~ : String,
  dbname~ : String,
  body : async (@pgpool.Pool) -> Unit,
) -> Unit {
  let cfg = @pgpool.Config::Config(
    [@pgpool.ConnectionTarget(host~)],
    user~,
    dbname~,
    password~,
    ssl_mode=@pgclient.SslMode::Disable,
    application_name="agentskills-storage",
    pool=@pgpool.PoolConfig::PoolConfig(4),
  )
  let (pool, exec) = @pgpool.Pool::create(cfg)
  @async.with_task_group(async fn(g : @async.TaskGroup[Unit]) {
    g.spawn_bg(async fn() { exec.run() }, no_wait=true)
    pool.ready()
    pool.batch_execute(
      "CREATE TABLE IF NOT EXISTS agentskills_kv (k text PRIMARY KEY, v text NOT NULL)",
    )
    body(pool)
    pool.close()
  })
}

///|
///kv_put — 写入/覆盖（UPSERT）。
pub async fn kv_put(pool : @pgpool.Pool, k : String, v : String) -> Unit {
  pool.batch_execute(
    "INSERT INTO agentskills_kv (k, v) VALUES ('" +
    sql_escape(k) +
    "', '" +
    sql_escape(v) +
    "') ON CONFLICT (k) DO UPDATE SET v = EXCLUDED.v",
  )
}

///|
///kv_get — 读取（缺失返回 None）。
pub async fn kv_get(pool : @pgpool.Pool, k : String) -> String? {
  let rows = pool.query_all("SELECT v FROM agentskills_kv WHERE " + kv_where(k))
  if rows.length() == 0 {
    None
  } else {
    rows[0].get_text(0)
  }
}

///|
///kv_delete — 删除（存在则 true）。
pub async fn kv_delete(pool : @pgpool.Pool, k : String) -> Bool {
  let rows = pool.query_all("DELETE FROM agentskills_kv WHERE " + kv_where(k) + " RETURNING k")
  rows.length() > 0
}

///|
///kv_count_text — 行数（文本形式，避免整数解析依赖）。
pub async fn kv_count_text(pool : @pgpool.Pool) -> String? {
  let rows = pool.query_all("SELECT count(*)::text FROM agentskills_kv")
  if rows.length() == 0 {
    None
  } else {
    rows[0].get_text(0)
  }
}

///|
///kv_clear — 清空表（联测收尾）。
pub async fn kv_clear(pool : @pgpool.Pool) -> Unit {
  pool.batch_execute("DELETE FROM agentskills_kv")
}
