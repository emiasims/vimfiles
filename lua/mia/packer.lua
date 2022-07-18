vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  use 'ludovicchabant/vim-gutentags'
  -- use "SirVer/ultisnips"

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/playground'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  -- use 'hrsh7th/vim-vsnip'
  -- use 'hrsh7th/cmp-vsnip'

  use 'L3MON4D3/LuaSnip'

  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lsp-document-symbol'
  use 'tamago324/cmp-zsh'

  use 'onsails/lspkind-nvim'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  use 'wbthomason/lsp-status.nvim'

  -- lsp_signature.nvim (automatically pop up signature window, note signature_help is built-into core, just manually triggered)

  use 'JuliaEditorSupport/julia-vim'

  use 'rktjmp/lush.nvim'

end)
