stimpack.add({ 'https://github.com/tpope/vim-fugitive' }, { start = true })

local ctx = require('ctxmap')

ctx.keymap.sets({
  ctx = 'cmd.start(lhs, map) and abbr.trigger(" ")',
  mode = 'ca',
  { 'gau', 'Git add --update' },
  { 'gst', 'Git status' },
  { 'gco', 'Git checkout' },
  { 'gad', 'Git add' },
  { 'cad', 'Git cfg add' },
  { 'gaup', 'Git add --update --patch' },
})

ctx.keymap.sets({
  ctx = 'cmd.start',
  mode = 'ca',
  clear = false,
  { 'gd', 'botright Gvdiffsplit!' },
  { 'gau', 'Git add --update %' },
  { 'gst', 'Git status <C-r>=expand("%:h")<Cr>' },
  { 'gpl', 'Git pull' },
  { 'gps', 'Git push' },
  { 'gcim', "Git commit -m ''<Left>", eat = '%s' },
  { 'gco', 'Git checkout %' },
  { 'gad', 'Git add %' },
  { 'cad', 'Git cfg add %' },
  { 'gaup', 'Git add --update --patch %' },
})

mia.augroup('fugitive', {
  BufEnter = {
    pattern = 'fugitive://*',
    callback = function()
      vim.b.update_bufinfo = function(info)
        local git_dir, object, path = info.bufname:match('^fugitive://(.-)//(%x+)/(.*)$')
        if object then
          return {
            type = 'fugitive',
            desc = ('(fugitive:%s)%s/'):format(info.git.head, vim.fs.dirname(path)),
            cwd = vim.fs.dirname(path),
            name = vim.fs.basename(path),
          }
        end
        mia.err_once(('bufname parsing failed for: "%s"'):format(info.bufname))
        return {}
      end
    end,
  },
})
