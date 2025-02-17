local pick = {
  cmd = function(name, opts)
    if type(opts) == 'table' then
      opts = vim.inspect(opts, { newline = '', indent = '' })
    end
    return ('lua Snacks.picker.%s(%s)'):format(name, opts or '')
  end,
  key = function(name, opts)
    return function()
      _G.Snacks.picker[name](opts)
    end
  end,
}

return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@module 'snacks'
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
    notifier = {
      enabled = true,
      style = 'history',
      top_down = false,
    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = false },  -- ??

    picker = {
      enabled = true,
      layout = 'pseudo_sidebar',

      win = {
        input = {
          keys = { ['<C-t>'] = { 'tabdrop', mode = { 'i', 'n' } } },
        },
      },
      layouts = {
        pseudo_sidebar = {  -- sidebar, but in floating windows.
          layout = {
            box = 'horizontal',
            backdrop = false,
            row = 1,
            width = 0,
            height = function()
              return vim.o.lines - 3
            end,
            {
              box = 'vertical',
              width = 40,
              {
                win = 'input',
                height = 1,
                border = 'rounded',
                title = ' {title} {live} {flags}',
                title_pos = 'center',
              },
              { win = 'list', border = 'rounded' },
            },
            {
              win = 'preview',
              title = '{preview}',
              border = 'rounded',
              wo = {
                wrap = true,
              },
            },
          },
        },
      },
      sources = {
        nvim_plugins = {
          finder = 'files',
          format = 'file',
          cwd = vim.fn.stdpath('data') .. '/lazy',
          transform = function(item)
            local plugin = item.file:match('^([^/]+)/')
            item.cwd = item.cwd .. '/' .. plugin
            item.file = item.file:sub(#plugin + 2)
            return item
          end,
        },
        config_files = {
          format = 'file',
          finder = function()
            return vim
                .iter(vim.fn.systemlist('git cfg ls-files --exclude-standard'))
                :map(function(item)
                  return { file = item, cwd = vim.env.HOME }
                end)
                :totable()
          end,
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
        evr = pick.cmd('files', '{ cwd = vim.env.VIMRUNTIME }'),
        evs = pick.cmd('nvim_plugins'),
        ecf = pick.cmd('config_files'),
        gst = pick.cmd('git_status'),
      },
    },
  },

  keys = {
    { 'gd', pick.key('lsp_definitions'), desc = 'Goto Definition' },
    { 'gD', pick.key('lsp_declarations'), desc = 'Goto Declaration' },
    { 'gr', pick.key('lsp_references'), nowait = true, desc = 'References' },
    { 'gI', pick.key('lsp_implementations'), desc = 'Goto Implementation' },
    { 'gy', pick.key('lsp_type_definitions'), desc = 'Goto T[y]pe Definition' },
    { '<C-g><C-o>', pick.key('jumps'), desc = 'Pick jumps' },
    { 'z-', pick.key('spelling'), desc = 'Pick spelling' },
  },
}
