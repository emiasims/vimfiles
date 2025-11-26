local a = vim.api

---@param layout vim.fn.winlayout.ret
---@param win_specs table<number, mia.line.spec>
local function window_layout(layout, win_specs)
  local node_type = layout[1]

  if node_type == 'leaf' then
    return { win_specs[layout[2] --[[@as number]] ], type = 'leaf' }
  end

  -- First do it recursively..
  local it = vim.iter(layout[2]):map(function(_layout)
    return window_layout(_layout, win_specs)
  end)

  -- now join with separator logic:
  -- add padding that separates units within the window layout.
  -- A| B/C indicates A takes the left vsplit, and B and C take the right splits
  -- A|B /C indicates A and B take the top split vertically, and C takes the bottom
  local res = it:fold(it:next(), function(t, node)
    local sep = (node_type == 'row') and '|' or '/'

    if t.type ~= 'leaf' and t.type ~= node_type then
      sep = ' ' .. sep
    end

    if node.type ~= 'leaf' and node.type ~= node_type then
      sep = sep .. ' '
    end

    table.insert(t, sep)
    vim.list_extend(t, node)
    t.type = node.type
    return t
  end)
  res.type = node_type
  return res
end

local clickable_window = function(winid)
  return function(_, _, button, _)
    if button == 'l' then
      a.nvim_set_current_win(winid)
    end
  end
end

local function tab_layout()
  local current_win = a.nvim_get_current_win()
  local current_tab = a.nvim_get_current_tabpage()

  local bufname_counts = { ['init.lua'] = 1 } -- all init.lua gets modified
  for _, buf in ipairs(a.nvim_list_bufs()) do
    local name = vim.fs.basename(vim.fn.bufname(buf))
    bufname_counts[name] = bufname_counts[name] and bufname_counts[name] + 1 or 1
  end

  ---@type mia.line.spec[]
  local tabline = {}
  for _, tabid in ipairs(a.nvim_list_tabpages()) do

    ---@type table<number, mia.line.spec>
    local win_specs = {}

    -- First, for this tab get the names as displayed for each window
    for _, winid in ipairs(a.nvim_tabpage_list_wins(tabid)) do
      local buf = vim.fn.winbufnr(winid)
      local info = mia.bufinfo(buf)
      local name, dir = info.tab_name or info.name, info.tab_hint
      name = name or vim.fn.bufname(buf)

      -- if the file buffer is duplicated in name, indicate which with a prefix
      -- init.lua -> mia➔init.lua for example.
      if dir and bufname_counts[name] > 1 then
        name = ('%s➔%s'):format(dir, name)
      end
      name = name:gsub('%%', '%%%%')

      win_specs[winid] = {
        name,
        hl = winid == current_win and 'TabLineWin' or nil,
        on_click = winid ~= current_win and clickable_window(winid) or nil,
      }

    end

    local tabnr = a.nvim_tabpage_get_number(tabid)

    table.insert(tabline, {
      { ('%%%dT%d'):format(tabnr, tabnr), pad = true },
      window_layout(vim.fn.winlayout(tabnr), win_specs),
      '%T ',
      hl = tabid == current_tab and 'TabLineSel',
    })
  end

  return tabline
end

local function session()
  if not vim.g.session then
    return
  end
  return {
    mia.session.status() .. '  ',
    on_click = function(_, _, button, _)
      if button == 'l' then
        vim.cmd.Pick('sessions')
      end
    end,
  }
end

local function macro_status()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('[q:%s]'):format(reg) or nil
end

local function definition()
  return {
    tab_layout,
    '%=',
    { macro_status, hl = 'TabLineRecording', pad = true },
    { '%S', pad = true },
    { session, hl = 'TabLineSession', pad = true},
  }
end

local function tabline()
  local ok, res = pcall(mia.line_utils.resolve, 'tabline', definition)
  if not ok then
    return 'Error: ' .. res
  end
  return res
end

vim.o.tabline = '%!v:lua.mia.tabline()'

return setmetatable({
  definition = definition,
  win_layout = window_layout,
  tab_layout = tab_layout,
  tabline = tabline,
}, { __call = tabline })
