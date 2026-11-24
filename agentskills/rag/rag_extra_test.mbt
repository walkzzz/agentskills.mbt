// F04 RRF 有界返回测试（rrf_fuse_top 与全量前缀严格一致 + is_empty）

///|
test "rag index is_empty tracks additions" {
  let index = @rag.RagIndex::new()
  assert_true(index.is_empty())
  index.add("d1", "moonbit skill runtime")
  assert_false(index.is_empty())
  assert_eq(index.count(), 1)
}

///|
test "rrf_fuse_top returns the exact prefix of the full fusion" {
  let rankings : Array[Array[String]] = [["a", "b", "c"], ["b", "c", "d"]]
  let full = @rag.rrf_fuse(rankings, k=60)
  let top2 = @rag.rrf_fuse_top(rankings, k=60, top_n=2)
  assert_eq(top2.length(), 2)
  assert_eq(top2[0].doc_id, full[0].doc_id)
  assert_eq(top2[1].doc_id, full[1].doc_id)
  assert_eq(top2[0].score, full[0].score)
  // top_n 超过总条目数 → 返回全量
  let top_all = @rag.rrf_fuse_top(rankings, k=60, top_n=99)
  assert_eq(top_all.length(), full.length())
  // top_n <= 0 → 空
  assert_eq(@rag.rrf_fuse_top(rankings, k=60, top_n=0).length(), 0)
}
