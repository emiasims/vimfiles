local ts = vim.treesitter
local api = vim.api

return function(lnum, bufnr)
  local foldtext = fold.highlights(lnum, bufnr)
  local text = vim.fn.getbufoneline(bufnr, lnum) --[[@as string]]

  -- Process decorated functions
  if text:match('^%s*@') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local decorator = ts.get_node({ bufnr = bufnr, pos = pos })
    while decorator and decorator:type() ~= 'decorated_definition' do
      decorator = decorator:parent()
    end
    if not decorator then
      return M.default(foldtext)
    end

    local line = decorator:field('definition')[1]:start()
    local new_foldtext = fold.highlights(line + 1, bufnr)
    while #new_foldtext > 0 and new_foldtext[1][1]:match('^%s+$') do
      table.remove(new_foldtext, 1)
    end
    new_foldtext[1][1] = ' ' .. new_foldtext[1][1]
    vim.list_extend(foldtext, new_foldtext)

    -- Process decorated functions
  elseif text:match('^%s*class') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local class = ts.get_node({ bufnr = bufnr, pos = pos })
    while class and class:type() ~= 'class_definition' do
      class = class:parent()
    end
    if not class then
      return M.default(foldtext)
    end

    local params
    for node in class:field('body')[1]:iter_children() do
      if node:type() == 'function_definition' and ts.get_node_text(node:field('name')[1], bufnr):match('__init__') then
        params = node:field('parameters')[1]
        break
      end
    end
    if not params then
      return M.default(foldtext)
    end
    local matcher = function(char)
      return function(chunk)
        return chunk[1] == char
      end
    end

    local it_ft = vim.iter(fold.highlights(params:start() + 1, bufnr))
    local open = it_ft:find(matcher('('))
    local close = it_ft:rfind(matcher(')'))
    if not (open and close) then
      return M.default(foldtext)
    end

    if it_ft:peek() and it_ft:peek()[1] == 'self' then
      it_ft:next()
      while it_ft:peek() and (it_ft:peek()[1]:match('^%s*,%s*$') or it_ft:peek()[1]:match('^%s$')) do
        it_ft:next()
      end
    end
    local args = it_ft:totable()

    local semi = table.remove(foldtext)
    table.insert(foldtext, open)
    vim.list_extend(foldtext, args)
    table.insert(foldtext, close)
    table.insert(foldtext, semi)
  elseif text:match('^%s*"""%s*$') then
    local nb = api.nvim_buf_call(bufnr, function()
      return vim.fn.nextnonblank(lnum + 1)
    end)
    local docline = vim.fn.getbufline(bufnr, nb)[1]:match('^%s*(%S.*)')
    local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
    local target = wininfo.width - wininfo.textoff - 11 - 15
    docline = table.concat(
      vim.iter(docline:gmatch('%S*')):fold({ len = 0, text = {} }, function(t, s)
        if s == '' then
        elseif t.len + #s > target then
          t.len = 9000
        else
          t.len = t.len + #s
          table.insert(t.text, s)
        end
        return t
      end).text,
      ' '
    )
    table.insert(foldtext, { ' ' })
    table.insert(foldtext, { docline, 'String' })
  end

  return foldtext
end
