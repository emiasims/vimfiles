local start_scanner = function(opts)
  local buf = opts.buf
  local ns = opts.ns
  local sr, sc = unpack(opts.pos)

  local mopts = {
    end_row = sr,
    end_col = sc + 1,
    hl_group = opts.hl_group,
    right_gravity = false,
    end_right_gravity = true,
    strict = false,
  }

  local update = function(row, col)
    return vim.api.nvim_buf_set_extmark(buf, ns, row, col, mopts)
  end
  mopts = { id = update(sr, sc), hl_group = opts.hl_group, strict = true }

  opts.speed = math.max(100, opts.speed)
  local speed = opts.speed * opts.dt / 1000

  local scan = function()
    local update_ok = pcall(function()
      local mark = vim.api.nvim_buf_get_extmark_by_id(buf, ns, mopts.id, { details = true })
      local row, col = mark[1], mark[2]
      local _mopts = mark[3] --[[@as vim.api.keyset.extmark_details]]

      local dx = math.random(2, math.ceil(speed * 2 - 2))
      mopts.end_row = _mopts.end_row
      mopts.end_col = _mopts.end_col
      local ok = pcall(update, row, col + dx)
      if not ok then
        update(row + 1, 0)
      end
    end)
    if not update_ok then
      vim.api.nvim_buf_del_extmark(buf, ns, mopts.id)
    end
    return not update_ok
  end

  local timer = assert(vim.uv.new_timer())
  local start = vim.uv.now()
  local cb = function()
    if vim.uv.now() - start >= opts.timeout or scan() then
      pcall(timer.stop, timer)
      pcall(timer.close, timer)
      pcall(vim.api.nvim_buf_del_extmark, buf, ns, mopts.id)
    end
  end

  timer:start(opts.dt, opts.dt, vim.schedule_wrap(cb))
  return mopts.id
end

local M = {}

-- function that prints 10 lines, line by line

---@class mia.RevealOpts
---@field buf? integer
---@field pos? table 0-indexed position
---@field ns? integer extmark namespace
---@field speed? integer characters per second
---@field dt? integer miliseconds default 15
---@field hl_group? string Comment
---@field timeout? integer miliseconds

local function normalize_opts(opts)
  opts = opts or {}
  -- default pos
  if not opts.buf then
    opts.buf = vim.api.nvim_get_current_buf()
    opts.pos = opts.pos or vim.api.nvim_win_get_cursor(0)
    opts.pos[1] = opts.pos[1] - 1
  end
  if opts.buf and not opts.pos then
    local win = vim.fn.bufwinid(opts.buf)
    if win == -1 then
      error('buf not in window')
    end
    opts.pos = vim.api.nvim_win_get_cursor(win)
    opts.pos[1] = opts.pos[1] - 1
  end
  if opts.pos and not opts.buf then
    opts.buf = vim.api.nvim_get_current_buf()
  end

  while opts.pos[1] < 0 do
    opts.pos[1] = vim.api.nvim_buf_line_count(opts.buf) + opts.pos[1]
  end

  local cols = #vim.api.nvim_buf_get_lines(opts.buf, opts.pos[1], opts.pos[1] + 1, false)[1]
  while opts.pos[2] < 0 do
    opts.pos[2] = cols + opts.pos[2] + 1
  end

  return vim.tbl_extend('keep', opts, {
    buf = vim.api.nvim_get_current_buf(),
    ns = vim.api.nvim_create_namespace('mia-reveal'),
    hl_group = 'CommentSansItalic',
    speed = 100,
    dt = 16,
    timeout = 2000,
  })
end

---@param opts mia.RevealOpts
function M.track(opts)
  opts = normalize_opts(opts)
  return start_scanner(opts)
end

---@param text string|string[]
---@param opts mia.RevealOpts
function M.text(text, opts)
  if type(text) == 'string' then
    text = vim.split(text, '\n')
  end
  local timeout = opts and opts.timeout
  opts = normalize_opts(opts)
  if not timeout then
    opts.timeout = #table.concat(text, '\n') / opts.speed * 1000
  end
  start_scanner(opts)
  local sr, sc = unpack(opts.pos)
  vim.api.nvim_buf_set_text(opts.buf, sr, sc, sr, sc, text)
end

return M
