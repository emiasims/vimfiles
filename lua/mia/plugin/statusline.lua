local stl
stl = setmetatable({
  winid = function()
    return vim.g.statusline_winid or vim.api.nvim_get_current_win()
  end,
  bufnr = function()
    return vim.api.nvim_win_get_buf(stl.winid())
  end,
  full_bufname = function()
    return vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(stl.winid()))
  end,
  bufname = function()
    return vim.fn.bufname(vim.api.nvim_win_get_buf(stl.winid()))
  end,
  timer = nil
}, {
  __index = function(t, name)
    if name == 'bo' then
      return vim.bo[t.bufnr()]
    elseif name == 'wo' then
      return vim.wo[t.winid()]
    end
  end,
})

local HOME = '^' .. vim.pesc(vim.env.HOME)

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

local function hl(text, group, skip_close)
  if not group or not text or text == '' then
    return text and ' ' .. text .. ' ' or ''
  end
  return ('%%#%s# %s %s'):format(group, text, skip_close and '' or '%*')
end

local function term_info()
  local bvs = vim.b[stl.bufnr()]
  local desc = bvs.stl_desc
  if not desc then
    desc = stl.bufname():match('^term://.*/%d+:(.*)$')
  end
  return {
    title = bvs.stl_title or bvs.term_title or '',
    desc = desc or stl.bufname(),
  }
end

local function file_info()
  local desc
  local file = vim.fs.basename(stl.full_bufname())

  if stl.bo.filetype ~= 'help' and stl.bo.buftype ~= 'nofile' then
    if stl.full_bufname():match('^fugitive') then
      file = vim.fn['fugitive#Object'](stl.full_bufname())
    elseif vim.g.loaded_fugitive and stl.bo.modifiable then
      -- git info
      local branch = vim.fn.FugitiveHead(1, stl.bufnr())
      branch = branch ~= '' and ('(%s)'):format(branch) or nil

      if branch then
        desc = branch .. vim.fn.fnamemodify(stl.bufname(), ':h') .. '/'
      else
        -- no git info, just show the directory
        -- desc = vim.fn.getcwd() .. '/'
        desc = vim.fn.getcwd() .. '/'
        file = stl.bufname()
      end
    end
  end
  return { desc = desc or '', title = file }
end

local function buf_info()
  if stl.bo.buftype == 'nofile' then
    return { desc = stl.bufname(), title = '' }
  end
  local info = stl.bo.buftype == 'terminal' and term_info() or file_info()
  return { desc = info.desc, title = ' ' .. info.title:gsub(' ', '␣'):gsub('%%', '%%%%') }
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

local function macro()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('[q:%s]'):format(reg)
end

local function error_info()
  if _G.stl_noerr then ---@diagnostic disable-line: undefined-field
    return
  end
end

local function cursor_info()
  local digits = math.ceil(math.log10(vim.fn.line('$') + 1))
  local width = '%' .. digits .. '.' .. digits
  return '%2p%% ☰ ' .. ('%sl/%sL '):format(width, width) .. ': %02c'
end

local function encoding()
  local digits = math.ceil(math.log10(vim.fn.line('$') + 1))
  local typeinfo = (' %s[%s]'):format(stl.bo.fileencoding, stl.bo.fileformat)
  return typeinfo .. (' '):rep(14 + 2 * digits - #typeinfo)
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
  local col = vim.str_byteindex(line, vim.fn.getmousepos().screencol)
  -- there shouldn't be newlines in the statusline
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

-- priority wrapper?
-- maxwidth wrapper
-- click wrapper - exports automatically
-- deferred? needs to get width from rest of stl?
-- width that deals with laststatus

local function active()
  local ok, res = pcall(function()
    local mode = mode_info()
    local info = buf_info()
    -- local w = vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(stl.winid())
    -- w = w - #info.desc - #info.title
    -- local dir, fname = dir_info(), filename()
    return table.concat({
      hl(mode.abbrev, mode.color),
      hl(info.desc:gsub(HOME, '~'), 'stlDescription'),
      info.title,
      hl('%m', 'stlModified'),
      hl(mia.spinner.status(5), 'Added'),
      peek(),
      '%=%#stlNodeTree#',
      node_tree(),
      -- hl(node_tree(), 'stlNodeTree'),
      hl(error_info(), 'stlErrorInfo'),
      hl('%y', 'stlTypeInfo'),
      hl(cursor_info(), mode.color),
    })
  end)
  if not ok then
    return 'Error: ' .. res
  end
  return res
end

local function inactive()
  local info = buf_info()
  return table.concat({ hl(' ', 'SignColumn'), info.desc, info.title, '%m %=%y', encoding() }, ' ')
end

vim.go.statusline = '%!v:lua.mia.statusline()'
vim.go.laststatus = 3

return setmetatable({
  active = active,
  inactive = inactive,
  stl = stl,
  inspect = inspect,
}, { __call = active })
