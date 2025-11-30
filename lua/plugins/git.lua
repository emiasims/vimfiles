---@type LazySpec
return {
  {
    'tpope/vim-fugitive',
    lazy = false,
    cmd = { 'G', 'Git' },
    ctxmap = {
      {
        ctx = 'cmd.start(lhs, map) and abbr.trigger(" ")',
        mode = 'ca',
        { 'gau', 'Git add --update' },
        { 'gst', 'Git status' },
        { 'gco', 'Git checkout' },
        { 'gad', 'Git add' },
        { 'gau', 'Git add --update' },
        { 'gaup', 'Git add --update --patch' },
      },
      {
        ctx = 'cmd.start',
        mode = 'ca',
        { 'gau', 'Git add --update %' },
        { 'gst', 'Git status <C-r>=expand("%:h")<Cr>' },
        { 'gpl', 'Git pull' },
        { 'gps', 'Git push' },
        { 'gcim', "Git commit -m ''<Left>", eat = '%s' },
        { 'gco', 'Git checkout %' },
        { 'gad', 'Git add %' },
        { 'gau', 'Git add --update %' },
        { 'gaup', 'Git add --update --patch %' },
        -- TODO cfg files
        clear = false,
      },
    },
  },
  {
    'kdheepak/lazygit.nvim',
    lazy = true,
    cmd = {
      'LazyGit',
      'LazyGitConfig',
      'LazyGitCurrentFile',
      'LazyGitFilter',
      'LazyGitFilterCurrentFile',
    },
    ctxmap = {
      { 'lg', 'LazyGit', mode = 'ca', ctx = 'cmd.start' },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'TextChanged', 'SafeState' },
    opts = { attach_to_untracked = true },
    keys = {
      { ']c', '<Cmd>Gitsigns next_hunk<Cr>' },
      { '[c', '<Cmd>Gitsigns prev_hunk<Cr>' },
      { 'gsh', '<Cmd>Gitsigns stage_hunk<Cr>' },
    },
  },
}
