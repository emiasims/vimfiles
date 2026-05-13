stimpack.add({ 'https://github.com/lewis6991/gitsigns.nvim' })

require('gitsigns').setup({ attach_to_untracked = true })

mia.keymap({
  { ']c', '<Cmd>Gitsigns next_hunk<Cr>' },
  { '[c', '<Cmd>Gitsigns prev_hunk<Cr>' },
  { 'gsh', '<Cmd>Gitsigns stage_hunk<Cr>' },
})
