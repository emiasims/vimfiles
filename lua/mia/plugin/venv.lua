local datapath = vim.fn.stdpath('data') --[[@as string]]

local M = {
  path = vim.fs.joinpath(datapath, 'venv'),
  bin = vim.fs.joinpath(datapath, 'venv/bin'),
  prog = vim.fs.joinpath(datapath, 'venv/bin/python'),
}

vim.g.python3_host_prog = M.prog

return M
