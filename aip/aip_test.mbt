// GB/Z 185.6 AIP 协议黑盒测试（对齐 TCA TC-F17-001~005）

///|
test "identity json wire roundtrip" {
  let node = @aip.AgentNode::from_frontmatter(
    "urn:agent:walkzzz:node-1",
    "Node One",
    @aip.Active,
    true,
    ["skill:demo"],
    ["text"],
    ["text"],
  )
  let back = @aip.AgentNode::from_json(node.to_json()) catch { _ => panic() }
  assert_eq(back, node)
}

///|
test "envelope json wire roundtrip (TC-F17-003)" {
  let a = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let pa = @aip.AipProtocol::new(a)
  let payload : Json = { "body": "hello" }
  let env = @aip.AipProtocol::dispatch(
    pa,
    @aip.Event,
    "urn:agent:group:g",
    payload,
  ) catch {
    err => {
      println("dispatch failed: \{err}")
      panic()
    }
  }
  let back = @aip.AipEnvelope::from_json(env.to_json()) catch {
    err => {
      println("from_json failed: \{err}")
      panic()
    }
  }
  assert_eq(back, env)
}

///|
test "atr register flow (GB/Z 185.3)" {
  let node = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.NoIdentity,
    true,
    [],
    [],
    [],
  )
  let proto = @aip.AipProtocol::new(node)
  let req = @aip.AipProtocol::register_request(proto)
  assert_true(req.node.identity.identity_status is @aip.NoIdentity)
  @aip.AipProtocol::handle_register_response(proto, {
    accepted: true,
    aic: Some("1.2.156.185.2.1.42"),
    reason: None,
  }) catch {
    _ => panic()
  }
  assert_true(@aip.AipProtocol::identity(proto).identity_status is @aip.Active)
  assert_eq(@aip.AipProtocol::identity(proto).aic, "1.2.156.185.2.1.42")
}

///|
test "atr reject raises registry error" {
  let node = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.NoIdentity,
    true,
    [],
    [],
    [],
  )
  let proto = @aip.AipProtocol::new(node)
  let mut got = false
  try {
    @aip.AipProtocol::handle_register_response(proto, {
      accepted: false,
      aic: None,
      reason: Some("denied"),
    })
    panic()
  } catch {
    @aip.Registry(_) => got = true
    _ => panic()
  }
  assert_true(got)
}

///|
test "adp discover registers discoverable peers (GB/Z 185.5)" {
  let a = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let proto = @aip.AipProtocol::new(a)
  let b = @aip.AgentNode::from_frontmatter(
    "urn:agent:b",
    "B",
    @aip.Active,
    true,
    ["skill:demo"],
    [],
    [],
  )
  let hidden = @aip.AgentNode::from_frontmatter(
    "urn:agent:c",
    "C",
    @aip.Active,
    false,
    [],
    [],
    [],
  )
  let added = @aip.AipProtocol::handle_discover_response(proto, {
    nodes: [b, hidden],
  })
  assert_eq(added, 1)
  assert_true(@aip.AipProtocol::peer(proto, "urn:agent:b") is Some(_))
  assert_true(@aip.AipProtocol::peer(proto, "urn:agent:c") is None)
  assert_eq(@aip.AipProtocol::peer_count(proto), 1)
}

///|
test "aip dispatch and receive with replay rejection (GB/Z 185.6)" {
  let a = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let pa = @aip.AipProtocol::new(a)
  let b = @aip.AgentNode::from_frontmatter(
    "urn:agent:b",
    "B",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let pb = @aip.AipProtocol::new(b)
  let _ = @aip.AipProtocol::handle_discover_response(pa, { nodes: [b], })
  let env = @aip.AipProtocol::dispatch(
    pa,
    @aip.TaskRequest,
    "urn:agent:b",
    ("ping" : Json),
  ) catch {
    _ => panic()
  }
  assert_eq(env.seq, 1L)
  let msg = @aip.AipProtocol::receive(pb, env) catch { _ => panic() }
  assert_eq(msg.sender_urn, "urn:agent:a")
  let env2 = { ..env, seq: 2L, payload: ("pong" : Json), }
  let msg2 = @aip.AipProtocol::receive(pb, env2) catch { _ => panic() }
  assert_eq(msg2.seq, 2L)
  let mut rejected = false
  try {
    let _ = @aip.AipProtocol::receive(pb, env2)
    panic()
  } catch {
    @aip.Envelope(_) => rejected = true
    _ => panic()
  }
  assert_true(rejected)
}

///|
test "dispatch requires active identity" {
  let node = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.NoIdentity,
    true,
    [],
    [],
    [],
  )
  let proto = @aip.AipProtocol::new(node)
  let mut got = false
  try {
    let _ = @aip.AipProtocol::dispatch(
      proto,
      @aip.Event,
      "urn:agent:group:g",
      ("x" : Json),
    )
    panic()
  } catch {
    @aip.Registry(_) => got = true
    _ => panic()
  }
  assert_true(got)
}

///|
test "unknown unicast recipient rejected" {
  let a = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let proto = @aip.AipProtocol::new(a)
  let mut got = false
  try {
    let _ = @aip.AipProtocol::dispatch(
      proto,
      @aip.Event,
      "urn:agent:unknown",
      ("x" : Json),
    )
    panic()
  } catch {
    @aip.Dispatch(_) => got = true
    _ => panic()
  }
  assert_true(got)
}

///|
test "envelope version and protocol checks" {
  let a = @aip.AgentNode::from_frontmatter(
    "urn:agent:a",
    "A",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let pa = @aip.AipProtocol::new(a)
  let env = @aip.AipProtocol::dispatch(
    pa,
    @aip.Heartbeat,
    "urn:agent:group:g",
    Json::empty_object(),
  ) catch {
    _ => panic()
  }
  let bad_version = { ..env, envelope_version: "9", }
  let b = @aip.AgentNode::from_frontmatter(
    "urn:agent:b",
    "B",
    @aip.Active,
    true,
    [],
    [],
    [],
  )
  let pb = @aip.AipProtocol::new(b)
  let mut got = false
  try {
    let _ = @aip.AipProtocol::receive(pb, bad_version)
    panic()
  } catch {
    @aip.Envelope(_) => got = true
    _ => panic()
  }
  assert_true(got)
  let mut decode_rejected = false
  try {
    let _ = @aip.AipEnvelope::from_json(bad_version.to_json())
    panic()
  } catch {
    @aip.Envelope(_) => decode_rejected = true
    _ => panic()
  }
  assert_true(decode_rejected)
}

///|
test "aip error part mapping" {
  let err : @aip.AipError = @aip.Envelope("bad")
  assert_eq(err.part(), "gbz185.6")
  let err2 : @aip.AipError = @aip.Discovery("missing")
  assert_eq(err2.part(), "gbz185.5")
}
