; (document (body) @fold)
; (section) @fold
(document [(body)(section)] @fold)
(section (section) @fold (section) . ) ; trim the nl?
; ((section (section) @fold . ) (#trim-nls! @fold))
((section (section) @fold . ) (#trim! @fold))

(property_drawer . (property)) @fold
(drawer (contents)) @fold
(block name: (_) @_name (#eq? @_name "fold") (contents)) @fold


; (body (_ (_ (checkbox) (_)* contents: (_ (_ (checkbox)))) @fold))
