vim.b.update_bufinfo = function(info)
  local title = (info.name == '' or info.name == info.bufname) and 'claude' or info.name
  local dir = vim.fs.basename(info.dir:match('([^/]+)/*$'))
  return {
    type = 'claude',
    name = title,
    tab_name = ('[claude:%s]'):format(dir:upper()),
    dir = dir,
  }
end

vim.keymap.set('t', '<C-z>', '<Nop>', { buffer = true })
