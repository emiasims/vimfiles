vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use { 'wbthomason/packer.nvim', opt = true}

  use 'ludovicchabant/vim-gutentags'
  use 'SirVer/ultisnips'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'nvim-treesitter/playground'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  use 'hrsh7th/nvim-cmp'
  use 'onsails/lspkind-nvim'
  use 'neovim/nvim-lspconfig'
  use 'wbthomason/lsp-status.nvim'

  -- vim-vsnip (snippets)
  -- lsp_signature.nvim (automatically pop up signature window, note signature_help is built-into core, just manually triggered)

  use 'JuliaEditorSupport/julia-vim'

  use 'kristijanhusak/orgmode.nvim'
  use 'rktjmp/lush.nvim'

end)
