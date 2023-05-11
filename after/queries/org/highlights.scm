; extends

(stars sub: _ @conceal (#set! conceal "-"))
(stars final: _ @error (#set! conceal "❤")) ; U+2764 U+2765

(item . (_) @todo (#eq? @todo "GOAL"))
(item . (_) @bold (#eq? @bold "CANCELLED")) @text.strike @comment

; U+2713 U+2717
(listitem (checkbox (status) @string (#eq? @string "/") (#set! conceal "✓")) . contents: (paragraph) @text.strike)
(listitem (checkbox (status) @error (#eq? @error "X") (#set! conceal "✗")) . contents: (paragraph) @comment)
(listitem (checkbox (status) @todo (#eq? @todo "-")) . contents: (paragraph [(str)(sym)(num)]+ @typedef))
(listitem contents: (paragraph [(sym)(str)(num)]+ @tag . (sym ":") @special . (sym ":" prev: "sym" !next) @special))
