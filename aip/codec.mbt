// AIP wire JSON 编解码（手写，wire 契约显式受控；E3 错误分型统一 Envelope）

///|
pub fn AgentIdentity::to_json(self : AgentIdentity) -> Json {
  let registered_at_json = match self.registered_at {
    Some(t) => Json::number(t.to_double())
    None => Json::null()
  }
  {
    "aic": Json(self.aic),
    "identity_status": Json(self.identity_status.to_wire()),
    "cai_ref": Json(self.cai_ref),
    "registered_at": registered_at_json,
  }
}

///|
pub fn AgentIdentity::from_json(j : Json) -> AgentIdentity raise AipError {
  guard j is { "aic": String(aic), "identity_status": String(status_wire), .. } else {
    raise Envelope("agent_identity: missing aic/identity_status")
  }
  guard IdentityStatus::from_wire(status_wire) is Some(status) else {
    raise Envelope("agent_identity: bad identity_status \{status_wire}")
  }
  let cai_ref : String? = if j is { "cai_ref": String(c), .. } {
    Some(c)
  } else {
    None
  }
  let registered_at : Int64? = if j is { "registered_at": Number(t, ..), .. } {
    Some(t.to_int64())
  } else {
    None
  }
  { aic, identity_status: status, cai_ref, registered_at, }
}

///|
pub fn AgentCapabilitySet::to_json(self : AgentCapabilitySet) -> Json {
  {
    "capabilities": Json(self.capabilities),
    "default_input_types": Json(self.default_input_types),
    "default_output_types": Json(self.default_output_types),
  }
}

///|
pub fn AgentCapabilitySet::from_json(
  j : Json,
) -> AgentCapabilitySet raise AipError {
  {
    capabilities: json_string_array_opt(j, "capabilities"),
    default_input_types: json_string_array_opt(j, "default_input_types"),
    default_output_types: json_string_array_opt(j, "default_output_types"),
  }
}

///|
pub fn AgentNode::to_json(self : AgentNode) -> Json {
  {
    "urn": Json(self.urn),
    "display_name": Json(self.display_name),
    "identity": self.identity.to_json(),
    "acs": self.acs.to_json(),
    "discoverable": Json(self.discoverable),
    "endpoint": Json(self.endpoint),
  }
}

///|
pub fn AgentNode::from_json(j : Json) -> AgentNode raise AipError {
  guard j
    is {
      "urn": String(urn),
      "display_name": String(display_name),
      "identity": identity_j,
      "acs": acs_j,
      "discoverable": discoverable_j,
      ..
    } else {
    raise Envelope("agent_node: missing required fields")
  }
  let identity = AgentIdentity::from_json(identity_j)
  let acs = AgentCapabilitySet::from_json(acs_j)
  let discoverable : Bool = match discoverable_j {
    True => true
    False => false
    _ => raise Envelope("agent_node: discoverable must be boolean")
  }
  let endpoint : String? = if j is { "endpoint": String(e), .. } {
    Some(e)
  } else {
    None
  }
  { urn, display_name, identity, acs, discoverable, endpoint, }
}

///|
pub fn AipEnvelope::to_json(self : AipEnvelope) -> Json {
  {
    "envelope_version": Json(self.envelope_version),
    "protocol": Json(protocol_name()),
    "sender_urn": Json(self.sender_urn),
    "recipient_urn": Json(self.recipient_urn),
    "seq": Json::number(self.seq.to_double()),
    "timestamp": Json::number(self.timestamp.to_double()),
    "kind": Json(self.kind.to_wire()),
    "payload": self.payload,
  }
}

///|
pub fn AipEnvelope::from_json(j : Json) -> AipEnvelope raise AipError {
  guard j
    is {
      "envelope_version": String(ver),
      "sender_urn": String(sender),
      "recipient_urn": String(recipient),
      "seq": Number(seq, ..),
      "timestamp": Number(ts, ..),
      "kind": String(kind_wire),
      "payload": payload,
      ..
    } else {
    raise Envelope("envelope: missing required fields")
  }
  guard ver == envelope_version() else {
    raise Envelope("envelope: unsupported version \{ver}")
  }
  guard j is { "protocol": String(p), .. } else {
    raise Envelope("envelope: missing protocol field")
  }
  guard p == protocol_name() else {
    raise Envelope("envelope: wrong protocol \{p}")
  }
  guard MessageKind::from_wire(kind_wire) is Some(kind) else {
    raise Envelope("envelope: bad kind \{kind_wire}")
  }
  {
    envelope_version: ver,
    sender_urn: sender,
    recipient_urn: recipient,
    seq: seq.to_int64(),
    timestamp: ts.to_int64(),
    kind,
    payload,
  }
}

///|
pub fn DiscoverRequest::to_json(self : DiscoverRequest) -> Json {
  {
    "requester_urn": Json(self.requester_urn),
    "filter_capabilities": Json(self.filter_capabilities),
  }
}

///|
pub fn DiscoverRequest::from_json(j : Json) -> DiscoverRequest raise AipError {
  guard j is { "requester_urn": String(u), .. } else {
    raise Envelope("discover_request: missing requester_urn")
  }
  {
    requester_urn: u,
    filter_capabilities: json_string_array_opt(j, "filter_capabilities"),
  }
}

///|
pub fn DiscoverResponse::to_json(self : DiscoverResponse) -> Json {
  let items : Array[Json] = []
  for node in self.nodes {
    items.push(node.to_json())
  }
  { "nodes": Json::array(items) }
}

///|
pub fn DiscoverResponse::from_json(j : Json) -> DiscoverResponse raise AipError {
  guard j is { "nodes": Array(items), .. } else {
    raise Envelope("discover_response: missing nodes array")
  }
  let nodes : Array[AgentNode] = []
  for item in items {
    nodes.push(AgentNode::from_json(item))
  }
  { nodes, }
}

///|
pub fn RegisterRequest::to_json(self : RegisterRequest) -> Json {
  { "node": self.node.to_json() }
}

///|
pub fn RegisterRequest::from_json(j : Json) -> RegisterRequest raise AipError {
  guard j is { "node": node_j, .. } else {
    raise Envelope("register_request: missing node")
  }
  { node: AgentNode::from_json(node_j), }
}

///|
pub fn RegisterResponse::to_json(self : RegisterResponse) -> Json {
  {
    "accepted": Json(self.accepted),
    "aic": Json(self.aic),
    "reason": Json(self.reason),
  }
}

///|
pub fn RegisterResponse::from_json(j : Json) -> RegisterResponse raise AipError {
  guard j is { "accepted": accepted_j, .. } else {
    raise Envelope("register_response: missing accepted")
  }
  let accepted : Bool = match accepted_j {
    True => true
    False => false
    _ => raise Envelope("register_response: accepted must be boolean")
  }
  let aic : String? = if j is { "aic": String(a), .. } { Some(a) } else { None }
  let reason : String? = if j is { "reason": String(r), .. } {
    Some(r)
  } else {
    None
  }
  { accepted, aic, reason, }
}

///|
pub fn CapabilityRequest::to_json(self : CapabilityRequest) -> Json {
  {
    "requester_urn": Json(self.requester_urn),
    "target_urn": Json(self.target_urn),
  }
}

///|
pub fn CapabilityRequest::from_json(
  j : Json,
) -> CapabilityRequest raise AipError {
  guard j is { "requester_urn": String(req), "target_urn": String(tgt), .. } else {
    raise Envelope("capability_request: missing urns")
  }
  { requester_urn: req, target_urn: tgt, }
}

///|
fn json_string_array_opt(
  j : Json,
  key : String,
) -> Array[String] raise AipError {
  match j {
    Object(fields) =>
      match fields.get(key) {
        Some(Array(items)) => {
          let out : Array[String] = []
          for item in items {
            match item {
              String(s) => out.push(s)
              _ => raise Envelope("\{key}: expected string elements")
            }
          }
          out
        }
        Some(_) => raise Envelope("\{key}: expected array")
        None => []
      }
    _ => raise Envelope("expected json object")
  }
}
