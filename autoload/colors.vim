function! colors#fromlush(name) abort " {{{1
  " TODO use runtimepath
  let cname = fnamemodify($MYVIMRC, ':h') . '/colors/' . a:name . '.vim'
  if !has('nvim') || getftime(fnamemodify($MYVIMRC, ':h') . '/lua/' . a:name . '/init.lua') <= getftime(cname)
    execute 'colorscheme' a:name
    return
  endif
  let lines = luaeval('require("lush").compile(require("' . a:name . '"), {force_clean = true})')
  " Remove incompatible with vim option
  call map(lines, 'substitute(v:val, ''\s\?blend\s*=\s*\S*'', "", "")')
  call writefile(lines, cname)
  execute 'colorscheme' a:name
endfunction
