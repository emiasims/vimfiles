local function get_visual(concat, allowed)
  allowed = allowed and ('[%s]'):match(allowed) or '[vV]'
  local mode = vim.fn.mode():match(allowed)
  if mode then
    nvim.feedkeys('`<', 'nx', false)
  end
  local text
  mode = mode or vim.fn.visualmode()
  local open, close = nvim.buf_get_mark(0, '<'), nvim.buf_get_mark(0, '>')
  if mode == 'v' then
    text = nvim.buf_get_text(0, open[1] - 1, open[2], close[1] - 1, close[2] + 1, {})
  elseif mode == 'V' then
    text = nvim.buf_get_lines(0, open[1] - 1, close[1], true)
  elseif mode == '' then
    text = vim.iter.map(
      function(line) return line:sub(open[2] + 1, close[2] + 1) end,
      nvim.buf_get_lines(0, open[1] - 1, close[1], true))
  end
  if concat then
    return table.concat(text, concat)
  end
  return text
end

return {
  get_visual = get_visual,
}
