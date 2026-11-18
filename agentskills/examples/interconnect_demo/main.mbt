///|
fn node(urn : String, name : String) -> @discovery.AgentNode {
  @discovery.AgentNode::from_frontmatter(
    urn,
    name,
    @identity.NoIdentity,
    true,
    ["skill:demo"],
    ["text"],
    ["text"],
  )
}

///|
fn show(r : Result[String, String]) -> String {
  match r {
    Ok(s) => s
    Err(e) => "FAILED: \{e}"
  }
}

///|
///D5 双智能体互联演示（决赛剧本）：alpha/beta 两协议实例完成
///单播直连 → 群组 dispatch → fanout → receive → 重放攻击拒收 → 状态机不变量。
///sans-I/O：全程 FakeTransport 语义，零网络依赖，一条命令 moon run。
fn main raise {
  println("== GB/Z 185-2026 AIP 双智能体互联演示 ==")
  let node_a = node("urn:agent:walkzzz:alpha", "alpha")
  let node_b = node("urn:agent:walkzzz:beta", "beta")
  let a = @aip.AipProtocol::new(node_a)
  let b = @aip.AipProtocol::new(node_b)
  println("alpha = \{a.self_urn()}")
  println("beta  = \{b.self_urn()}")
  // [0] ATR 注册激活（GB/Z 185.3：真实部署由 TokenRegistry 裁决；演示 accept-all 直通）
  let _ = a.register_request()
  a.handle_register_response({
    accepted: true,
    aic: Some("1.2.156.185.2.1"),
    reason: None,
  })
  let _ = b.register_request()
  b.handle_register_response({
    accepted: true,
    aic: Some("1.2.156.185.2.2"),
    reason: None,
  })
  println("[0] ATR 注册: alpha/beta 身份激活 (AIC 1.2.156.185.2.1/2)")
  // [0.5] ADP 发现：互换 peer 表（真实部署由 beta 处理 DiscoverRequest 应答）
  let _ = a.discover_request()
  let added_a = a.handle_discover_response({ nodes: [node_b], })
  let _ = b.discover_request()
  let added_b = b.handle_discover_response({ nodes: [node_a], })
  println(
    "[0.5] ADP 发现: alpha 识别 \{added_a} 个新 peer, beta 识别 \{added_b} 个",
  )
  // [1] 单播直连：send_direct = dispatch + receive 一步完成（beta 解出 AipMessage）
  let r1 : Result[String, String] = try {
    let _ = @aip.send_direct(a, b, @aip.Event, Json::string("hello from alpha"))
    Ok("beta received AipMessage OK")
  } catch {
    e => Err(@aip.AipError::to_string(e))
  }
  println("[1] 单播直连: \{show(r1)}")
  // [2] 群组 dispatch → fanout → receive
  let r2 : Result[String, String] = try {
    let env = a.dispatch(
      @aip.Event,
      "urn:agent:group:ops",
      Json::string("group hello"),
    )
    let outs = @aip.fanout(env, [b.self_urn()][:])
    let _ = b.receive(outs[0])
    Ok("fanout=\{outs.length()} delivered")
  } catch {
    e => Err(@aip.AipError::to_string(e))
  }
  println("[2] 群组分发: \{show(r2)}")
  // [3] 重放攻击：变异信封再次投递，防重放应拒收
  let r3 : Result[String, String] = try {
    let env3 = a.dispatch(
      @aip.Event,
      "urn:agent:group:ops",
      Json::string("replay probe"),
    )
    let mutated = @aip.generate_mutated_envelope(env3, 0)
    let _ = b.receive(mutated)
    Ok("accepted (no anti-replay trigger for this mutation)")
  } catch {
    e => Ok("REJECTED: \{@aip.AipError::to_string(e)} (anti-replay holds)")
  }
  println("[3] 重放攻击: \{show(r3)}")
  // [4] 状态机不变量与对端观测
  println(
    "[4] invariant(alpha)=\{a.invariant()} invariant(beta)=\{b.invariant()} peer_count(beta)=\{b.peer_count()}",
  )
  println("== 演示结束 ==")
}
