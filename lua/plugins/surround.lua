-- needs doing before it's loaded, config occurs after packadd.
vim.g.surround_no_mappings = 1

---@type LazySpec
return {
  'tpope/vim-surround',
  ---@diagnostic disable: missing-fields
  keys = {
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
  },
  ---@diagnostic enable: missing-fields
}
