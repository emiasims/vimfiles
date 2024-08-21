; extends

(pair key: (string (string_content) @field) @dark)

((identifier) @constant
  (#lua-match? @constant "^_+[A-Z][A-Z_0-9]*$"))
