// GB/Z 185.2/185.4/185.5 数据模型：智能体身份（AIC/CAI）、能力描述（ACS）、节点（ADP）

///|
#derive(Eq, Debug)
pub(all) enum IdentityStatus {
  NoIdentity
  Active
  Locked
  Revoked
}

///|
pub extend IdentityStatus with Eq::{equal, not_equal}

///|
pub extend IdentityStatus with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub fn IdentityStatus::to_wire(self : IdentityStatus) -> String {
  match self {
    NoIdentity => "none"
    Active => "active"
    Locked => "locked"
    Revoked => "revoked"
  }
}

///|
pub fn IdentityStatus::from_wire(s : String) -> IdentityStatus? {
  match s {
    "none" => Some(NoIdentity)
    "active" => Some(Active)
    "locked" => Some(Locked)
    "revoked" => Some(Revoked)
    _ => None
  }
}

///|
#derive(Eq, Debug)
pub(all) struct AgentIdentity {
  aic : String
  identity_status : IdentityStatus
  cai_ref : String?
  registered_at : Int64?
}

///|
pub extend AgentIdentity with Eq::{equal, not_equal}

///|
pub extend AgentIdentity with @moonbitlang/core/debug.Debug::{to_repr}

///|
#derive(Eq, Debug)
pub(all) struct AgentCapabilitySet {
  capabilities : Array[String]
  default_input_types : Array[String]
  default_output_types : Array[String]
}

///|
pub extend AgentCapabilitySet with Eq::{equal, not_equal}

///|
pub extend AgentCapabilitySet with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub fn AgentCapabilitySet::empty() -> AgentCapabilitySet {
  { capabilities: [], default_input_types: [], default_output_types: [], }
}

///|
#derive(Eq, Debug)
pub(all) struct AgentNode {
  urn : String
  display_name : String
  identity : AgentIdentity
  acs : AgentCapabilitySet
  discoverable : Bool
  endpoint : String?
}

///|
pub extend AgentNode with Eq::{equal, not_equal}

///|
pub extend AgentNode with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub fn AgentNode::from_frontmatter(
  urn : String,
  display_name : String,
  identity_status : IdentityStatus,
  discoverable : Bool,
  capabilities : Array[String],
  default_input_types : Array[String],
  default_output_types : Array[String],
) -> AgentNode {
  {
    urn,
    display_name,
    identity: { aic: "", identity_status, cai_ref: None, registered_at: None, },
    acs: { capabilities, default_input_types, default_output_types, },
    discoverable,
    endpoint: None,
  }
}
