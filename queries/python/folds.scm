; top level function and class definitions
(module
  [
    (decorated_definition definition: (_ (block)))
    (function_definition (block))
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

(class_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
(function_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
