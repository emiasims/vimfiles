local gid = nvim.create_augroup('mia-general', { clear = true })

local autocmd = function(event, opts)
  opts.group = opts.group or gid
  nvim.create_autocmd(event, opts)
end

autocmd('TextYankPost', {
  desc = 'Highlight yanked text briefly',
  callback = function()
    vim.highlight.on_yank { higroup = 'Visual', timeout = 400 }
  end,
})

autocmd('OptionSet', {
  pattern = 'wrap',
  desc = "Toggle 'formatoptions' t when wrap is toggled",
  callback = function()
    if vim.v.option_type == 'global' then
      return
    end

    if vim.v.option_new == '1' and vim.v.option_old == '0' and vim.o.formatoptions:match 't' then
      vim.b._old_fo = vim.bo.formatoptions
      vim.opt_local.formatoptions:remove 't'
    elseif vim.v.option_new == '0' and vim.v.option_old == '1' and vim.b._old_fo then
      vim.b._old_fo = nil
      vim.opt_local.formatoptions:append 't'
    end
  end,
})

nvim.create_augroup('term-mode', { clear = true })
nvim.create_autocmd({ 'WinEnter', 'BufWinEnter' }, {
  group = 'term-mode',
  pattern = 'term://*',
  callback = function() if vim.b.last_mode == 't' then vim.cmd.startinsert() end end,
})

nvim.create_autocmd('TermOpen', {
  group = 'term-mode',
  pattern = '*',
  callback = function(ev)
    vim.b[ev.buf].last_mode = 't'
    vim.schedule_wrap(function()
      if ev.buf == vim.fn.bufnr() then
        vim.cmd.startinsert()
      end
    end)
  end,
})
