vim.env.CFGDIR = (vim.env.XDG_CONFIG_HOME or vim.env.HOME)..'/.config/nvim'
vim.env.DATADIR = (vim.env.XDG_DATA_HOME or vim.env.HOME)..'/.local/share/nvim'
vim.cmd 'runtime settings.vim'

-- v:lua.mia will work and if I :source% a file in mia, it'll update
-- See lua/mia.init.lua
setmetatable(_G, { __index = function(_, k)
  if k == 'mia' then
    return require(k)
  end
end})
