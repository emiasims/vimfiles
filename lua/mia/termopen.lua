-- TODO make this a command to work with T<cr> and T<space>
local function default_term()
  -- if in term (same window)
  if vim.bo.buftype == 'terminal' then
    return 'term fish'
  end

  -- if term open in tab
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(winid)
    if vim.bo[buf].buftype == 'terminal' then
      local winnr = vim.fn.win_id2win(winid)
      return winnr .. 'wincmd w'
    end
  end

  -- if term buffer open in same dir
  -- ONLY apply if the buffer is running the requested prg (if I open opencode)
  -- I don't want this to apply
  local dir = vim.fs.normalize(vim.fn.getcwd(0))

  local info = vim
    .iter(vim.api.nvim_list_bufs())
    :map(mia.bufinfo --[[@as function]])
    :find(function(ifo) return ifo.pid and vim.fs.normalize(ifo.dir) == dir end)
  if info then
    return 'vsplit|buffer ' .. info.bufnr
  end

  -- default
  return 'vsplit|term fish'
end

-- open vsp term if open
-- open vsp term buffer if open in same dir
-- go to window if term open in tab
-- if in term, open new term
return setmetatable({}, {
  __call = default_term,
})
