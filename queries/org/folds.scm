(
  [
    (document [(body)(section)] @fold)
    (property_drawer . (property)) @fold
    (drawer (contents)) @fold
    (section (section) @fold (section) . )
    (block name: (_) @_name (#eq? @_name "fold") (contents)) @fold
  ]
 (#offset! @fold 0 0 -1 0)
)

((section (section) @fold . ) (#offset! @fold 0 0 -1 0) (#trim-nls! @fold))
