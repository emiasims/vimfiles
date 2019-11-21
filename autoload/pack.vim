function! s:setup() abort
  packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', {'type' : 'opt'})

  call minpac#add('jeetsukumaran/vim-pythonsense')
  call minpac#add('Vimjas/vim-python-pep8-indent')
  call minpac#add('vim-jp/syntax-vim-ex')

  call minpac#add('tpope/vim-repeat')
  call minpac#add('tpope/vim-fugitive')
  call minpac#add('tpope/vim-surround')
  call minpac#add('tpope/vim-commentary')
  call minpac#add('tpope/vim-speeddating')
  call minpac#add('tpope/vim-obsession')
  call minpac#add('tpope/vim-scriptease', {'type' : 'opt'})
  call minpac#add('andymass/vim-matchup')
  call minpac#add('tommcdo/vim-exchange')

  call minpac#add('machakann/vim-highlightedyank')
  call minpac#add('itchyny/vim-cursorword')
  call minpac#add('christoomey/vim-tmux-navigator')
  call minpac#add('jeetsukumaran/vim-filebeagle')
  call minpac#add('junegunn/fzf.vim')  " Slow?
  call minpac#add('tommcdo/vim-lion')
  call minpac#add('junegunn/vader.vim')

  call minpac#add('justinmk/vim-sneak')
  call minpac#add('wellle/targets.vim')

  call minpac#add('inkarkat/vim-SyntaxRange')
  call minpac#add('mbbill/undotree')
  call minpac#add('chrisbra/unicode.vim')

  " Nvim specific:
  call minpac#add('neoclide/coc.nvim', {'type': 'opt', 'branch': 'release'})
  call minpac#add('neoclide/jsonc.vim', {'type' : 'opt'})
  call minpac#add('mhinz/vim-signify', {'type' : 'opt'})  " Slow?
  call minpac#add('ludovicchabant/vim-gutentags', {'type' : 'opt'})
  call minpac#add('SirVer/ultisnips')

endfunction



let s:coc_packages = [
      \ 'coc-python', 'coc-vimlsp', 'coc-lists', 'coc-ultisnips',
      \ 'coc-calc', 'coc-word', 'coc-sh', 'coc-json']

function! pack#coc_install(...) abort
  for l:cp in s:coc_packages
    execute (a:0 > 0 ? "CocUninstall " : "CocInstall ") . l:cp
  endfor
endfunction

function! pack#update() abort
  call s:setup()
  call minpac#update('', {'do' : 'call minpac#status() | call pack#coc_install()'})
endfunction

function! pack#clean() abort
  call s:setup()
  call minpac#clean()
endfunction

function! pack#status() abort
  call s:setup()
  call minpac#status()
endfunction
