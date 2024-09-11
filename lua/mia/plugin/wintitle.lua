local M = { ns = vim.api.nvim_create_namespace('mia-wintitle') }

local function is_float(wid)
  return vim.api.nvim_win_get_config(wid).zindex
end

local valid_buf = function(buf)
  buf = buf or 0
  return ({ [''] = true, help = true })[vim.bo[buf].buftype]
end

local on_win = function(_, win, buf, toprow, _)
  if not valid_buf(buf) or is_float(win) then
    return
  end
  local title = vim.api.nvim_eval_statusline(' %f ', { winid = win, use_winbar = true })
  vim.api.nvim_buf_set_extmark(buf, M.ns, toprow, 0, {
    virt_text = { { title.str, 'Comment' } },
    virt_text_pos = 'right_align',
    hl_mode = 'combine',
    ephemeral = true,
    ui_watched = true,
  })
end

M.enable = function()
  M.disable()
  vim.api.nvim_set_decoration_provider(M.ns, { on_win = on_win })
end

M.disable = function()
  vim.api.nvim_set_decoration_provider(M.ns, {})
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(b, M.ns, 0, -1)
  end
end
M.enable()

return M
