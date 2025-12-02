local M = {}

---@param lang string
---@return function
function M.get(lang)
  local ok, srcf = pcall(require, 'mia.source.' .. lang)
  if not ok then
    error(('Unable to source filetype: "%s"\n%s'):format(lang, srcf), 0)
  end

  return mia.restore_opt({ eventignore = { append = { 'SourceCmd' } } }, srcf)
end

---@param ev nil|string|integer|aucmd.callback.arg
function M.source(ev)
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
  if not ft and vim.startswith(file, vim.fs.normalize(vim.o.viewdir)) then
    ft = 'vim'
  elseif not ft then
    error(('Unable to detect filetype for "%s"'):format(vim.inspect(ev)), 0)
  end
  local src = M.get(ft)

  if vim.v.vim_did_enter == 1 and vim.api.nvim_buf_get_name(buf) == file then
    vim.api.nvim_buf_call(buf, vim.cmd.update)
  end

  local s, r = pcall(src, file, buf)
  if not s then
    mia.err(r)
  end
end

function M.enable()
  mia.augroup('mia-source', { SourceCmd = M.source }, true)
end

function M.disable(ignore)
  local ok, err = pcall(vim.api.nvim_del_augroup_by_name, 'mia-source')
  if not ok and not ignore then
    mia.err(err)
  end
end

return M
