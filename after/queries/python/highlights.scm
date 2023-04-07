; extends

; quotes get darkened
; ((string) @conceal (#match? @conceal "^('[^']|\"[^\"])"))
; ((string) @string (#match? @string "^('[^']|\"[^\"])") (#offset! @string 0 1 0 -1))

; different color for dictionary keys
; wtf why doesn't offset work for highlights? seems useful..
(pair key: (string) @field)
; (pair key: (string) @variable (#set! "range" 0 1 0 -1) (#set! "priority" 110))

