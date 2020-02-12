call SyntaxRange#Include('^```\s*sh\s*', '^```$', 'sh', 'Identifier')
call SyntaxRange#Include('^```\s*vim\s*', '^```', 'vim', 'Identifier')

let b:syntax_markdown_loaded = 1
if !exists('b:syntax_python_loaded')
  call SyntaxRange#Include('^```\s*python\s*', '^```', 'python', 'Identifier')
endif
