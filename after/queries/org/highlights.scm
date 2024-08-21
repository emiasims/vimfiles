; extends

; TODO on query file SOURCE
; for each buffers of the appropriate filetype
; setfiletype?

(headline (stars) @_stars (#match? @_stars "^(\\*{3})*\\*$") (item) @identifier)
(headline (stars) @_stars (#match? @_stars "^(\\*{3})*\\*\\*$") (item) @function)
(headline (stars) @_stars (#match? @_stars "^(\\*{3})*\\*\\*\\*$") (item) @special)

; (item . (_) @text.todo (#eq? @text.todo "TODO"))
; (item . (_) @text.todo.checked (#eq? @text.todo.checked "DONE"))

(stars sub: _ @conceal (#set! conceal "-"))
(stars final: _ @error (#set! conceal "❤")) ; U+2764 U+2765

(item . (_) @todo (#eq? @todo "GOAL") (#set! "priority" 105))
(item . (_) @bold (#eq? @bold "CANCELLED") (#set! "priority" 105)) @text.strike @comment

; (body (_ (_ (checkbox) (_)* . contents: (paragraph [(str)(num)(sym)] @text ) contents: (_ (_ (checkbox)))) ))

(listitem contents: (paragraph [(sym)(str)(num)]+ @tag . (sym ":") @special . (sym ":" prev: "sym" !next) @special))
; U+2713 U+2717
(listitem (checkbox (status) @text.todo.checked (#eq? @text.todo.checked "/") (#set! conceal "✓")) . contents: (paragraph) @dark)
(listitem (checkbox (status) @error (#eq? @error "X") (#set! conceal "✗")) . contents: (paragraph) @comment @text.strike)
(listitem (checkbox (status) @todo (#eq? @todo "-")) . contents: (paragraph [(str)(sym)(num)]+ @typedef))
(listitem contents: (paragraph [(sym)(str)(num)]+ @tag . (sym ":") @special . (sym ":" prev: "sym" !next) @special))

(body (paragraph (sym ":").(nl).) . (list (listitem (bullet) @boldconst (#eq? @boldconst "-") (#set! conceal "⤷")) ))

((paragraph . (sym "-")) @comment (#lua-match? @comment "^%-%-%-%-%-+$"))

; (paragraph (sym "[") . (sym "[")  (sym "]") . (sym "]"))
