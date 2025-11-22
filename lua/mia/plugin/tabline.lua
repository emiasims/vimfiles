local a = vim.api

local hl = mia.line_utils.hl

local function window_layout(layout, names)
  local node_type = layout[1]

  if node_type == 'leaf' then
    return { names[layout[2]], type = 'leaf' }
  end

  -- First do it recursively..
  local it = vim.iter(layout[2]):map(function(_layout)
    return window_layout(_layout, names)
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

local function tab_layout()
  local current_win = a.nvim_get_current_win()
  local current_tab = a.nvim_get_current_tabpage()

  local bufname_counts = { ['init.lua'] = 1 } -- all init.lua gets modified

  for _, buf in ipairs(a.nvim_list_bufs()) do
    local name = vim.fs.basename(vim.fn.bufname(buf))
    bufname_counts[name] = bufname_counts[name] and bufname_counts[name] + 1 or 1
  end

  local tabline = {}
  for _, tabid in ipairs(a.nvim_list_tabpages()) do
    local win_names = {}

    -- First, for this tab get the names as displayed for each window
    for _, winid in ipairs(a.nvim_tabpage_list_wins(tabid)) do
      local buf = vim.fn.winbufnr(winid)
      local name, dir = unpack(mia.bufinfo(buf).tabline)
      name = name or vim.fn.bufname(buf)

      -- if the file buffer is duplicated in name, indicate which with a prefix
      -- init.lua -> mia➔init.lua for example.
      if dir and bufname_counts[name] > 1 then
        name = ('%s➔%s'):format(dir, name)
      end
      name = name:gsub('%%', '%%%%')

      ---@type mia.line.spec
      local spec = { [1] = name }

      -- highlight...
      if tabid == current_tab and winid == current_win then
        spec.hl = 'TabLineWin'
      end

      local _winid = winid -- capture for closure
      spec.on_click = function(_, _, button, _)
        if button == 'l' then
          a.nvim_set_current_win(_winid)
        end
      end

      win_names[winid] = spec
    end

    -- Get a pretty window layout
    local tabnr = a.nvim_tabpage_get_number(tabid)
    local ok, layout = pcall(window_layout, vim.fn.winlayout(tabnr), win_names)
    if not ok then
      layout = { hl('Error', 'Error in g:tabline_err') }
      vim.g.tabline_err = layout[1]
    end

    table.insert(tabline, {
      { ('%%%dT%d'):format(tabnr, tabnr), pad = true },
      layout,
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
    ' ' .. mia.session.status(),
    on_click = function(_, _, button, _)
      if button == 'l' then
        mia.session.pick()
      end
    end,
  }
end

local function macro_status()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('[q:%s]'):format(reg) or nil
end

local function tabline()
  local ok, res = pcall(mia.line_utils.resolve, 'tabline', {
    tab_layout,
    { '%= ', hl = 'TabLineFill' },
    { macro_status, hl = 'TabLineRecording' },
    { '%S ', hl = 'TabLineFill' },
    { session, hl = 'TabLineSession' },
    ' ',
  })
  if not ok then
    return 'Error: ' .. res
  end
  return res
end

vim.o.tabline = '%!v:lua.mia.tabline()'

return setmetatable({
  win_layout = window_layout,
  tab_layout = tab_layout,
  tabline = tabline,
  test = tabline,
}, { __call = tabline })
