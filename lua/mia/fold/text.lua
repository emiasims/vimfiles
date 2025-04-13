local M = {}

local ts = vim.treesitter
local api = vim.api

function M.extract(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()

  local ok, parser = pcall(ts.get_parser, bufnr)
  if not ok then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local query = ts.query.get(parser:lang(), 'highlights')
  if not query then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  local tree = parser:parse({ lnum - 1, lnum })[1]

  local line = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1]
  if not line or line:match('^%s*$') then
    return { { vim.fn.foldtext() or '', 'Folded' } }
  end

  return mia.highlights.extract(bufnr, lnum)
end

function M.default(foldtext, bufnr)
  if type(foldtext) ~= 'table' then
    foldtext = M.extract(foldtext, bufnr)
  end

  if type(foldtext) == 'string' then
    foldtext = { { foldtext, 'Folded' } }
  end
  table.insert(foldtext, { ' ⋯ ', 'Comment' })

  local suffix = ('%s lines %s'):format(vim.v.foldend - vim.v.foldstart, ('|'):rep(vim.v.foldlevel))
  local sufWidth = vim.fn.strdisplaywidth(suffix)
  local vtWidth = 0
  for _, chunk in ipairs(foldtext) do
    vtWidth = vtWidth + vim.fn.strdisplaywidth(chunk[1])
  end

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local target = wininfo.width - wininfo.textoff - sufWidth

  if vtWidth < target then
    suffix = (' '):rep(target - vtWidth) .. suffix
  end
  table.insert(foldtext, { suffix, 'Comment' })
  return foldtext
end

function M.org()
  local foldtext
  if vim.v.foldstart == 1 and vim.fn.getline(1):match('^%s*#%+[tT][iI][tT][lL][eE]:') then
    foldtext = M.extract(1)
    foldtext = { foldtext[#foldtext] }
  end

  foldtext = M.default(foldtext)

  local heart = vim.iter(foldtext):find(function(t)
    return t[1] == '❤'
  end)
  if heart then
    heart[1] = '❥'
  end

  return foldtext
end

function M.help(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  if lnum > 1 then
    lnum = lnum + 1
  end
  return M.default(M.extract(lnum, bufnr))
end

function M.python(lnum, bufnr)
  lnum = lnum or vim.v.foldstart
  bufnr = bufnr ~= 0 and bufnr or api.nvim_get_current_buf()
  local foldtext = M.extract()
  local text = vim.fn.getbufoneline(bufnr, lnum) --[[@as string]]

  -- Process decorated functions
  if text:match('^%s*@') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local decorator = vim.treesitter.get_node({ bufnr = bufnr, pos = pos })
    while decorator and decorator:type() ~= 'decorated_definition' do
      decorator = decorator:parent()
    end
    if not decorator then
      return M.default(foldtext)
    end

    local line = decorator:field('definition')[1]:start()
    local new_foldtext = M.extract(line + 1)
    while #new_foldtext > 0 and new_foldtext[1][1]:match('^%s+$') do
      table.remove(new_foldtext, 1)
    end
    new_foldtext[1][1] = ' ' .. new_foldtext[1][1]
    vim.list_extend(foldtext, new_foldtext)

    -- Process decorated functions
  elseif text:match('^%s*class') then
    local pos = { lnum - 1, #vim.fn.getbufline(bufnr, lnum)[1] - 1 }
    local class = vim.treesitter.get_node({ bufnr = bufnr, pos = pos })
    while class and class:type() ~= 'class_definition' do
      class = class:parent()
    end
    if not class then
      return M.default(foldtext)
    end

    local params
    for node in class:field('body')[1]:iter_children() do
      if
        node:type() == 'function_definition'
        and vim.treesitter.get_node_text(node:field('name')[1], bufnr):match('__init__')
      then
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

    -- local it_ft = vim.iter(require('mia.fold').ts_chunks(params, bufnr))
    -- local it_ft = vim.iter(P(require('mia.fold').ts_chunks(params:start() + 1, bufnr)))
    local it_ft = vim.iter(M.extract(params:start() + 1, bufnr))
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
    local nb = vim.api.nvim_buf_call(bufnr, function()
      return vim.fn.nextnonblank(lnum + 1)
    end)
    local docline = vim.fn.getbufline(bufnr, nb)[1]:match('^%s*(%S.*)')
    local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
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

  return M.default(foldtext)
end

return M
