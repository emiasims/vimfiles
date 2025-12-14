local api = vim.api

local function attach(winid)
  winid = winid or api.nvim_get_current_win()
  if not (winid and api.nvim_win_is_valid(winid)) then
    return
  end
  local buf = api.nvim_win_get_buf(winid)
  if not buf then
    return
  end
  vim.wo[winid].winbar = '%!v:lua.winbar()'
  vim.b[buf].winbar_attached = true
end

do -- setup treesitter window context updates

  local ctx_level = { '⠂', '⠢', '⠦', '⠶', '⠷', '⢷', '⣷', '⣿' }

  local function update_window_context(winid)
    local ctx_ranges = require('treesitter-context.context').get(winid) or {}
    local topline = vim.fn.line('w0', winid) - 1
    while #ctx_ranges > 0 and ctx_ranges[#ctx_ranges][1] >= topline do
      table.remove(ctx_ranges)
    end
    if #ctx_ranges == 0 then
      vim.w[winid].winbar_ctx = nil
      return
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local row = ctx_ranges[#ctx_ranges][1]

    -- set up statuscolumn first
    local statuscolumn = api.nvim_eval_statusline(vim.wo[winid].statuscolumn, {
      winid = winid,
      use_statuscol_lnum = row + 1,
      highlights = true,
    })
    local ctx = {}
    local hls = statuscolumn.highlights
    local sc_str = statuscolumn.str
    for i = 2, #hls do
      local _sc, _ec = hls[i - 1].start, hls[i].start
      table.insert(ctx, { text = sc_str:sub(_sc + 1, _ec), hl = hls[i - 1].group })
    end
    table.insert(ctx, { text = sc_str:sub(hls[#hls].start + 1), hl = hls[#hls].group })

    -- add clickable context indicator
    if ctx[1] and vim.startswith(ctx[1].text, '  ') then
      local text = ctx[1].text:match('^  ( *%d* )')
      ctx[1].text = ctx[1].text:sub(#text + 3)

      local indicator = ctx_level[math.min(#ctx_ranges, #ctx_level)]
      table.insert(ctx, 1, {
        text = '' .. indicator .. text,
        hl = ctx[1].hl,
        on_click = function() mia.warn('NYI') end,
      })
    end

    -- add highlighted context
    vim.iter(mia.highlight.extract(bufnr, row + 1)):each(function(chunk)
      table.insert(ctx, { text = chunk[1], hl = chunk[2] })
    end)

    vim.w[winid].winbar_ctx = ctx
  end

  local scheduled = {}
  local schedule_update = vim.schedule_wrap(function(winid)
    if scheduled[winid] then
      return
    end
    scheduled[winid] = true
    vim.schedule(function()
      scheduled[winid] = nil
      if not api.nvim_win_is_valid(winid) then
        return
      end
      -- super simple throttling
      local last_time = vim.w[winid].winbar_last_update or 0
      if vim.uv.now() - last_time >= 10 then
        vim.w[winid].winbar_last_update = vim.uv.now()
        update_window_context(winid)
        api.nvim__redraw({ win = winid, winbar = true })
      end
    end)
  end)

  --- @param ev vim.api.keyset.create_autocmd.callback_args
  local function update_context(ev)
    if vim.b[ev.buf].winbar_attached then
      vim.iter(vim.fn.win_findbuf(ev.buf)):each(schedule_update)
    end
  end

  local function au_attach(ev)
    vim.wo.winbar = ''
    if
      not api.nvim_win_get_config(0).zindex -- Not a floating window
      and vim.bo[ev.buf].buftype == '' -- Normal buffer
      and api.nvim_buf_get_name(ev.buf) ~= '' -- Has a file name
      and not vim.wo[0].diff -- Not in diff mode
    then
      attach()
    end
  end

  mia.augroup('mia.winbar', {
    BufWinEnter = au_attach,
    WinScrolled = update_context,
    BufEnter = update_context,
    VimResized = update_context,
    CursorMoved = update_context,
    WinResized = update_context,
    WinEnter = update_context,
    OptionSet = {
      { pattern = '*number', callback = update_context },
      { pattern = 'buftype', callback = au_attach }
    },
  })
end

local function treesitter_context()
  local ctx = vim.w[vim.g.statusline_winid or api.nvim_get_current_win()].winbar_ctx
  if not ctx then
    return ''
  end
  return vim
    .iter(ctx)
    :map(function(item)
      local hl = item.hl
      if type(hl) == 'table' then
        hl = hl[#hl]
      end
      return { item.text, hl = hl, on_click = item.on_click }
    end)
    :totable()
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
    ' ',
  }
end

function _G.winbar()
  return mia.line.render(definition, 'winbar')
end

return {
  context = treesitter_context,
  bufinfo = bufinfo,
  definition = _G.winbar,
  attach = attach,
}
