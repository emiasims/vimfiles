; extends

; (stars sub: _ @special)
(stars sub: _ @conceal (#set! "conceal" "-"))

(item . (_) @todo (#eq? @todo "GOAL"))
(item . (_) @bold (#eq? @bold "CANCELLED")) @text.strike @comment
