if not vim.env.CONDA_PREFIX then
  vim.api.nvim_echo({ { "conda env 'nvim-base' not found", 'Error' } }, true, {})
else
  local prefix = vim.env.CONDA_PREFIX:gsub('(/miniconda3)/.*$', '%1')

  _G._conda = {
    env = vim.env.CONDA_PREFIX,
    base = prefix .. '/envs/nvim-base',
    hostprg = prefix .. '/envs/nvim-base/bin/python',
  }
  local basebin = _conda.base .. '/bin'
  if vim.env.CONDA_DEFAULT_ENV ~= 'nvim-base' and not vim.env.PATH:find(basebin, 1, true) then
    vim.env.PATH = basebin .. ':' .. vim.env.PATH
  end
  vim.g.python3_host_prog = _conda.hostprg
end
