return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  config = function(spec)
    require('snacks').setup(spec.opts)

    mia.command('Pick', {
      nargs = '+',
      callback = function(cmd)
        local opts = { source = cmd.fargs[1] }

        for i = 2, #cmd.fargs do
          local k, v = cmd.fargs[i]:match('^(%w+)=(.*)$')  -- escaping ws works
          if not k then
            error('Invalid argument: ' .. cmd.fargs[i])
          end
          if v == 'true' then
            opts[k] = true
          elseif v == 'false' then
            opts[k] = false
          else
            opts[k] = vim.fn.expandcmd(v)
          end
        end

        Snacks.picker.pick(opts)
      end,

      -- arglead, cmdline, cursorpos
      complete = function(arglead, cmdline, _)
        if cmdline == 'Pick ' then
          return vim.tbl_keys(Snacks.picker.config.get().sources  --[[@as table]])
        end

        local opts = Snacks.picker.config.get({ source = cmdline:match('Pick (%S+)') })

        local opt = arglead:match('^(%w+)=')
        if not opt then
          local ret = { 'cwd=' }
          local skip = { enabled = true, source = true }

          for k, v in pairs(opts) do
            if not skip[k] and type(v) ~= 'table' then
              table.insert(ret, k .. '=')
            end
          end
          return ret
        end

        if opt == 'focus' then
          return { 'input', 'list' }
        elseif opt == 'finder' then
          return vim
              .iter(Snacks.picker.config.get().sources)
              :map(function(_, v)
                return type(v.finder) == 'string' and v.finder or nil
              end)
              :totable()
        elseif opt == 'layout' then
          return vim.tbl_keys(Snacks.picker.config.get().layouts)
        elseif opt == 'cwd' then
          return vim.fn.getcompletion(arglead:sub(#opt + 2), 'dir', true)
        elseif type(opts[opt]) == 'boolean' then
          return { 'true', 'false' }
        end
      end,
    })
  end,

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
              wo = { wrap = true },
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
                  return { file = item, cwd = vim.env.HOME, text = item }
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
        p = 'Pick smart',
        pi = 'Pick',
        pp = 'Pick pickers',
        f = 'Pick files',
        fh = 'Pick files cwd=%:h',
        u = 'Pick undo',
        l = 'Pick buffers',
        pr = 'Pick resume',
        mr = 'Pick recent',
        A = 'Pick grep',
        h = 'Pick help',
        n = 'Pick notifications',
        ex = 'Pick explorer',
        hi = 'Pick highlights',
        em = 'Pick icons',
        t = 'Pick lsp_symbols',
        ps = 'Pick lsp_symbols',
        pws = 'Pick lsp_workspace_symbols',
        ev = 'Pick files cwd=<C-r>=stdpath("config")<Cr>',
        evp = 'Pick files cwd=<C-r>=stdpath("config")<Cr>/mia_plugins',
        evr = 'Pick files cwd=$VIMRUNTIME',
        evs = 'Pick nvim_plugins',
        ecf = 'Pick config_files',
        gst = 'Pick git_status',
      },
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
}
