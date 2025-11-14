local modecolors = {
  n = { color = 'stlNormalMode', abbrev = 'n' },
  i = { color = 'stlInsertMode', abbrev = 'i' },
  v = { color = 'stlVisualMode', abbrev = 'v' },
  V = { color = 'stlVisualMode', abbrev = 'V' },
  [''] = { color = 'stlVisualMode', abbrev = 'B' },
  R = { color = 'stlReplaceMode', abbrev = 'R' },
  s = { color = 'stlSelectMode', abbrev = 's' },
  S = { color = 'stlSelectMode', abbrev = 'S' },
  [''] = { color = 'stlSelectMode', abbrev = 'S' },
  c = { color = 'stlTerminalMode', abbrev = 'c' },
  t = { color = 'stlTerminalMode', abbrev = 't' },
  ['-'] = { color = 'stlNormalMode', abbrev = '-' },
  ['!'] = { color = 'stlNormalMode', abbrev = '!' },
}

local function mode_info()
  return modecolors[vim.api.nvim_get_mode().mode:sub(1, 1)] or { color = 'stlNormalMode', abbrev = '-' }
end

local function buf_info()
  local winid = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local bufnr = vim.api.nvim_win_get_buf(winid)
  local desc, title = unpack(mia.bufinfo(bufnr).statusline)
  return desc, title:gsub('%%', '%%%%')
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

local function node_tree()
  if not mia.treesitter.has_parser() then
    return '🚫🌴'
  end
  local nodes = table.concat(vim.iter(mia.treesitter.nodelist_atcurs()):rev():totable(), '➜')
  return '%@v:lua.mia.statusline.inspect@%<%(' .. nodes .. '%)%X'
end

local function inspect(...)
  local line = vim.api.nvim_eval_statusline(mia.statusline(), {}).str:gsub('➜', '\n')
  local col = vim.str_byteindex(line, 'utf-8', vim.fn.getmousepos().screencol)
  local node_ix = #line:sub(col):gsub('[^\n]', '')

  -- get matching clicked node
  -- left click selects the node
  -- right click inspects highlighting that node

  local node = vim.treesitter.get_node({ ignore_injections = false }) --[[@as TSNode]]
  for _ = 1, node_ix do
    node = node:parent() --[[@as TSNode]]
  end
  local sr, sc, er, ec = node:range()

  local mouse = select(3, ...) -- :h 'stl' , see @ execute function label
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

local function spacer(text, skipnil)
  if text then
    return ' ' .. text .. ' '
  end
  return skipnil and '' or ' '
end

local function hl(group, text)
  if not group or not text or text == '' then
    return text and ' ' .. text .. ' ' or ''
  end
  return ('%%#%s#%s%%*'):format(group, text)
end

local function active()
  local ok, res = pcall(function()
    local mode = mode_info()
    local desc, title = buf_info()
    return table.concat({
      hl(mode.color, spacer(mode.abbrev)),
      hl('stlDescription', spacer(desc)),
      spacer(title), -- StatusLine is default
      hl('stlModified', '%m'),
      hl('Added', spacer(mia.spinner.status(5), true)),
      hl('stlErrorInfo', spacer(peek(), true)),
      '%=',
      hl('stlNodeTree', node_tree()),
      hl('stlTypeInfo', ' %y '),
      hl(mode.color, spacer(cursor_info())),
    })
  end)
  if not ok then
    return 'Error: ' .. res
  end
  return res
end

vim.go.statusline = '%!v:lua.mia.statusline()'
vim.go.laststatus = 3

return setmetatable({
  buf_info = buf_info,
  active = active,
  inspect = inspect,
}, { __call = active })
