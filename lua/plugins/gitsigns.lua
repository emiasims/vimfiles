---@type LazySpec
return {
  'lewis6991/gitsigns.nvim',
  event = { 'TextChanged', 'SafeState' },
  opts = { attach_to_untracked = true },
  keys = {
    { ']c', '<Cmd>Gitsigns next_hunk<Cr>' },
    { '[c', '<Cmd>Gitsigns prev_hunk<Cr>' },
    { 'gsh', '<Cmd>Gitsigns stage_hunk<Cr>' },
  },
}
