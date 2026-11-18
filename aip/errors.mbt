// AIP（GB/Z 185.6 智能体交互协议）错误分型（E3）

///|
pub(all) suberror AipError {
  Discovery(String)
  Registry(String)
  Capability(String)
  Dispatch(String)
  Envelope(String)
}

///|
pub fn AipError::part(self : AipError) -> String {
  match self {
    Discovery(_) => "gbz185.5"
    Registry(_) => "gbz185.3"
    Capability(_) => "gbz185.4"
    Dispatch(_) => "gbz185.6"
    Envelope(_) => "gbz185.6"
  }
}

///|
pub extend AipError with Show::{to_string, output}

///|
pub extend AipError with @moonbitlang/core/json.ToJson::{to_json}

///|
pub impl Show for AipError with fn output(self, logger) -> Unit {
  match self {
    Discovery(m) =>
      logger.write_string("aip/discovery(\{AipError::part(self)}): \{m}")
    Registry(m) =>
      logger.write_string("aip/registry(\{AipError::part(self)}): \{m}")
    Capability(m) =>
      logger.write_string("aip/capability(\{AipError::part(self)}): \{m}")
    Dispatch(m) =>
      logger.write_string("aip/dispatch(\{AipError::part(self)}): \{m}")
    Envelope(m) =>
      logger.write_string("aip/envelope(\{AipError::part(self)}): \{m}")
  }
}

///|
pub impl ToJson for AipError with fn to_json(self) -> Json {
  match self {
    Discovery(m) => { "part": "gbz185.5", "kind": "discovery", "message": m }
    Registry(m) => { "part": "gbz185.3", "kind": "registry", "message": m }
    Capability(m) => { "part": "gbz185.4", "kind": "capability", "message": m }
    Dispatch(m) => { "part": "gbz185.6", "kind": "dispatch", "message": m }
    Envelope(m) => { "part": "gbz185.6", "kind": "envelope", "message": m }
  }
}
