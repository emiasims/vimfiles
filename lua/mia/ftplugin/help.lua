return {
  opts = {
    colorcolumn = '80',
    foldmethod = 'expr',
  },
  keys = { { 'K', 'K' } },
  config = function(buf)
    if vim.bo[buf].modifiable then
      return { opts = { concealcursor = '' } }
    end
    return { keys = { 'q', '<Cmd>helpclose<Cr>' } }
  end,
}
