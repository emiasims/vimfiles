;; extends
;(function_call (identifier) @_name (#eq? @_name "set_query") (arguments . (string) @language (#offset! @language 0 1 0 -1) (string) @content . ))
;(function_call name: (_) @_func (#match? @_func "pyeval$") (arguments (string) @python (#match? @python "^\\[\\[") (#offset! @python 0 2 0 -2)))
;(function_call name: (_) @_func (#match? @_func "pyeval$") (arguments (string) @python (#match? @python "^[\"']") (#offset! @python 0 1 0 -1)))

((function_call
  name: (_) @_mia_augrp
  arguments: (arguments
    (table_constructor
      (field
        name: (_)
        value: [
                (string content: _ @injection.content)
                (table_constructor (field !name value: (string content: _ @injection.content)))
                (table_constructor (field !name value: (table_constructor (field !name value: (string content: _ @injection.content)))))
                ]))))
  (#set! injection.language "vim")
  (#eq? @_mia_augrp "mia.augroup"))

; ((function_call
;   name: (_) @_vimcmd_identifier
;   arguments: (arguments
;     (string
;       content: _ @injection.content)))
;   (#set! injection.language "vim")
;   (#any-of? @_vimcmd_identifier
;     "vim.cmd" "vim.api.nvim_command" "vim.api.nvim_command" "vim.api.nvim_exec2"))
