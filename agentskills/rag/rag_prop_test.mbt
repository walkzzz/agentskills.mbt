// rag 包属性测试（quickcheck，seed 固定可复现；RRF 融合的数学性质）。

///|
test "property: single ranking preserves order and strictly decreases" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let len = (n & 15) + 1
      let rk : Array[String] = Array::makei(len.to_int(), i => {
        "d" + i.to_string()
      })
      let fused = @rag.rrf_fuse([rk], k=60)
      if fused.length() != len.to_int() {
        return false
      }
      let mut i = 0
      while i < fused.length() {
        if fused[i].doc_id != rk[i] {
          return false
        }
        i = i + 1
      }
      let mut j = 1
      while j < fused.length() {
        if fused[j - 1].score <= fused[j].score {
          return false
        }
        j = j + 1
      }
      true
    },
    count=60,
    seed=2031,
  )
}

///|
test "property: fusion covers the union of all rankings exactly once" {
  @quickcheck.check(
    fn(n : Int32) -> Bool {
      let la = (n & 3) + 1
      let lb = ((n >> 2) & 3) + 1
      let a : Array[String] = Array::makei(la.to_int(), i => "a" + i.to_string())
      let b : Array[String] = Array::makei(lb.to_int(), i => "b" + i.to_string())
      let fused = @rag.rrf_fuse([a, b], k=60)
      // 两路 doc_id 不重叠 → 融合后数量精确等于各部分之和（无丢失、无重复）
      fused.length() == (la + lb).to_int()
    },
    count=60,
    seed=2032,
  )
}
