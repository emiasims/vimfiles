vim.env.CFGDIR = (vim.env.XDG_CONFIG_HOME or vim.env.HOME)..'/.config/nvim'
vim.env.DATADIR = (vim.env.XDG_DATA_HOME or vim.env.HOME)..'/.local/share/nvim'

if not os.getenv('CONDA_PREFIX') then
  vim.api.nvim_echo({ { "conda env 'nvim-base' not found", 'Error' } }, true, {})
else
  vim.g.python3_host_prog = (
      (os.getenv('CONDA_PREFIX_1') or os.getenv('CONDA_PREFIX'))
          .. '/envs/nvim-base/bin/python')
end


vim.cmd 'runtime settings.vim'

require 'mia'

require 'mia.tslib'
require 'mia.fold'

