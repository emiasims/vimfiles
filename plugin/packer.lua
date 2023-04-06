vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()

  -- check if $vim/mia_plugins/PLUGNAME exists. If not, clone.
  local function use_local(opts)
    if type(opts) == 'string' then opts = { opts } end
    local name = opts[1]
    local path = ('%s/mia_plugins/%s'):format(vim.fn.stdpath('config'), name)
    opts[1] = path

    if not vim.loop.fs_stat(path) then
      local url = ('git@github.com:milisims/%s.git'):format(name)
      vim.fn.system { 'git', 'clone', url, path }
    end

    use(opts)
  end

  use 'wbthomason/packer.nvim'

  use 'ludovicchabant/vim-gutentags'

  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'nvim-treesitter/playground'
  use 'nvim-treesitter/nvim-treesitter-textobjects'

  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'

  use 'L3MON4D3/LuaSnip'

  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-nvim-lua'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-nvim-lsp-document-symbol'
  use 'tamago324/cmp-zsh'

  use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}

  use 'onsails/lspkind-nvim'
  use 'williamboman/mason.nvim'
  use 'williamboman/mason-lspconfig.nvim'
  use 'neovim/nvim-lspconfig'
  use 'wbthomason/lsp-status.nvim'

  use 'JuliaEditorSupport/julia-vim'

  use 'rktjmp/lush.nvim'

  use 'echasnovski/mini.doc'

  use_local 'contextualize.nvim'
  use_local 'nvim-org'

end)
