local M = {}

local function is_float(wid)
  return vim.api.nvim_win_get_config(wid).zindex
end

local valid_buf = function(buf)
  buf = buf or 0
  return ({ [''] = true, help = true })[vim.bo[buf].buftype]
end

local config = function(winid, buf)
  local r, c, w = 1, 1, 1
  if buf then
    r = vim.api.nvim_win_get_height(winid)
    c = vim.api.nvim_win_get_width(winid)
    w = vim.b[buf].titlewidth
    if w > c then
      w = c - 1
    end
  end
  return {
    relative = 'win',
    win = winid,
    anchor = 'NE',
    height = 1,
    width = w,
    row = 0, -- r for bottom
    col = c,
    style = 'minimal',
    focusable = false,
    zindex = 50,
    hide = not buf,
  }
end

M.ns = vim.api.nvim_create_namespace('mia-wintitle')
vim.api.nvim_set_hl(M.ns, 'NormalFloat', { link = 'Comment', force = true })

local setup_window = function(id)
  local new_win = vim.api.nvim_open_win(0, false, config(id))
  util.autocmd('WinClosed', {
    pattern = tostring(id),
    callback = util.restore_opt(
      { eventignore = { append = { 'WinClosed', 'WinResized', 'WinNew' } } },
      function()
        pcall(vim.api.nvim_win_close, new_win, true)
      end
    ),
  })
  util.autocmd('WinClosed', {
    pattern = tostring(new_win),
    callback = util.restore_opt(
      { eventignore = { append = { 'WinClosed', 'WinResized', 'WinNew' } } },
      function()
        vim.w[id].titlewin = nil
      end
    ),
  })
  return new_win
end
setup_window =
  util.restore_opt({ eventignore = { append = { 'WinClosed', 'WinResized', 'WinNew' } } }, setup_window)

local function setup_buffer(buf)
  if not valid_buf(buf) then
    return
  end

  local root = vim.fs.root(buf, '.git') or vim.uv.cwd()

  if not vim.b[buf].titlebuf then
    vim.b[buf].titlebuf = vim.api.nvim_create_buf(false, true)
    util.autocmd('BufDelete', {
      pattern = tostring(buf),
      callback = function()
        pcall(vim.api.nvim_buf_delete, vim.b[buf].titlebuf, { force = true })
      end,
    })
    util.autocmd('BufDelete', {
      pattern = tostring(vim.b[buf].titlebuf),
      callback = function()
        vim.b[buf].titlebuf = nil
        vim.b[buf].titlewin = nil
      end,
    })
  end

  local wid = vim.fn.win_getid(vim.fn.winnr())
  local title = vim.api.nvim_eval_statusline(' %f ', { winid = wid, use_winbar = true })
  vim.api.nvim_buf_set_lines(vim.b[buf].titlebuf, 0, -1, false, { title.str })
  vim.b[buf].titlewidth = title.width
end

local function update_window(id)
  local buf = vim.api.nvim_win_get_buf(id)
  if not vim.b[buf].titlebuf then
    return
  end

  vim.w[id].titlewin = vim.w[id].titlewin or setup_window(id)
  if not vim.w[id].titlewin then
    return
  end

  vim.api.nvim_win_set_buf(vim.w[id].titlewin, vim.b[buf].titlebuf)
  vim.api.nvim_win_set_config(vim.w[id].titlewin, config(id, buf))
  vim.api.nvim_win_set_hl_ns(vim.w[id].titlewin, M.ns)
end

local scheduled = {}
local update_tab = function(tab, skip)
  tab = tab or vim.api.nvim_get_current_tabpage()
  if scheduled[tab] then
    return
  end
  scheduled[tab] = true
  vim.schedule(function()
    scheduled[tab] = false
    if vim.api.nvim_tabpage_is_valid(tab) then
      for _, wid in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
        if not is_float(wid) and wid ~= skip then
          pcall(update_window, wid)
        end
      end
    end
  end)
end

M.setup = function()
  if vim.o.winbar == '' then
    M.winbar = M.winbar or '%f'
  else
    M.winbar = M.winbar or vim.o.winbar
    vim.o.winbar = ''
  end

  M.gid = vim.api.nvim_create_augroup('mia-wins', { clear = true })

  util.autocmd('BufWinEnter', {
    group = M.gid,
    callback = function(ev)
      setup_buffer(ev.buf)
    end,
  })

  util.autocmd({ 'BufWinEnter', 'WinNew', 'WinResized', 'WinClosed' }, {
    group = M.gid,
    callback = function(ev)
      if ev.event == 'WinClosed' then
        local skipid = tonumber(ev.match) --[[@as integer]]
        update_tab(vim.api.nvim_win_get_tabpage(skipid), skipid)
      else
        update_tab()
      end
    end,
  })
end

-- maybe tab stuff?

-- project title
-- file relative to project

return M
