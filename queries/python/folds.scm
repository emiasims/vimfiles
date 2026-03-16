(decorated_definition) @fold
([
  (function_definition)
  (class_definition)
] @fold (#not-has-parent? @fold decorated_definition))

(class_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))
(function_definition (block . (expression_statement . (string) @fold (#match? @fold "^\"\"\""))))

(if_statement (comparison_operator (identifier) @_name (#eq? @_name "__name__") (string (string_content) @_main (#eq? @_main "__main__")))) @fold
