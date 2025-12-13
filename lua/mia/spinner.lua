local M = {
  -- stylua: ignore
  frames = { '⡆', '⡇', '⠇', '⠏', '⠋', '⠙', '⠹', '⠸', '⢸', '⢰', '⣰', '⣠', '⣄', '⣆' },

  spinners = {},
  spin_ix = 1,
  timer = nil, ---@type uv_timer_t?
  spin_rate = 100,
  msg_rate = 100 / 3,
  msg_pad = '   ',
}

local _last_id = 0
local function get_next_id()
  _last_id = _last_id + 1
  return _last_id
end

local function spin_it()
  M.spin_ix = M.spin_ix + 1
  local active = false
  for id, spinner in pairs(M.spinners) do
    if spinner.check_complete() then
      M.remove(id)
    else
      active = true
    end
  end

  vim.api.nvim__redraw({ statusline = true })

  if not active then
    if M.timer then
      M.timer:stop()
      M.timer = nil
    end
  end
end

function M.add(check_complete, opts)
  assert(type(check_complete) == 'function', 'check_complete must be a function')

  opts = opts or {}
  local id = opts.id or get_next_id()

  M.spinners[id] = {
    id = id,
    check_complete = check_complete,
    msg = opts.msg,
    timeout = opts.timeout,
    created_at = vim.uv.now(),
  }

  if not M.timer then
    M.timer = assert(vim.uv.new_timer())
    M.spin_ix = 1
    M.timer:start(0, M.spin_rate, vim.schedule_wrap(spin_it))
  end

  return id
end

function M.remove(id)
  M.spinners[id] = nil
end

function M.clear()
  M.spinners = {}
end

function M.status(width)
  local active_spinners = {}
  for _, spinner in pairs(M.spinners) do
    table.insert(active_spinners, spinner)
  end

  if #active_spinners == 0 then
    return
  end

  local spin_char = M.frames[M.spin_ix % #M.frames + 1]

  if #active_spinners > 1 or not active_spinners[1].msg then
    return string.format('%d:%s', #active_spinners, spin_char)
  end

  local spinner = active_spinners[1]
  local msg = spinner.msg

  if width and #msg > width then
    msg = msg .. M.msg_pad
    local msg_ix = math.ceil(M.spin_ix * M.msg_rate / M.spin_rate) % #msg + 1
    msg = msg:rep(2):sub(msg_ix, msg_ix + width - 1)
  end

  return string.format('%s:%s', msg, spin_char)
end

return setmetatable(M, {
  __call = function(_, ...)
    return M.add(...)
  end,
})
