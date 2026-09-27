stimpack.dev('mia', 'emiasims/nvim-bodgery')

vim.keymap.set({ 'n', 't' }, '<C-.>', function()
  if not pcall(require('bodgery').toggle) then
    vim.cmd.Claude({ mods = { vertical = true } })
  end
end)

-- loading the file before Claude writes it lets 'autoread' record the change
-- as an undo step (see 'undoreload') and attaches LSP so diagnostics after
-- the edit are real
local edit_tools = { Edit = true, Write = true, NotebookEdit = true, Update = true }
mia.augroup('bodgery', {
  User = {
    ClaudeToolUsePre = function(ev)
      local input = ev.data.tool_input or {}
      local file = edit_tools[ev.data.tool_name] and (input.file_path or input.notebook_path)
      local buf = file and vim.fn.bufadd(file)
      if buf and not vim.api.nvim_buf_is_loaded(buf) then
        vim.fn.bufload(buf)
        vim.bo[buf].buflisted = true
        -- bufload skips BufRead autocmds, so no filetype and no LSP
        vim.api.nvim_exec_autocmds('BufReadPost', { buffer = buf })
        mia.info('Claude: loaded %s (%s)', file, vim.api.nvim_buf_get_name(buf))
      end
    end,
  },
})
