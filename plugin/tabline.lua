local function get_text(tree, prev, id2name)
  -- to be called with vim.fn.winlayout, '', and set up from Tabline
  if tree[1] == 'row' then
    local text = {}
    for _, subtree in ipairs(tree[2]) do
      text[#text + 1] = get_text(subtree, 'row', id2name)
    end
    local txt = table.concat(text, '|')
    if prev ~= 'row' then
      return ' ' .. txt .. ' '
    end
    return txt

  elseif tree[1] == 'col' then
    local text = {}
    for _, subtree in ipairs(tree[2]) do
      text[#text + 1] = get_text(subtree, 'col', id2name)
    end
    local txt = table.concat(text, '/')
    if prev ~= 'col' then
      return ' ' .. txt .. ' '
    end
    return txt
  end

  -- leaf. Haven't seen the error, but just in case..
  return id2name[tree[2]] or '%#Error#[Confused]%#Tabline#'
end

function Tabline()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local current_win = vim.api.nvim_get_current_win()
  local win_info = {}
  local id2name = {}
  local counts = { ['init.lua'] = 1 } -- all init.lua gets modified

  -- setup
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
      local name = vim.split(vim.fn.fnamemodify(vim.fn.bufname(vim.fn.winbufnr(winid)), ':p'), '/')
      local short = name[#name]
      win_info[winid] = { name = short, dir = name[#name - 1] }
      -- counts[short] = counts[short] and counts[short] + 1 or 1
      if tabnr == current_tab then
        win_info[winid].color = winid == current_win and "%#TabLineWin#" or "%#TabLineSel#"
      end
    end
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.fn.fnamemodify(vim.fn.bufname(buf), ':t')
    counts[name] = counts[name] and counts[name] + 1 or 1
  end
  counts[""] = 0 -- don't try to modify unnamed buffers


  -- add name modifications. Duplicates, scratch, colors
  for id, info in pairs(win_info) do
    if counts[info.name] > 1 and info.dir then
      info.name = ('%s➔%s'):format(info.dir, info.name)
    elseif info.name == "" then
      info.name = "[Scratch]"
    end
    if info.color then
      info.name = info.color .. info.name .. "%#TabLine#"
    end
    id2name[id] = info.name
  end

  -- construct tabline from layout
  local text = {}
  for tabnr, tabid in ipairs(vim.api.nvim_list_tabpages()) do
    if tabid == current_tab then
      text[#text + 1] = '%#TabLineSelNumber#%' .. tabnr .. 'T ' .. tabnr .. " %#TabLine#"
    else
      text[#text + 1] = '%#TabLineNumber#%' .. tabnr .. 'T ' .. tabnr .. " %#TabLine#"
    end
    text[#text + 1] = get_text(vim.fn.winlayout(tabnr), '', id2name)
    text[#text] = vim.fn.substitute(text[#text], '  \\+', ' ', 'g')
    text[#text] = vim.fn.substitute(text[#text], '\\v^ +| +$', '', 'g') .. ' '
  end

  -- return text
  if #vim.api.nvim_list_tabpages() > 1 then
    return table.concat(text, '') .. '%#TabLineFill#%T%=%#TabLineFill#%999XX '
  end
  return table.concat(text, '') .. '%#TabLineFill#%T'

end

vim.o.tabline = "%!v:lua.Tabline()"
