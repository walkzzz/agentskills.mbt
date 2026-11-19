///|
///F08 PostgreSQL 联测演示：建表 → 写/读/覆盖/删除/计数 → 清空。
///运行（凭据经环境变量，不进仓库）：
///  PG_PASSWORD=*** moon run examples/storage_pg_demo --target native
///可选：PG_HOST（默认 127.0.0.1）/ PG_USER（postgres）/ PG_DB（postgres）。
///
fn env_or(key : String, default : String) -> String {
  match @env.get_env_var(key) {
    Some(v) => v
    None => default
  }
}

///|
fn show_opt(o : String?) -> String {
  match o {
    Some(s) => s
    None => "(none)"
  }
}

///|
async fn main {
  let host = env_or("PG_HOST", "127.0.0.1")
  let user = env_or("PG_USER", "postgres")
  let dbname = env_or("PG_DB", "postgres")
  let password = match @env.get_env_var("PG_PASSWORD") {
    Some(p) => p
    None => {
      println("SKIP: PG_PASSWORD env not set")
      return
    }
  }
  @storage_pg.with_pg_storage(host~, user~, password~, dbname~, async fn(pool) {
    @storage_pg.kv_clear(pool)
    @storage_pg.kv_put(pool, "skill/demo", "{\"name\":\"demo\"}")
    @storage_pg.kv_put(pool, "skill/中文", "多行\n值\t制表")
    let v1 = @storage_pg.kv_get(pool, "skill/demo")
    let cnt1 = @storage_pg.kv_count_text(pool)
    println("put/get: " + show_opt(v1))
    println("count after 2 puts: " + show_opt(cnt1))
    // 覆盖写
    @storage_pg.kv_put(pool, "skill/demo", "{\"name\":\"demo2\"}")
    let v2 = @storage_pg.kv_get(pool, "skill/demo")
    println("overwrite: " + show_opt(v2))
    // 中文键往返
    let vc = @storage_pg.kv_get(pool, "skill/中文")
    println("cjk roundtrip: " + show_opt(vc))
    // 删除
    let del = @storage_pg.kv_delete(pool, "skill/demo")
    println("delete exists: " + (if del { "true" } else { "false" }))
    println(
      "delete again: " +
      (if @storage_pg.kv_delete(pool, "skill/demo") { "true" } else { "false" }),
    )
    let after = @storage_pg.kv_get(pool, "skill/demo")
    println("get after delete: " + show_opt(after))
    @storage_pg.kv_clear(pool)
    println("clear: done")
  })
  println("PG DEMO OK")
}
