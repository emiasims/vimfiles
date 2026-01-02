;; extends

(string [ "\"" "'" "[[" ] @comment  [ "\"" "'" "]]" ] @comment)

((identifier) @module.builtin
  (#any-of? @module.builtin "vim"  "mia" "P" "N" "P1" "T" "put" "keys" "values")
  (#not-has-parent? @module.builtin field))

(dot_index_expression
  table: (identifier) @_G (#eq? @_G "_G")
  field: (identifier) @module.builtin (#set! priority 150))
