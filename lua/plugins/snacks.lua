return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,

  ctxmap = {
    {
      mode = 'ca',
      -- ctx = 'builtin.cmd_start',
      ctx = 'cmd.start',
      { 'p', 'Pick smart' },
      { 'pi', 'Pick' },
      { 'pp', 'Pick pickers' },
      { 'f', 'Pick files' },
      { 'fh', 'Pick files cwd=%:h' },
      { 'u', 'Pick undo' },
      { 'l', 'Pick buffers' },
      { 'pr', 'Pick resume' },
      { 'mr', 'Pick recent' },
      { 'A', 'Pick grep' },
      { 'h', 'Pick help' },
      { 'n', 'Pick notifications' },
      { 'ex', 'Pick explorer' },
      { 'hi', 'Pick highlights' },
      { 'em', 'Pick icons' },
      { 't', 'Pick lsp_symbols' },
      { 'ps', 'Pick lsp_symbols' },
      { 'pws', 'Pick lsp_workspace_symbols' },
      { 'ev', 'Pick files cwd=<C-r>=stdpath("config")<Cr>' },
      { 'evp', 'Pick files cwd=<C-r>=stdpath("config")<Cr>/mia_plugins' },
      { 'evs', 'Pick files cwd=<C-r>=stdpath("data")<Cr>/lazy' },
      { 'evr', 'Pick files cwd=$VIMRUNTIME' },
      { 'ecf', 'Pick config_files' },
      { 'gst', 'Pick git_status' },
      { 'ep', 'Pick prompts' },
    },
    {
      '<C-p>',
      {
        'opt.buftype() == "" and opt.modifiable()',
        function()
          return require('config.snacks').put_register()
        end,
      },
      desc = 'Pick register & put',
    },
  },
  keys = {
    { 'gd', '<Cmd>Pick lsp_definitions<Cr>', desc = 'Goto Definition' },
    { 'gD', '<Cmd>Pick lsp_declarations<Cr>', desc = 'Goto Declaration' },
    { 'gr', '<Cmd>Pick lsp_references<Cr>', nowait = true, desc = 'References' },
    { 'gI', '<Cmd>Pick lsp_implementations<Cr>', desc = 'Goto Implementation' },
    { 'gy', '<Cmd>Pick lsp_type_definitions<Cr>', desc = 'Goto T[y]pe Definition' },
    { '<C-g><C-o>', '<Cmd>Pick jumps<Cr>', desc = 'Pick jumps' },
    { 'z-', '<Cmd>Pick spelling<Cr>', desc = 'Pick spelling' },
  },
  opts = function()
    return require('config.snacks').lazy_opts
  end,
}
