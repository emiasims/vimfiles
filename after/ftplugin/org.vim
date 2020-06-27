setlocal colorcolumn=100
setlocal spell
let b:cursorword = 0
setlocal foldminlines=0

command! -buffer -nargs=0 ToNote call org#refile('notebox.org')
