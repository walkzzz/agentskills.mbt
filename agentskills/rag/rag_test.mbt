///|
test {
  let idx = @rag.RagIndex::new()
  idx.add("d1", "MoonBit is a new programming language for AI agents")
  idx.add("d2", "智能体互联协议国家标准 GB/Z 185")
  idx.add("d3", "RAG retrieval augmented generation")
  assert_eq(idx.count(), 3)
  let hits = idx.search("MoonBit programming", top_k=2)
  assert_true(hits.length() > 0)
  // MoonRetrieve 对长文分块，doc_id 带 #chunk 后缀——前缀匹配容错
  assert_true(hits[0].doc_id.has_prefix("d1"))
}

///|
test {
  // RRF 手工期望：A=[a,b,c]、B=[b,c,a] → b 双路靠前，必居首
  let fused = @rag.rrf_fuse([["a", "b", "c"], ["b", "c", "a"]], k=60)
  assert_eq(fused.length(), 3)
  assert_eq(fused[0].doc_id, "b")
  assert_true(fused[0].score > fused[1].score)
  assert_true(fused[1].score > fused[2].score)
}

///|
test {
  assert_eq(@rag.rrf_fuse([]).length(), 0)
  assert_eq(@rag.rrf_fuse([[]]).length(), 0)
  let single = @rag.rrf_fuse([["x", "y"]], k=60)
  assert_eq(single[0].doc_id, "x")
  assert_eq(single[1].doc_id, "y")
}
