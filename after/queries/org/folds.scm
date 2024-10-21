(document (body) @fold (#trim! @fold))

; (document (section) @fold)

; the last section in subsections gets trimmed
; ((section) @fold . (section) (#has-parent? @fold section))
; (section (section)* . (section) @fold . (#trim! @fold))

(section
  (headline)? @fold
  (plan)? @fold
  (property_drawer)? @fold
  (body)? @fold)


(property_drawer . (property)) @fold
(drawer (contents)) @fold
(block name: (_) @_name (#eq? @_name "fold") (contents)) @fold
