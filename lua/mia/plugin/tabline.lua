local a = vim.api

local function hl(group, text)
  if not text then
    return '%#' .. group .. '#'
  end
  return ('%%#%s#%s%%*'):format(group, text or '')
end


local function window_layout(win_names, tabid)
  local current_win = a.nvim_get_current_win()
  local current_tab = a.nvim_get_current_tabpage()
  local is_current_tab = (tabid == current_tab)

  local tabnr = a.nvim_tabpage_get_number(tabid)
  local winlayout = vim.fn.winlayout(tabnr)

  -- 1. Build the post-order stack (This part is unchanged)
  local traversal = {} -- Traversal stack
  local ordered = {}   -- Post-order node stack

  table.insert(traversal, winlayout)
  while #traversal > 0 do
    local node = table.remove(traversal)
    table.insert(ordered, node)

    if node[1] ~= 'leaf' then
      for i = 1, #node[2] do
        table.insert(traversal, node[2][i])
      end
    end
  end

  -- 2. Process nodes and build results
  local results = {}

  while #ordered > 0 do
    local node = table.remove(ordered)
    local node_type = node[1]

    if node_type == 'leaf' then
      local name = win_names[node[2]]

      if is_current_tab and node[2] == current_win then
        name = hl('TabLineWin', name)
      elseif is_current_tab then
        name = hl('TabLinesel', name)
      end

      -- Instead of a `str` field, we use an `items` table
      table.insert(results, { items = { name }, type = 'leaf' })
    else
      -- Branching node: combine children with separators
      local sep_char = (node_type == 'row') and '|' or '/'
      local num_children = #node[2]

      local child_results = {}
      for _ = 1, num_children do
        table.insert(child_results, 1, table.remove(results))
      end

      local items = vim.deepcopy(child_results[1].items)

      for i = 2, num_children do
        local prev_res = child_results[i - 1] --[[@as table]]
        local curr_res = child_results[i]

        local sep = sep_char

        if prev_res.type ~= 'leaf' and prev_res.type ~= node_type then
          sep = ' ' .. sep
        end

        if curr_res.type ~= 'leaf' and curr_res.type ~= node_type then
          sep = sep .. ' '
        end

        table.insert(items, sep)
        for _, item in ipairs(curr_res.items) do
          table.insert(items, item)
        end
      end

      table.insert(results, { items = items, type = node_type })
    end
  end

  local label = tostring(tabnr)
  if is_current_tab then
    label = hl('TabLineSel', label)
  end

  return ' ' .. label .. ' ' .. table.concat(results[#results].items, '')
end

local function tab_layout()
  local bufname_counts = { ['init.lua'] = 1 } -- all init.lua gets modified

  for _, buf in ipairs(a.nvim_list_bufs()) do
    local name = vim.fs.basename(vim.fn.bufname(buf))
    bufname_counts[name] = bufname_counts[name] and bufname_counts[name] + 1 or 1
  end

  local tabline = {}
  for _, tabid in ipairs(a.nvim_list_tabpages()) do
    local win_names = {}
    for _, winid in ipairs(a.nvim_tabpage_list_wins(tabid)) do
      -- Get the names of each window
      local buf = vim.fn.winbufnr(winid)
      local name, dir = mia.bufinfo.tabline(buf)
      name = name or vim.fn.bufname(buf)

      if dir and bufname_counts[name] > 1 then
        name = ('%s➔%s'):format(dir, name)
      end
      win_names[winid] = name
    end

    table.insert(tabline, window_layout(win_names, tabid))
  end

  return table.concat(tabline, ' %*')
end

local function session()
  return vim.g.session and mia.session.status() or nil
end

local function macro_status()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('[q:%s]'):format(reg)
end

local function tabline()
  local ok, res = pcall(function()
    return table.concat({
      tab_layout(),
      hl('TabLineFill', '%= '),
      hl('TabLineRecording', macro_status()),
      hl('TabLineFill', '%S '),
      hl('TabLineSession', session()),
      ' %*',
    })
  end)
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
}, { __call = tabline })
