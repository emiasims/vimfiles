if not os.getenv 'CONDA_PREFIX' then
  vim.api.nvim_echo({ { "conda env 'nvim-base' not found", 'Error' } }, true, {})
else
  vim.g.python3_host_prog = (
    (os.getenv 'CONDA_PREFIX_1' or os.getenv 'CONDA_PREFIX')
    .. '/envs/nvim-base/bin/python')
end
