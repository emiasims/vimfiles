packadd minpac

call minpac#init()
call minpac#add('k-takata/minpac', #{type : 'opt'})

call minpac#add('jeetsukumaran/vim-pythonsense')
call minpac#add('Vimjas/vim-python-pep8-indent')
call minpac#add('vim-jp/syntax-vim-ex')
call minpac#add('dag/vim-fish')
call minpac#add('jelera/vim-javascript-syntax')

call minpac#add('tpope/vim-repeat')
call minpac#add('tpope/vim-fugitive')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-commentary')
call minpac#add('tpope/vim-speeddating')
call minpac#add('tpope/vim-obsession')
call minpac#add('tpope/vim-scriptease')
call minpac#add('tommcdo/vim-exchange')
call minpac#add('justinmk/vim-sneak')
call minpac#add('wellle/targets.vim')
call minpac#add('tommcdo/vim-lion')

call minpac#add('machakann/vim-highlightedyank')
call minpac#add('itchyny/vim-cursorword')
" call minpac#add('christoomey/vim-tmux-navigator')
call minpac#add('jeetsukumaran/vim-filebeagle')

call minpac#add('inkarkat/vim-SyntaxRange')
call minpac#add('mbbill/undotree')

" Nvim specific:
call minpac#add('glacambre/firenvim', #{type: 'opt', do: 'packadd firenvim|call firenvim#install()' })
call minpac#add('mhinz/vim-signify', #{type : 'opt'})  " Slow?
call minpac#add('ludovicchabant/vim-gutentags', #{type : 'opt'})
call minpac#add('SirVer/ultisnips', #{type : 'opt'})
call minpac#add('nvim-treesitter/nvim-treesitter', #{type : 'opt', do: 'TSUpdate'})
call minpac#add('nvim-treesitter/playground', #{type : 'opt'})

call minpac#add('nvim-lua/popup.nvim', #{type: 'opt'})
call minpac#add('nvim-lua/plenary.nvim', #{type: 'opt'})
call minpac#add('nvim-telescope/telescope.nvim', #{type: 'opt'})

call minpac#add('hrsh7th/nvim-compe', #{type : 'opt'})

call minpac#add('git@github.com:milisims/vim-org.git', #{depth: 0})
call minpac#add('git@github.com:milisims/vim-org-notebox.git', #{depth: 0})
call minpac#add('git@github.com:milisims/contextualize.vim.git', #{depth: 0})
call minpac#add('git@github.com:milisims/nvim-luaref.git', #{depth: 0})

call minpac#add('rktjmp/lush.nvim')

function! pack#update() abort
  call minpac#update('', #{do : 'call minpac#status()'})
endfunction

function! pack#clean() abort
  call minpac#clean()
endfunction

function! pack#status() abort
  call minpac#status()
endfunction

function! pack#list(...) abort
  return join(sort(keys(minpac#getpluglist())), "\n")
endfunction

function! pack#open(qargs) abort
  call util#openf(minpac#getpluginfo(a:qargs).url)
endfunction
