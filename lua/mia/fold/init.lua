return {
  text = function()
    local text = require'mia.fold.text'
    local ft = vim.bo[nvim.get_current_buf()].filetype
    if text[ft] then
      return text[ft]()
    end
    return text['default']()
  end,

  expr = function()
    local expr = require'mia.fold.expr'
    local ft = vim.bo[nvim.get_current_buf()].filetype
    if expr[ft] then
      return expr[ft]()
    end
    return expr['default']()
  end,
}
