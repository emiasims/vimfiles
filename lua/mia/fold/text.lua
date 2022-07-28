local a = vim.api
local ts = vim.treesitter
local ns = vim.api.nvim_create_namespace('mia-foldtext')

local foldtext = { _default_group = 'Folded' }
local langs


local is_foldclosed = {}
setmetatable(is_foldclosed, {
  __call = function()
    return vim.fn.foldclosed(is_foldclosed.lnum) == is_foldclosed.lnum
  end,
})

local function on_win(_, winid, bufnr, top, bot)
  local ft = a.nvim_buf_get_option(bufnr, 'filetype')
  local has_parser, parser = pcall(ts.get_parser, bufnr)
  if not has_parser or not ft or not langs[ft] then
    return
  end
  local root = parser:parse()[1]:root()
  for lnum = top, bot do
    is_foldclosed.lnum = lnum + 1
    if a.nvim_win_call(winid, is_foldclosed) then
      local success, text = pcall(langs[ft], bufnr, lnum, root)
      if success and text then
        pcall(
          a.nvim_buf_set_extmark,
          bufnr,
          ns,
          lnum,
          0,
          { ephemeral = true, virt_text_pos = 'overlay', virt_text = text, hl_mode = 'combine' }
        )
      elseif not success then
        vim.notify_once(('Foldtext calculation for buf:%s, ft:"%s" failed.'):format(bufnr, ft))
      end
    end
  end
end

local faded = { Folded = 'Folded' }
setmetatable(faded, {
  __index = function(self, name)
    local exists, hl = pcall(a.nvim_get_hl_by_name, name, true)
    if not exists or hl[true] then
      -- seems to be hl[true] when the group is ':hi-clear'ed
      return faded[foldtext._default_group]
    end

    -- For hsl2rgb and back
    -- https://github.com/rktjmp/lush.nvim/blob/main/lua/lush/vivid/hsl/convert.lua
    hl.foreground = require('lush').hsl(string.format('#%0X', hl.foreground)).de(33).da(33) .. ''
    self[name] = 'Folded' .. name
    a.nvim_set_hl(0, self[name], hl)
    return self[name]
  end,
})
foldtext._faded_groups = faded

function foldtext.flatten(captures)
  -- set up cache
  local hls = { foldtext._default_group }
  local hlid = { [foldtext._default_group] = 1 }
  for _, t in ipairs(captures) do
    if not hlid[t[3]] then
      hlid[t[3]] = #hls + 1
      hls[#hls+1] = t[3]
    end
  end

  local chars = {}
  local s, e, hl, id
  local max = 0

  -- get the characters
  for c_ix = #captures, 1, -1 do
    s, e, hl = unpack(captures[c_ix])
    s = s + 1
    id = hlid[hl]
    max = max < e and e or max
    for i = s, e do
      if not chars[i] then
        chars[i] = id
      end
    end
  end

  -- fill the gaps
  for i = 1, max do
    if not chars[i] then
      chars[i] = 1  -- default id
    end
  end

  -- local s, e, id (above)
  local text_groups = {}
  local i = 1
  while chars[i] do
    s, e = i, i
    id = chars[i]
    while chars[i] and id == chars[i] do
      i = i + 1
      e = i
    end
    text_groups[#text_groups+1] = {s, e, hls[id]}
  end

  return text_groups
end

function foldtext.from_query(buf, lnum, root)
  local query = ts.get_query(a.nvim_buf_get_option(buf, 'filetype'), 'highlights')
  local hlmap = ts.highlighter.hl_map
  local line = a.nvim_buf_get_lines(buf, lnum, lnum+1, false)[1]

  local startrow, startcol, endrow, endcol
  local captures = {}
  local hl
  for id, node, _ in query:iter_captures(root, buf, lnum, lnum+1) do
    startrow, startcol, endrow, endcol = node:range()
    if lnum == startrow and lnum == endrow then
      hl = query.captures[id]
      if hlmap[hl] and hlmap[hl] ~= '__notfound' then
        hl = hlmap[hl]
      end
      captures[#captures+1] = { startcol, endcol, hl }
    end
  end

  local text = foldtext.flatten(captures)
  for i = 1, #text do
    text[i] = { line:sub(text[i][1], text[i][2]-1), faded[text[i][3]] }
  end

  return text
end

function foldtext.optfunc()
  local line = a.nvim_buf_get_lines(0, vim.v.foldstart - 1, vim.v.foldstart, false)[1]
  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, string.rep('|', vim.v.foldlevel))
  local pad = a.nvim_win_get_width(0)
    - vim.o.foldcolumn
    - (vim.o.number and 1 or 0) * vim.o.numberwidth
    - #line
    - #suffix
    - 9 -- ' ... ' and some other correction
  return ('%s ... %s %s '):format(line, string.rep(' ', pad), suffix)
end

function foldtext.enable()
  if foldtext._enabled then
    return
  end
  langs = langs or require('mia.fold.langs')
  a.nvim_set_decoration_provider(ns, { on_win = on_win })
  foldtext._enabled = true
end

function foldtext.disable()
  a.nvim_set_decoration_provider(ns, {})
  foldtext._enabled = nil
end

function foldtext.toggle()
  if foldtext._enabled then
    foldtext.disable()
  else
    foldtext.enable()
  end
end

vim.api.nvim_create_user_command('FoldHlEnable', foldtext.enable, {})
vim.api.nvim_create_user_command('FoldHlDisable', foldtext.disable, {})
vim.api.nvim_create_user_command('FoldHlToggle', foldtext.toggle, {})

-- TODO set_buf for use in ftplugins
-- Use one global and otherwise buffer local things it

return foldtext
