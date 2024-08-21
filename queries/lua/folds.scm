; comments get folded into function
((comment)+ @fold (#lua-match? @fold "^%-%-%-"))
[ (function_definition) (function_declaration) ] @fold

; 4 or more lines get folded
; offset prevents folds from running into each other.. why does this happen?
([
  (arguments)
  (parameters)
  (table_constructor)
] @fold (#match? @fold "\n(.*\n){4}") )
; ] @fold (#match? @fold "\n(.*\n){4}") (#offset! @fold 1 0 0 0))
; Module return statements

; very long statements get folded
([
 (do_statement)
 (while_statement)
 (repeat_statement)
 (if_statement)
 (for_statement)
] @fold (#vim-match? @fold "\n(.*\n){10}"))

