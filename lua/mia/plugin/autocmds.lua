return mia.augroup('mia-autocmds', {
  -- OG
  BufWinLeave = "if empty(&buftype) && &modifiable && !empty(expand('%')) | mkview | endif",
  BufWinEnter = "if empty(&buftype) && &modifiable && !empty(expand('%')) | silent! loadview | endif",

  [{ 'WinEnter', 'FocusGained' }] = 'silent! checktime',

  [{ 'WinLeave', 'BufLeave', 'FocusLost' }] = "if &buftype == '' && &modifiable | silent! lockmarks update | endif",

  BufWritePost = { 'if empty(&filetype) | unlet! b:ftdetect | filetype detect | endif', nested = true },

  BufReadPost = [[if &ft !~ '^git\c' && ! &diff && line("'\"") > 0 && line("'\"") <= line("$") | execute 'normal! g`"zvzz' | endif]],

  InsertLeave = {
    "if &paste | setlocal nopaste | echo 'nopaste' | endif",
    'if &diff | diffupdate | endif',
  },

  WinEnter = 'setlocal cursorline',
  WinLeave = 'setlocal nocursorline',

  BufWritePre = 'call mkdir(expand("<afile>:p:h"), "p")',

  [{ 'BufEnter', 'FocusGained', 'InsertLeave', 'WinEnter' }] = 'if &nu | set rnu   | endif',
  [{ 'BufLeave', 'FocusLost', 'InsertEnter', 'WinLeave' }] = 'if &nu | set nornu | endif',

  FileType = {
    -- qfreplace = 'setlocal nofoldenable',
    -- sh = 'let b:is_bash=1|let g:sh_fold_enabled=5',
    { 'setlocal nofoldenable', pattern = 'qfreplace' },
    { 'let b:is_bash=1|let g:sh_fold_enabled=5', pattern = 'sh' },
  },

  BufRead = 'if empty(&filetype) | set commentstring=#%s | endif',

  -- neovim

  -- Shares cmdline, search, and input histories, registers,
  FocusGained = 'rshada',
  FocusLost = 'wshada',

  -- cursor color macro recording
  RecordingEnter = 'hi! link CursorLine CursorLRecording',
  RecordingLeave = 'hi! link CursorLine CursorLBase',

  TextYankPost = {
    {
      desc = 'Highlight yanked text briefly',
      callback = function()
        vim.highlight.on_yank({ higroup = 'Visual', timeout = 400 })
      end,
    },
    {
      desc = 'Shift yanked text to registers 1-9',
      callback = function()
        local event = vim.v.event
        ---@diagnostic disable-next-line: undefined-field
        if event.operator == 'y' and event.regname == '' then
          local un = tonumber(vim.fn.getreginfo('"').points_to)
          local i, reg, last = 1, vim.fn.getreginfo('1'), vim.fn.getreginfo('0')
          repeat
            ---@diagnostic disable-next-line: param-type-mismatch
            vim.fn.setreg(i, last.regcontents, last.regtype .. (un == i and 'u' or ''))
            i, reg, last = i + 1, vim.fn.getreginfo(i + 1), reg
          until i > 9
            -- if its empty, we can stop there. Don't need to save it
            or (#last.regcontents == 1 and last.regcontents[1]:match('^%s*$'))
            -- if the next register is the same as this one, don't need to save it
            or vim.deep_equal(reg.regcontents, last.regcontents)
        end
      end,
    },
  },

  OptionSet = {
    pattern = 'wrap',
    desc = "Toggle 'formatoptions':t when 'wrap' is toggled",
    callback = function()
      if vim.v.option_type == 'global' then
        return
      end

      ---@diagnostic disable-next-line: undefined-field
      if vim.v.option_new == '1' and vim.v.option_old == '0' and vim.o.formatoptions:match('t') then
        vim.b._old_fo = vim.bo.formatoptions
        vim.opt_local.formatoptions:remove('t')
      elseif vim.v.option_new == '0' and vim.v.option_old == '1' and vim.b._old_fo then
        vim.b._old_fo = nil
        vim.opt_local.formatoptions:append('t')
      end
    end,
  },

  [{ 'WinEnter', 'BufWinEnter' }] = {
    pattern = 'term://*',
    callback = function()
      if vim.b.last_mode == 't' then
        vim.cmd.startinsert()
      end
    end,
  },

  TermOpen = {
    callback = function(ev)
      vim.b[ev.buf].last_mode = 't'
      vim.schedule_wrap(function()
        if ev.buf == vim.fn.bufnr() then
          vim.cmd.startinsert()
        end
      end)
    end,
  },

  ModeChanged = {
    pattern = '*:no*',
    desc = 'Mark `` with location before editing.',
    callback = function()
      local pos = vim.api.nvim_win_get_cursor(0)
      vim.api.nvim_buf_set_mark(0, '`', pos[1], pos[2], {})
    end,
  },
}, true)
