local gid = nvim.create_augroup('mia-src', { clear = true })
local disabled = { vim = true, lua = true }

nvim.create_autocmd('FileType', {
  group = gid,
  desc = 'Set up a blocking source cmd for filetypes',
  callback = function(ev)
    local filetype = ev.match
    local extension = vim.fn.expand '<afile>:e'
    if vim.o.buftype == '' and vim.o.modifiable and extension ~= '' and not disabled[filetype] then
      nvim.create_autocmd('SourceCmd', {
        group = gid,
        desc = 'Block source cmd',
        pattern = '*.' .. extension,
        command = ('echoerr "Unable to source filetype: %s"'):format(filetype),
      })
      disabled[filetype] = true
    end
  end,
})

nvim.create_autocmd('SourceCmd', {
  group = gid,
  pattern = '*.lua',
  desc = 'Reload lua full module, lazy config, or source lua file',
  callback = function(ev)
    require 'mia.source'.reload_lua_module(ev.match)
  end,
})
