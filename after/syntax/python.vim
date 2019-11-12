" Vim syntax file to complement the default (as of update date) with folding.
" Language:	Python
" Author:	Matthew Simmons <matt.simmons@compbiol.org>
" Updated:	2019 Nov 12

silent! syntax clear @pythonFolding
silent! syntax clear pythonString pythonDocString

syntax cluster pythonFolding contains=pythonFunctionFold,pythonMethodFold,pythonClassFold,pythonCommentFold,pythonDocString

syntax region pythonFunctionFold	start="^\%(@.\+\ndef\|\%(@.\+\n\)\@80<!def\)\>"
      \ end="\%(\s*\n\)\{2,3}\ze\%(\s*\n\)*[^)[:space:]]" fold transparent

" start=Decorator, start=no decorator, end=another method, end=class indent
syntax region pythonMethodFold	start="^\(\z(\s\+\)\)@.\+\n\1def\>" fold transparent
      \ start="\%(@.\+\n\)\@80<!\_^\z(\s\+\)def\>"
      \ end="\n\%(\s*\n\)\+\ze\%(\z1\s\@![^)]\)"
      \ end="\n\ze\%(\%(\s*\n\)*\%(\z1\)\@![^)]\)"
      " \ end="\%(\s*\n\)\+\ze\%(\z1\s\@![^)]\)"

syntax region pythonClassFold	start="\%(@.\+\n\)\@80<!\_^\z(\s*\)class\>" fold transparent
      \ start="^\(\z(\s*\)\)\%(@.\+\n\1class\)\>"
      \ end="\%(\s*\n\)\{2,3}\ze\%(\%(\s*\n\)*\%(\z1\s\)\@!.\)"

" TODO works for methods but not unindented classes and functions
syntax region pythonCommentFold start="^\z(\s*\)#\s*\%(def\|class\).*\n\s*"
      \ end='^\ze\%(\s*\n\)*\s*[^#[:space:]]' fold transparent

" strings
syntax region pythonString		start=/\v[uUf]?\z("|')/ end=/\z1/ skip=/\\\\\|\\'/ contains=pythonEscape,@Spell
syntax region pythonDocString		start=/\v[uU]?\z("""|''')/ end=/\z1/ fold contains=pythonEscape,@Spell
