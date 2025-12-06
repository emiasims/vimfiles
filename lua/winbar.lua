local M = {}

-- TODO:
-- chunks vs spec

local api = vim.api

local function update_window_context(winid)
  local ctx_ranges = require('treesitter-context.context').get(winid)
  local topline = vim.fn.line('w0', winid) - 1
  if ctx_ranges and ctx_ranges[#ctx_ranges] and ctx_ranges[#ctx_ranges][1] == topline then
    table.remove(ctx_ranges)
  end
  if not ctx_ranges or #ctx_ranges == 0 then
    vim.w[winid].winbar_ctx = nil
    return
  end

  local bufnr = api.nvim_win_get_buf(winid)
  local sr, sc, er, ec = unpack(ctx_ranges[#ctx_ranges])

  -- set up signcolumn first
  local signcolumn = api.nvim_eval_statusline(vim.wo[winid].statuscolumn, {
    winid = winid,
    use_statuscol_lnum = sr + 1,
    highlights = true,
  })
  local chunks = {}
  local hls = signcolumn.highlights
  local sc_str = signcolumn.str
  for i = 2, #hls do
    local _sc, _ec = hls[i - 1].start, hls[i].start
    table.insert(chunks, { sc_str:sub(_sc + 1, _ec), hls[i - 1].group })
  end
  table.insert(chunks, { sc_str:sub(hls[#hls].start + 1), hls[#hls].group })
  if chunks[1] and vim.startswith(chunks[1][1], ' ') then
    chunks[1][1] = '' .. chunks[1][1]:sub(2)
  end

  vim.list_extend(chunks, mia.highlight.extract(bufnr, sr + 1, sc, er + 1, ec)[1])

  vim.w[winid].winbar_ctx = chunks
end

M.update = function(winid)
  -- super simple throttling
  local last_time = vim.w[winid].winbar_last_update or 0
  if vim.uv.now() - last_time >= 10 then
    vim.w[winid].winbar_last_update = vim.uv.now()
    update_window_context(winid)
  end
end

local function treesitter_context()
  local ctx = vim.w[vim.g.statusline_winid or api.nvim_get_current_win()].winbar_ctx
  if not ctx then
    return ''
  end
  local spec = {}
  for _, chunk in ipairs(ctx) do
    local hl = chunk[2]
    if type(hl) == 'table' then
      local ix = #hl
      while not mia.highlight.exists(hl[ix]) and ix > 0 do
        ix = ix - 1
      end
      hl = hl[ix]
    end
    table.insert(spec, { chunk[1], hl = hl })
  end
  return spec
end

local function bufinfo()
  local buf = api.nvim_win_get_buf(vim.g.statusline_winid or api.nvim_get_current_win())
  local info = mia.bufinfo(buf)
  if not info then
    return
  end
  return info.cwd .. '/' .. info.name
end

local function definition()
  return {
    treesitter_context,
    '%=',
    { bufinfo, hl = 'Comment' },
  }
end

local function winbar()
  local ok, res = pcall(mia.line.resolve, 'winbar', definition, true)
  if ok then
    return res
  else
    mia.err_once(res)
  end
end
_G.winbar = winbar

local function attach(ev)
  if
    not api.nvim_win_get_config(0).zindex -- Not a floating window
    and vim.bo[ev.buf].buftype == '' -- Normal buffer
    and api.nvim_buf_get_name(ev.buf) ~= '' -- Has a file name
    and not vim.wo[0].diff -- Not in diff mode
    then
      vim.wo.winbar = "%!v:lua.winbar()"
      vim.b.winbar_attached = true
    end
  end

--- @param ev vim.api.keyset.create_autocmd.callback_args
local function update_context(ev)
  if ev.event == 'OptionSet' and ev.match ~= 'number' and ev.match ~= 'relativenumber' then
    return
  end
  if vim.b[ev.buf].winbar_attached then
    local wins = vim.fn.win_findbuf(ev.buf)
    for _, win in ipairs(wins) do
      M.update(win)
    end
  end
end

mia.augroup('mia.winbar', {
  BufWinEnter = attach,
  WinScrolled = update_context,
  BufEnter = update_context,
  WinEnter = update_context,
  VimResized = update_context,
  CursorMoved = update_context,
  OptionSet = update_context,
  WinResized = update_context,
})

return M
