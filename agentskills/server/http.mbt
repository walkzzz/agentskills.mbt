///|
///F10 服务端契约 —— HTTP 请求/应答与路由分发核（Kernel 式纯逻辑，无 IO）。
///
///En: F10 server contract — HTTP request/response and routing kernel (pure logic).
///HTTPS/WebMCP/SSE 的传输层（@async socket + TLS）随 native 集成注入。

///|
pub(all) struct HttpRequest {
  http_method : String
  path : String
  body : String
}

///|
pub(all) struct HttpResponse {
  status : Int32
  body : String
}

///|
pub fn ok(body : String) -> HttpResponse {
  { status: 200, body, }
}

///|
pub fn not_found() -> HttpResponse {
  { status: 404, body: "Not Found", }
}

///|
pub fn method_not_allowed() -> HttpResponse {
  { status: 405, body: "Method Not Allowed", }
}

///|
///RouteKind — 路径匹配方式（精确 / 前缀）。
pub(all) enum RouteKind {
  Exact
  Prefix
}

///|
pub(all) struct Route {
  http_method : String
  path : String
  kind : RouteKind
  handler : (HttpRequest) -> HttpResponse
}

///|
///Router — 路由表（注册/分发；路径命中但方法不符 → 405，无命中 → 404）。
pub struct Router {
  routes : Array[Route]
}

///|
pub fn Router::new() -> Router {
  { routes: [], }
}

///|
pub fn Router::add(
  self : Self,
  http_method : String,
  path : String,
  kind : RouteKind,
  handler : (HttpRequest) -> HttpResponse,
) -> Unit {
  self.routes.push({ http_method, path, kind, handler, })
}

///|
pub fn Router::dispatch(self : Self, req : HttpRequest) -> HttpResponse {
  let mut path_matched = false
  for r in self.routes {
    let hit = match r.kind {
      Exact => req.path == r.path
      Prefix => req.path.has_prefix(r.path)
    }
    if hit {
      path_matched = true
      if r.http_method == req.http_method {
        return (r.handler)(req)
      }
    }
  }
  if path_matched {
    method_not_allowed()
  } else {
    not_found()
  }
}
