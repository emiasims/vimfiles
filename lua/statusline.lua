local function buf_info()
  local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local info = mia.bufinfo(bufnr)
  local desc, title, hl = info.desc, info.name, info.hl
  return desc, title:gsub('%%', '%%%%'), hl
end

local function peek()
  ---@diagnostic disable
  local res
  if type(_G.peek) == 'function' then
    res = _G.peek()
  elseif type(_G.peek) == 'table' then
    res = vim.inspect(_G.peek):gsub('\n', ' ')
  elseif _G.peek ~= nil then
    res = vim.inspect(_G.peek)
  end
  return res or ''
  ---@diagnostic enable
end

local function cursor_info()
  local digits = math.ceil(math.log10(vim.fn.line('$') + 1))
  local width = '%' .. digits .. '.' .. digits
  return '%2p%% ☰ ' .. ('%sl/%sL '):format(width, width) .. ': %02c'
end

local function clickable_node(node)
  local sr, sc, er, ec = node:range()
  return function(_, _, mouse, _)
    if mouse == 'l' then
      local cmd = ('%dG%d|v%dG%d|'):format(sr + 1, sc + 1, er + 1, ec)
      vim.cmd.normal({ cmd, bang = true })
    elseif mouse == 'r' then
      local cmd = ('%dG%d|'):format(sr + 1, sc + 1)
      vim.cmd.normal({ cmd, bang = true })
      vim.treesitter.inspect_tree({})
    else
      mia.warn('No action for mouse click: ' .. mouse)
    end
  end
end

local function node_tree()
  if not mia.treesitter.has_parser() then
    return '🚫🌴'
  end

  local node = vim.treesitter.get_node({ ignore_injections = false })
  local spec = {}
  while node do
    table.insert(spec, {
      node:type(),
      on_click = clickable_node(node),
    })
    node = node:parent()
  end

  if #spec > 0 then
    spec = vim.iter(spec):rev():totable()
    spec.sep = '➜'
    return spec
  end
  return ''
end

local function definition()
  local mode = mia.line.mode_info()
  local desc, title, title_hl = buf_info()
  return {
    { mode.abbrev, hl = mode.hl, pad = true },
    { desc, hl = 'stlDescription', pad = true },
    { title, hl = title_hl, pad = true },
    { '%m', hl = 'stlModified' },
    { mia.spinner.status(5), hl = 'Added', pad = true },
    { peek, hl = 'stlErrorInfo', pad = true },
    { '%=%<' },
    { node_tree, hl = 'stlNodeTree' },
    { ' %y ', hl = 'stlTypeInfo' },
    { cursor_info, hl = mode.hl, pad = true },
  }
end

function _G.statusline()
  return mia.line.render(definition, 'statusline')
end
vim.go.statusline = '%!v:lua.statusline()'
vim.go.laststatus = 3

return {
  buf_info = buf_info,
  peek = peek,
  cursor_info = cursor_info,
  node_tree = node_tree,
  definition = _G.statusline,
}
