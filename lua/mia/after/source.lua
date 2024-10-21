local M = {}

---@param lang string
---@return function
M.get = function(lang)
  local ok, srcf = pcall(require, 'mia.source.' .. lang)
  if not ok then
    error(('Unable to source filetype: "%s"'):format(lang), 0)
  end

  return mia.restore_opt({ eventignore = { append = { 'SourceCmd' } } }, srcf)
end

---@param ev nil|string|number|aucmd.callback.arg
M.source = function(ev)
  local file, buf
  if type(ev) == 'string' then
    file = vim.fn.fnamemodify(ev, ':p')
    buf = vim.fn.bufnr(file)
  elseif type(ev) == 'number' then
    buf = vim.fn.bufnr(ev)
    file = vim.api.nvim_buf_get_name(ev)
  elseif type(ev) == 'table' then
    file, buf = ev.file, ev.buf
  else
    buf = vim.api.nvim_get_current_buf()
    file = vim.api.nvim_buf_get_name(buf)
  end

  local ft = vim.filetype.match({ buf = buf, filename = file })
  if not ft then
    error(('Unable to detect filetype for "%s"'):format(ev), 0)
  end
  local src = M.get(ft)

  local s, r = pcall(src, file, buf)
  if not s then
    mia.err(r)
  end
end

M.enable = function()
  mia.augroup('mia-source', { SourceCmd = M.source }, true)
end
M.enable()

M.disable = function()
  pcall(vim.api.nvim_del_augroup_by_name, 'mia-source')
end

return M
