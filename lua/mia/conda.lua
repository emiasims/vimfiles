if not os.getenv 'CONDA_PREFIX' then
  vim.api.nvim_echo({ { "conda env 'nvim-base' not found", 'Error' } }, true, {})
else
  _G._conda = {}
  _conda.env = os.getenv 'CONDA_PREFIX'
  _conda.base = _conda.env:gsub('(/miniconda3)/.*$', "%1") .. '/envs/nvim-base'
  _conda.hostprg = _conda.base .. '/bin/python'
  vim.g.python3_host_prog = _conda.hostprg
end
