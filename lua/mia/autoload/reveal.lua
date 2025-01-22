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
      local row, col, _mopts =
        unpack(vim.api.nvim_buf_get_extmark_by_id(buf, ns, mopts.id, { details = true }))
      local dx = math.random(2, speed * 2 - 2)
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

  local timer = vim.uv.new_timer()
  local start = vim.uv.now()
  local cb = function()
    if vim.uv.now() - start >= opts.timeout or scan() then
      pcall(timer.stop, timer)
      pcall(timer.close, timer)
      pcall(vim.api.nvim_buf_del_extmark, buf, ns, mopts.id)
    end
  end

  timer:start(opts.dt, opts.dt, vim.schedule_wrap(cb))
end

local M = {}

-- function that prints 10 lines, line by line

---@class mia.RevealOpts
---@field buf? number
---@field pos? table 0-indexed position
---@field ns? number extmark namespace
---@field speed? number characters per second
---@field dt? number miliseconds default 15
---@field hl_group? string Comment


function normalize_opts(opts)
  opts = opts or {}
  if not opts.pos then
    opts.pos = vim.api.nvim_win_get_cursor(0)
    opts.pos[1] = opts.pos[1] - 1
  end
  return vim.tbl_extend('keep', opts, {
    buf = vim.api.nvim_get_current_buf(),
    pos = vim.api.nvim_win_get_cursor(0),
    ns = vim.api.nvim_create_namespace('mia-reveal'),
    hl_group = 'CommentSansItalic',
    speed = 100,
    dt = 16,
    timeout = 2000,
  })
end

---@param opts mia.RevealOpts
function M.track(opts)
  return start_scanner(normalize_opts(opts))
end

-----@param text string|string[]
-----@param opts mia.RevealOpts
function M.text(text, opts)
  local timeout = opts and opts.timeout
  opts = normalize_opts(opts)
  text = type(text) == 'table' and table.concat(text, '\n') or text
  opts.timeout = timeout or #text / opts.speed * 1000
  mia.reveal.track(opts)
  vim.api.nvim_paste(text, true, -1)
end



return M
