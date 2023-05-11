; top level function and class definitions
(module
  [
    (decorated_definition (function_definition (block)))
    (function_definition (block))
    (decorated_definition (class_definition (block)))
    (class_definition (block))
  ] @fold
)
(class_definition
  (block
    [
     (decorated_definition (function_definition (block)))
     (function_definition (block))
    ] @fold
  )
)

; docstrings
; (class_definition body: (block . (expression_statement . (string) @fold)))
; (function_definition body: (block . (expression_statement . (string) @fold)))

(class_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
(function_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
