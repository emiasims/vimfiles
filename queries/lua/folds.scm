(function_declaration) @fold
(table_constructor (field (function_definition) @fold))
; fold top level tables with functions
(chunk (variable_declaration (assignment_statement (expression_list (table_constructor (field (function_definition))) @fold))))
