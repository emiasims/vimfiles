;; extends

(string [ "\"" "'" "[[" ] @comment  [ "\"" "'" "]]" ] @comment)

((identifier) @module.builtin
  (#any-of? @module.builtin "mia" "vim"))

(dot_index_expression
  table: (identifier) @_G (#eq? @_G "_G")
  field: (identifier) @module.builtin)
