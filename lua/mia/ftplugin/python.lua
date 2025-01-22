local H = {
  open_testfile = function()
    if not vim.uv.fs_realpath('tests') then
      vim.api.nvim_echo({ { 'No tests directory found', 'WarningMsg' } }, true, {})
      return
    end
    local fname = vim.fn.expand('%')
    local dir = vim.fs.dirname(fname)
    local base = vim.fs.basename(fname)
    local testpath = 'tests/' .. dir .. '/test_' .. base
    vim.cmd.edit(testpath)
    if not vim.uv.fs_realpath(testpath) then
      vim.api.nvim_echo({ { 'New file: ' .. testpath, 'WarningMsg' } }, true, {})
      -- vim.fn.setline(0, )
      local parts = vim.split(fname:gsub('%.py$', ''), '/')
      vim.api.nvim_buf_set_lines(0, 0, 0, false, {
        'import pytest',
        'from conftest import importerskip',
        '',
        ('%s = importorskip(%s)'):format(parts[#parts], table.concat(parts, '.')),
      })
    end
  end,

  ignore_lsp_diag = function()
    local it = vim.iter(vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 }))
    it:filter(function(d)
      return d.source:match('[Pp]yright$')
    end)
    local codes = it:fold({}, function(t, d)
      t[d.code] = true
      return t
    end)
    codes = vim.tbl_keys(codes)

    if #codes > 0 then
      vim.cmd.normal({ '$', bang = true })
      vim.api.nvim_put({ ('  # type: ignore [%s]'):format(table.concat(codes, ', ')) }, 'c', true, true)
    else
      vim.api.nvim_echo({ { 'No Pyright diagnostics found', 'WarningMsg' } }, true, {})
    end
  end,
}

---@type mia.ftplugin
FT = {
  H = H,
  opts = {
    tabstop = 4,
    shiftwidth = 4,
    foldminlines = 2,
    colorcolumn = '100',
  },

  keys = {
    {
      mode = 'ia',
      { 'ipdb', "__import__('ipdb').set_trace()<Left><Esc>" },
      { 'pdb', "__import__('pdb').set_trace()<Left><Esc>" },
      { 'iem', "__import__('IPython').embed()<Left><Esc>" },
      { 'true', 'True' },
      { 'false', 'False' },
      { '&&', 'and' },
      { '||', 'or' },
      { '--', '#' },
      { 'nil', 'None' },
      { 'none', 'None' },
      { 'naive', 'naïve' },
    },
    {
      { '\\tf', H.open_testfile },
      { '\\ci', H.ignore_lsp_diag },
      { '\\an', 'gziw]iAnnotated<Esc>f]i, ""<Left>', remap = true },
      { 'gO', '<cmd>lvimgrep /\\v^\\s*%(def |class )/ % | lopen<Cr>' },
    },
  },

  -- ctx = {
  --   ['g~'] = {
  --     { 'gziw"gza"]X%', query = '(attribute attribute: (identifier) @cursor)', remap = true },
  --     { 'yiqva]p`[i.<Esc>e', query = '(subscript subscript: (string) @cursor)', remap = true },
  --   },
  --   ['~'] = {
  --     default = '<plug>(ctx-global)',
  --     { 'ciwTrue<Esc>`[', node = 'false' },
  --     { 'ciwFalse<Esc>`[', node = 'true' },
  --   },
  --   ei = {
  --     mode = 'ca',
  --     { "edit <C-r>=expand('%:h')<Cr>/__init__.py", 'builtin.cmd_start' },
  --   },
  -- },
}

return FT
