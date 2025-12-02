local M = {}

function M.python(src, dest, force)
  if vim.startswith(src, 'tests/') then
    return
  end

  local src_import = src:gsub('/', '.'):gsub('.py$', ''):gsub('%.%.', '.')
  local dest_import = dest:gsub('/', '.'):gsub('.py$', ''):gsub('%.%.', '.')

  -- Move imports when we're done here
  local search = ('/%s/ **/*.py'):format(src_import)
  local sub = ('s/%s/%s/g%%s'):format(src_import, dest_import)
  vim.schedule(function()
    vim.ui.input({
      prompt = ("Replace imports?\n('%s' to '%s')\n[Y/n/c[onfirm]]: "):format(src_import, dest_import),
      default = 'y',
    }, function(input)
      input = (input and input or 'n'):sub(1, 1):lower()
      if input == 'n' then
        return
      elseif input == 'y' then
        vim.cmd.vimgrep(search)
        vim.cmd.cdo(sub:format(''))
      elseif input == 'c' then
        vim.cmd.vimgrep(search)
        vim.cmd.cdo(sub:format('c'))
      else
        vim.api.nvim_echo({ { 'Invalid input: [Y/n/c]', 'WarningMsg' } }, true, {})
      end
    end)
  end)

  -- Move tests to match the new name, if there's a matching test file
  local to_test = function(filename)
    if filename:sub(1, 1) == '/' then
      error('absolute path')
    end
    local dir = vim.fs.dirname(filename)
    local base = vim.fs.basename(filename) --[[@as string]]
    if dir == '.' then
      return 'tests/test_' .. base
    end
    return 'tests/' .. dir .. '/test_' .. base
  end

  src = to_test(src)
  dest = to_test(dest)

  if vim.fn.filereadable(src) == 1 then
    return M.Move(src, dest, force, true)
  end
end

function M.move(src, dest, force, skip_ft)
  local orig_buf = vim.fn.bufnr() --[[@as string]]

  if vim.fn.bufnr(src) == -1 and vim.fn.filereadable(src) ~= 1 then
    vim.api.nvim_echo({ { 'Unknown src to move: ' .. src, 'ErrorMsg' } }, true, {})
  elseif vim.fn.bufnr(src) == -1 or vim.fn.bufnr(src) ~= orig_buf then
    vim.cmd.edit({ src, mods = { keepalt = true, keepjumps = true, silent = true } })
  end

  if vim.fn.isdirectory(dest) == 1 then
    dest = vim.fs.joinpath(dest, vim.fn.expand('%:t'))
  end
  if vim.fn.filereadable(dest) == 1 and not force then
    vim.api.nvim_echo({ { 'E13: File exists (add ! to override)', 'ErrorMsg' } }, true, {})
    return
  end

  local path = vim.fn.expand('%:p')
  local rename = function()
    vim.cmd.file({ vim.fn.fnameescape(dest), mods = { silent = true, keepalt = true } })
    vim.cmd.write({ bang = true, mods = { silent = true } })
    vim.cmd.filetype({ 'detect', mods = { silent = true } })
    vim.fn.delete(path)
  end

  if Snacks then
    Snacks.rename.on_rename_file(path, dest, rename)
  else
    rename()
  end

  if vim.fn.bufnr() ~= orig_buf then
    vim.cmd.buffer({ orig_buf, mods = { keepalt = true, keepjumps = true, silent = true } })
  end

  -- TODO I feel like this should just be autocmds
  local ret = { { src, dest } }
  if not skip_ft and M[vim.o.filetype] then
    local moved = M[vim.o.filetype](src, dest, force)
    if moved then
      for _, mv in ipairs(moved) do
        table.insert(ret, mv)
      end
    end
  end

  return ret
end

function M.cmd(cmd)
  local src, dest = cmd.fargs[1], cmd.fargs[2]
  if not dest then
    dest = src
    src = vim.fn.expand('%')
  end
  local moved = M.move(src, dest, cmd.bang)
  if moved then
    for ix, mv in ipairs(moved) do
      moved[ix] = mv[1] .. ' to ' .. mv[2]
    end
    mia.info('Moved: ' .. table.concat(moved, ', '))
  end
end

return M
