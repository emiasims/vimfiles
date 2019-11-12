" Vim syntax file to complement the default (as of update date) with folding.
" Language:	Python
" Author:	Matt Simmons <matt.simmons@compbiol.org>
" Updated:	2019 Nov 12
" Description:
" Fold up to two lines underneath a function or class definition
" Class methods should eat ALL whitespace to the next method, but
" zero lines if it is the last method defined. The subsequent two
" empty lines (or all whitespace) belong to the class fold.
" Note that this will not work properly with multiple decorators.
"
" This setup lines up well with black formatting. edit foldtext
" to show both function/class name and decoration!

" Remove any of these if already defined. Statement & string are in vim runtime
silent! syntax clear pythonString
silent! syntax clear pythonStatement
silent! syntax clear pythonFunctionFold
silent! syntax clear pythonMethodFold
silent! syntax clear pythonClassFold
silent! syntax clear pythonCommentFold
silent! syntax clear pythonDocString

" pythonStatement conflicts with the folding. Specifically:
" syn keyword pythonStatement	class def nextgroup=pythonFunction skipwhite
syn keyword pythonStatement	False None True
syn keyword pythonStatement	as assert break continue del exec global
syn keyword pythonStatement	lambda nonlocal pass print return with yield
syn keyword pythonStatement class def contained nextgroup=pythonFunction skipwhite
      \ containedin=pythonFunctionFold,pythonMethodFold,pythonClassFold

syntax region pythonFunctionFold	start="^\%(@.\+\ndef\|\%(@.\+\n\)\@80<!def\)\>"
      \ end="\%(\s*\n\)\{2,3}\ze\%(\s*\n\)*[^)[:space:]]" fold transparent

" start=Decorator, start=no decorator, end=another method, end=class indent
syntax region pythonMethodFold	start="^\(\z(\s\+\)\)@.\+\n\1def\>" fold transparent
      \ start="\%(@.\+\n\)\@80<!\_^\z(\s\+\)def\>"
      \ end="\n\%(\s*\n\)\+\ze\%(\z1\s\@![^)]\)"
      \ end="\n\ze\%(\%(\s*\n\)*\%(\z1\)\@![^)]\)"
      \ containedin=pythonClassFold

syntax region pythonClassFold	start="\%(@.\+\n\)\@80<!\_^\z(\s*\)class\>" fold transparent
      \ start="^\(\z(\s*\)\)\%(@.\+\n\1class\)\>"
      \ end="\%(\s*\n\)\{2,3}\ze\%(\%(\s*\n\)*\%(\z1\s\)\@!.\)"

" TODO works for methods but not unindented classes and functions
syntax region pythonCommentFold start="^\z(\s*\)#\s*\%(def\|class\).*\n\s*"
      \ end='^\ze\%(\s*\n\)*\s*[^#[:space:]]' fold transparent

" strings
syntax region pythonString		start=/\v[uUf]?\z("|')/ end=/\z1/ skip=/\\\\\|\\'/ contains=pythonEscape,@Spell
syntax region pythonDocString		start=/\v[uU]?\z("""|''')/ end=/\z1/ fold contains=pythonEscape,@Spell

hi def link pythonString String
hi def link pythonDocString Comment
" hi def link pythonStatement

syntax sync fromstart
let b:current_syntax = "python"
