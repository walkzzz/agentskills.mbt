// 白盒测试：内部细节与边界（同包直访内部符号，不经过 @aip 门面）

///|
test "json_string_array_opt: non-object input raises envelope error" {
  try {
    let _ = json_string_array_opt(Json::string("x"), "key")
    panic()
  } catch {
    Envelope(_) => ()
    _ => panic()
  }
}

///|
test "json_string_array_opt: missing key returns empty array" {
  let out = json_string_array_opt(Json::empty_object(), "missing") catch {
    _ => panic()
  }
  assert_eq(out.length(), 0)
}

///|
test "json_string_array_opt: non-array value raises" {
  try {
    let _ = json_string_array_opt({ "key": Json::string("x") }, "key")
    panic()
  } catch {
    Envelope(_) => ()
    _ => panic()
  }
}

///|
test "json_string_array_opt: non-string element raises" {
  try {
    let _ = json_string_array_opt({ "key": [1.0] }, "key")
    panic()
  } catch {
    Envelope(_) => ()
    _ => panic()
  }
}

///|
test "json_string_array_opt: happy path preserves order" {
  let out = json_string_array_opt({ "key": ["a", "b", "c"] }, "key") catch {
    _ => panic()
  }
  assert_eq(out, ["a", "b", "c"])
}

///|
test "wire constants are pinned" {
  assert_eq(envelope_version(), "1")
  assert_eq(protocol_name(), "aip")
}

///|
test "from_wire rejects unknown values" {
  assert_true(IdentityStatus::from_wire("banned") is None)
  assert_true(IdentityStatus::from_wire("ACTIVE") is None)
  assert_true(MessageKind::from_wire("notify") is None)
  assert_true(IdentityStatus::from_wire("active") is Some(Active))
  assert_true(MessageKind::from_wire("task_request") is Some(TaskRequest))
}

///|
test "outbox sequence starts at one" {
  let node = AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    NoIdentity,
    true,
    [],
    [],
    [],
  )
  let proto = AipProtocol::new(node)
  AipProtocol::handle_register_response(proto, {
    accepted: true,
    aic: Some("1.2.156.185.2.1.99"),
    reason: None,
  }) catch {
    _ => panic()
  }
  let env = AipProtocol::dispatch(
    proto,
    Event,
    "urn:agent:group:g",
    ("x" : Json),
  )
  assert_eq(env.seq, 1L)
}

///|
test "invariant holds across full protocol cycle" {
  let node = AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    NoIdentity,
    true,
    ["skill"],
    [],
    [],
  )
  let proto = AipProtocol::new(node)
  assert_true(AipProtocol::invariant(proto))
  AipProtocol::handle_register_response(proto, {
    accepted: true,
    aic: Some("1.2.156.185.2.1.42"),
    reason: None,
  }) catch {
    _ => panic()
  }
  assert_true(AipProtocol::invariant(proto))
  let peer = AgentNode::from_frontmatter(
    "urn:agent:b",
    "B",
    Active,
    true,
    [],
    [],
    [],
  )
  let _ = AipProtocol::handle_discover_response(proto, { nodes: [peer], })
  let _ = AipProtocol::dispatch(proto, TaskRequest, "urn:agent:b", ("x" : Json))
  assert_true(AipProtocol::invariant(proto))
  assert_true(AipProtocol::peer_count(proto) == 1)
}
