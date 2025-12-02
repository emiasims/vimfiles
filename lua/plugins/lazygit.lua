---@type LazySpec
return {
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
}
