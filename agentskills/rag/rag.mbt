///|
///RagIndex — 混合检索编排（F04 锚点，ARCH §3.1）。
///
///En: RagIndex orchestrates BM25 retrieval (MoonRetrieve engine) and RRF fusion.
///Kernel 式纯函数域：内部只组合 Engine 的索引/查询语义；IO 与重排注入在运行时壳。
pub struct RagIndex {
  engine : @moonretrieve.Engine
}

///|
pub fn RagIndex::new() -> RagIndex {
  { engine: @moonretrieve.Engine::new(), }
}

///|
///add — 索引一篇文档（doc_id + 正文）。
pub fn RagIndex::add(self : Self, doc_id : String, text : String) -> Unit {
  self.engine.add_document(doc_id, text)
}

///|
///count — 已索引文档数（观测面）。
pub fn RagIndex::count(self : Self) -> Int32 {
  self.engine.count()
}

///|
///is_empty — 是否尚未索引任何文档。
///
///En: is_empty reports whether no document has been indexed.
pub fn RagIndex::is_empty(self : Self) -> Bool {
  self.count() == 0
}

///|
///search — BM25 检索（命中按相关度降序）。
pub fn RagIndex::search(
  self : Self,
  query : String,
  top_k~ : Int32 = 5,
) -> Array[@moonretrieve.SearchResult] {
  self.engine.search(query, top_k~)
}

///|
///RankedHit — RRF 融合结果（doc_id + 融合分）。
///实现 `Compare`：score 降序优先，同分按 doc_id 升序稳定 tie-break（排序逻辑单元化）。
#derive(Eq)
pub(all) struct RankedHit {
  doc_id : String
  score : Double
}

///|
pub extend RankedHit with Eq::{equal, not_equal}

///|
impl Compare for RankedHit with fn compare(self, other) {
  if self.score > other.score {
    -1
  } else if self.score < other.score {
    1
  } else {
    self.doc_id.compare(other.doc_id)
  }
}

///|
pub extend RankedHit with Compare::{compare}

///|
///rrf_fuse — 倒数排名融合（Reciprocal Rank Fusion，k 默认 60 标准值）。
///
///En: rrf_fuse merges multiple ranked doc_id lists — score(d) = Σ_r 1/(k + rank_r(d)).
///多路有序排名合并为单一有序列表（score 降序；同分按 doc_id 升序稳定 tie-break）。
///重排接口（LLM 重排，W7）在此之后经运行时壳注入，不改变本纯函数语义。
pub fn rrf_fuse(
  rankings : Array[Array[String]],
  k~ : Int32 = 60,
) -> Array[RankedHit] {
  let scores : Map[String, Double] = Map::from_array([])
  for ranking in rankings {
    for i, doc_id in ranking {
      let rank = (i + 1).to_double()
      let add = 1.0 / (k.to_double() + rank)
      let prev = match scores.get(doc_id) {
        Some(s) => s
        None => 0.0
      }
      scores[doc_id] = prev + add
    }
  }
  let hits : Array[RankedHit] = []
  for pair in scores {
    let (doc_id, score) = pair
    hits.push({ doc_id, score, })
  }
  hits.sort()
  hits
}

///|
///rrf_fuse_top — 有界返回的 RRF 融合（结果与 rrf_fuse 前缀严格一致）。
///
///En: rrf_fuse_top is a bounded variant of rrf_fuse — the result is exactly the
///prefix of the full fusion. It does not change the ranking semantics; use it to
///avoid materialising callers' downstream copies of the full list.
pub fn rrf_fuse_top(
  rankings : Array[Array[String]],
  k~ : Int32 = 60,
  top_n~ : Int32 = 10,
) -> Array[RankedHit] {
  let all = rrf_fuse(rankings, k~)
  if top_n <= 0 {
    return []
  }
  let limit = if all.length() < top_n { all.length() } else { top_n }
  let out : Array[RankedHit] = []
  for i in 0..<limit {
    out.push(all[i])
  }
  out
}
