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
(class_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
