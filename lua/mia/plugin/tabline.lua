local line = mia.line
local a = vim.api

---@alias winlayout {[1]: 'leaf', [2]: number} | {[1]: 'row'|'col', [2]: winlayout[]}
local function _wins(tree, prev, opts)
  if tree[1] == 'leaf' then
    local name = opts.win_info[tree[2]].name:gsub('%%', '%%%%')
    if tree[2] == opts.current.win then
      return line.cfmt(name, 'TabLineWin')
    end
    return name
  end

  local sep = tree[1] == 'row' and '|' or '/'
  if opts.eval.active_tab then
    sep = line.cfmt(sep, 'TabLine') .. line.cfmt(opts.eval.hl)
  end

  local it = vim.iter(tree[2]):map(function(t)
    return _wins(t, tree[1], opts)
  end)

  if prev == tree[1] then
    return table.concat(it:totable(), sep)
  end
  return ' ' .. table.concat(it:totable(), sep) .. ' '
end

---@param opts tabline.opts
local function pretty_windows(opts)
  return {
    _wins(vim.fn.winlayout(opts.eval.nr), nil, opts):gsub('^ +', ''):gsub(' +$', ''):gsub('  +', ' '),
    opts.eval.hl,
  }
end

local function prep()
  local tab_id = a.nvim_get_current_tabpage()
  local tab_nr = a.nvim_tabpage_get_number(tab_id)
  local win_id = a.nvim_get_current_win()
  local win_info = {}
  local bufname_counts = { ['init.lua'] = 1 } -- all init.lua gets modified

  -- setup
  for _, id in ipairs(a.nvim_list_tabpages()) do
    for _, winid in ipairs(a.nvim_tabpage_list_wins(id)) do
      local buf = vim.fn.winbufnr(winid)
      local path = vim.split(vim.fn.fnamemodify(vim.fn.bufname(buf), ':p'), '/')
      win_info[winid] = {
        name = path[#path],
        dir = path[#path - 1],
        buf = buf,
        current = id == tab_id and winid == win_id,
      }
    end
  end

  for _, buf in ipairs(a.nvim_list_bufs()) do
    local name = vim.fn.fnamemodify(vim.fn.bufname(buf), ':t')
    bufname_counts[name] = bufname_counts[name] and bufname_counts[name] + 1 or 1
  end
  bufname_counts[''] = 0 -- don't try to modify unnamed buffers

  -- add name modifications. Duplicates, scratch, colors
  local qf_buf = vim.fn.getqflist({ qfbufnr = true }).qfbufnr
  for _, info in pairs(win_info) do
    if bufname_counts[info.name] > 1 and info.dir then
      info.name = ('%s➔%s'):format(info.dir, info.name)
    elseif vim.bo[info.buf].buftype == 'quickfix' then
      info.name = info.buf == qf_buf and '[qf]' or '[loc]'
    elseif info.name == '' then
      info.name = '[Scratch]'
    end
  end

  ---@type tabline.opts
  return {
    current = { nr = tab_nr, id = tab_id, win = win_id },
    win_info = win_info,
    eval = {},
    color = {},
  }
end

---@class tabline.opts
---@field current {nr: number, id: number, win: number}
---@field win_info table<number, {name: string, dir: string?, current: true?}>
---@field eval {nr: number?, id: number?, hl: string?, active_tab?: boolean}
---@field color {current: string?, copts: string|table<string, any>?}

---@param segments line.segment[]
---@return line.func
local function each_tab(segments, defaults)
  local maps = line.compile(segments)

  return function(opts)
    local t = {}
    for nr, id in ipairs(a.nvim_list_tabpages()) do
      opts.eval = { nr = nr, id = id, active_tab = id == opts.current.id, colors = defaults }
      opts.eval.hl = defaults[opts.eval.active_tab and 'active' or 'inactive']
      local tab = maps(opts)
      tab[1] = '%' .. nr .. 'T' .. tab[1]
      tab[#tab] = tab[#tab] .. '%T'
      vim.list_extend(t, tab)
      if opts.eval.active_tab and nr ~= #a.nvim_list_tabpages() then
        table.insert(t, '%<')
      end
    end
    opts.eval = {}
    return table.concat(t, ' ')
  end
end

---@param opts tabline.opts
local function tabnr(opts)
  return { ' ' .. tostring(opts.eval.nr), opts.eval.hl }
end

local function session()
  return vim.g.session and mia.session.status() or nil
end

local function macro()
  local reg = vim.fn.reg_recording()
  return reg ~= '' and ('[q:%s]'):format(reg)
end

local M = setmetatable({
  prep = prep,
  each_tab = each_tab,
  tabnr = tabnr,
  pretty_windows = pretty_windows,
  macro = macro,
  session = session,
}, {
  __call = function(t)
    if not t.tabline then
      t.setup()
    end
    return t.tabline()
  end,
})

function M.setup()
  M.tabline = line.build( --
    {
      setup = prep,
      each_tab({ --
        tabnr,
        pretty_windows,
      }, { active = 'TabLineSel', inactive = 'TabLine' }),
      { '%=', 'TabLineFill' }, -- separator
      { macro, 'TabLineRecording' },
      { '%S ', 'TabLineFill' }, -- showmsg
      { session, 'TabLineSession' }, -- showmsg
    }
  )

  vim.o.tabline = '%!v:lua.mia.tabline()'
end
M.setup()

return M
