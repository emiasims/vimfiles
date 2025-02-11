local pick = {}
do -- define funcs for prettier opts
  function pick.cmd(name, opts)
    if type(opts) == 'table' then
      opts = vim.inspect(opts, { newline = '', indent = '' })
    end
    return ('lua Snacks.picker.%s(%s)'):format(name, opts or '')
  end

  function pick.key(name, opts)
    return function()
      _G.Snacks.picker[name](opts)
    end
  end
end

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    dashboard = { enabled = false },
    explorer = { enabled = true },
    indent = { enabled = true, indent = { char = '╎' } },
    input = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true }, -- ??
    words = { enabled = true }, -- ??
    picker = {
      enabled = true,
      win = {
        input = {
          keys = {
            ['<C-t>'] = { 'tabdrop', mode = { 'i', 'n' } },
            -- reverse for default swap
            ['<Tab>'] = { 'select_and_prev', mode = { 'i', 'n' } },
            ['<S-Tab>'] = { 'select_and_next', mode = { 'i', 'n' } },
          },
        },
      },
      sources = {
        config_files = {
          -- git cfg ls-files. see milisims/dotfiles
          finder = function(opts, ctx)
            opts.cwd = vim.fs.normalize(vim.env.HOME)
            ctx.picker:set_cwd(opts.cwd)
            local args = { 'cfg', '-c', 'core.quotepath=false', 'ls-files', '--exclude-standard' }
            return require('snacks.picker.source.proc').proc({
              opts,
              {
                cmd = 'git',
                args = args,
                ---@param item snacks.picker.finder.Item
                transform = function(item)
                  item.cwd = opts.cwd
                  item.file = item.text
                end,
              },
            }, ctx)
          end,
          show_empty = true,
          format = 'file',
          untracked = false,
          submodules = false,
        },
      },
      -- default layout but input on bottom
      layouts = {
        default = {
          reverse = true,
          layout = {
            box = 'horizontal',
            width = 0.8,
            min_width = 120,
            height = 0.9,
            {
              box = 'vertical',
              border = 'rounded',
              title = '{title} {live} {flags}',
              { win = 'list', border = 'none' },
              { win = 'input', height = 1, border = 'top' },
            },
            { win = 'preview', title = '{preview}', border = 'rounded', width = 0.5 },
          },
        },
      },
    },
  },

  ctx = {
    {
      mode = 'ca',
      ctx = 'builtin.cmd_start',
      each = {
        p = pick.cmd('smart'),
        pi = pick.cmd('') .. '<Left><Left>',
        pp = pick.cmd('pickers'),
        f = pick.cmd('files'),
        fh = pick.cmd('files', '{ cwd = vim.fn.expand("%:h") }'),
        u = pick.cmd('undo'),
        l = pick.cmd('buffers'),
        pr = pick.cmd('resume'),
        mr = pick.cmd('recent'),
        A = pick.cmd('grep'),
        h = pick.cmd('help'),
        n = pick.cmd('notifications'),
        ex = pick.cmd('explorer'),
        hi = pick.cmd('highlights'),
        em = pick.cmd('icons'),
        t = pick.cmd('lsp_symbols'),
        ps = pick.cmd('lsp_symbols'),
        pws = pick.cmd('lsp_workspace_symbols'),
        ev = pick.cmd('files', '{ cwd = vim.fn.stdpath("config") }'),
        evp = pick.cmd('files', "{ cwd = vim.fn.stdpath('config') .. '/mia_plugins' }"),
        evs = pick.cmd('files', "{ cwd = vim.fn.stdpath('data') .. '/lazy' }"),
        evr = pick.cmd('files', '{ cwd = vim.env.VIMRUNTIME }'),
        gst = pick.cmd('git_status'),
        ecf = pick.cmd('config_files'),
      },
    },
  },

  -- stylua: ignore start
  keys = {
    { "gd", pick.key('lsp_definitions'), desc = "Goto Definition" },
    { "gD", pick.key('lsp_declarations'), desc = "Goto Declaration" },
    { "gr", pick.key('lsp_references'), nowait = true, desc = "References" },
    { "gI", pick.key('lsp_implementations'), desc = "Goto Implementation" },
    { "gy", pick.key('lsp_type_definitions'), desc = "Goto T[y]pe Definition" },
    { "<C-g><C-o>", pick.key('jumps'), desc = "Pick jumps" },
    { "z-", pick.key('spelling'), desc = "Pick spelling" },
  },
  -- stylua: ignore end
}
