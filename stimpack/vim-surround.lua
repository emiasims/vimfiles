vim.g.surround_no_mappings = 1
stimpack.add({ 'https://github.com/tpope/vim-surround' })

mia.keymap({
  { 'Z', '<Plug>VSurround', mode = 'x' },
  { 'cZ', '<Plug>CSurround', mode = 'n' },
  { 'gZ', '<Plug>VgSurround', mode = 'x' },
  { 'cz', '<Plug>Csurround', mode = 'n' },
  { 'dz', '<Plug>Dsurround', mode = 'n' },
  { 'gZZ', '<Plug>YSsurround', mode = 'n' },
  { 'gZz', '<Plug>YSsurround', mode = 'n' },
  { 'gzz', '<Plug>Yssurround', mode = 'n' },
  { 'gZ', '<Plug>YSurround', mode = 'n' },
  { 'gz', '<Plug>Ysurround', mode = 'n' },
})
