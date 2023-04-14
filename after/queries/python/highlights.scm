; extends

; quotes get darkened
; ((string) @conceal (#match? @conceal "^('[^']|\"[^\"])"))
; ((string) @string (#match? @string "^('[^']|\"[^\"])") (#offset! @string 0 1 0 -1))

(string (string_content) @string) @dark
(pair key: (string (string_content) @field))

