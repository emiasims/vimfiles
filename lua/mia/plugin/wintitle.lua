local M = { ns = vim.api.nvim_create_namespace('mia-wintitle') }

---@return boolean
local function is_float(wid)
  return vim.api.nvim_win_get_config(wid).relative ~= ""
end

local function _set_mark(buf, line, text)
  vim.api.nvim_buf_set_extmark(buf, M.ns, line, 0, {
    virt_text = { { ' ' .. text .. ' ', 'Comment' } },
    virt_text_pos = 'right_align',
    hl_mode = 'combine',
    ephemeral = true,
    ui_watched = true,
  })
end

local function on_win(_, _, buf, toprow, _)
  local bufinfo = mia.bufinfo.get(buf)
  if not bufinfo then
    return
  end
  if bufinfo.type == 'file' then
    _set_mark(buf, toprow, bufinfo.relative_path)
    if bufinfo.root then
      _set_mark(buf, toprow + 1, bufinfo.root.short)
    end
  elseif bufinfo.type == 'help' then
    _set_mark(buf, toprow, bufinfo.file)
  elseif bufinfo.type == 'terminal' then
    _set_mark(buf, toprow, 'cmd: ' .. bufinfo.cmd)
    _set_mark(buf, toprow + 1, bufinfo.title)
  end

end

function M.enable()
  M.disable()
  vim.api.nvim_set_decoration_provider(M.ns, {
    on_win = function(...)
      if is_float(select(2, ...)) then
        return
      end
      local ok, err = pcall(on_win, ...)
      if not ok then
        vim.schedule(M.disable)
        mia.err(err)
        mia.warn_once('Disabling wintitle')
      end
    end,
  })
end

function M.disable()
  vim.api.nvim_set_decoration_provider(M.ns, {})
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    vim.api.nvim_buf_clear_namespace(b, M.ns, 0, -1)
  end
end
M.enable()

return M
