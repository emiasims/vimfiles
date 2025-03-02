local cfg = vim.fn.stdpath('config') --[[@as string]]

local M = {
  path = vim.fs.joinpath(cfg, '.venv'),
  bin = vim.fs.joinpath(cfg, '.venv/bin'),
  prog = vim.fs.joinpath(cfg, '.venv/bin/python'),
}

vim.g.python3_host_prog = M.prog

return M
