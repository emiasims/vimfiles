; extends
(function_call (identifier) @_name (#eq? @_name "set_query") (arguments . (string) @language (#offset! @language 0 1 0 -1) (string) @content . ))
(function_call name: (_) @_func (#match? @_func "pyeval$") (arguments (string) @python (#match? @python "^\\[\\[") (#offset! @python 0 2 0 -2)))
(function_call name: (_) @_func (#match? @_func "pyeval$") (arguments (string) @python (#match? @python "^[\"']") (#offset! @python 0 1 0 -1)))
