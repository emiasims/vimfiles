---@type LazySpec
return {
  {
    'milisims/lazy-ctx.nvim',
    event = 'VeryLazy',
    -- priority = math.huge,
    -- lazy = true,
    config = true,
    dev = true,
    dependencies = { 'ctx.nvim' },
  },
  {
    'milisims/ctx.nvim',
    -- FIXME: reloading doesn't reload keys defined like this
    dev = true,
    ctx = {
      -- Tab: if all whitespace,
      -- if not whitespace, but there's a ghost-text completion, accept it
      -- normal tab otherwise

      -- <C-t> on cmdline that starts with e or edit, make it tabedit and go
      -- same for C-v for vsplit and C-s for split? something like that
      {
        mode = 'ca',
        ctx = 'builtin.cmd_start',
        each = {
          he = 'help',
          eft = 'EditFtplugin',
          eq = 'vsp|TSEditQuery highlights',
          eqa = 'vsp|TSEditQueryUserAfter highlights',
          es = 'vertical EditSnippets',
          ['e!'] = 'mkview | edit!',
          use = 'UltiSnipsEdit',
          ase = 'AutoSourceEnable',
          asd = 'AutoSourceDisable',
          vga = 'vimgrep // **/*.<C-r>=expand("%:e")<Cr><C-Left><Left><Left>',
          ccle = 'Cclearquickfix',
          cclear = 'Cclearquickfix',
          lcle = 'Lclearloclist',
          lclear = 'Lclearloclist',
          w2 = 'w',
          dws = 'mkview | silent! %s/\\s\\+$// | loadview | update',
          eh = 'edit <C-r>=expand("%:h")<Cr>/',
          mh = 'Move <C-r>=expand("%:h")<Cr>/',
          T = 'execute "term fish"|startinsert',
          term = 'term fish',
          zo = 'lua require("mia.zotero").pick()',
          zc = 'lua require("mia.zotero").cite()',

          tc = 'TabCopy',
          tsl = 'TabSlice',
          tsp = 'tab split',

          -- For fugitive.vim, from cmdline config abbreviations
          git = 'Git',
          -- gst = 'Telescope git_status',  # see ./telescope.lua
          gpl = 'Git pull',
          gpu = 'Git push',
          gad = 'Git add',
          gap = 'Git add --patch',
          gau = 'Git add --update',
          gaup = 'Git add --update --patch',
          gd = 'Git diff',
          gdc = 'Git diff --cached',
          gwd = 'Git diff --color-words',
          grh = 'Git reset HEAD --',
          gcim = 'Git commit -m',
          gbr = 'Git branch',
          gco = 'Git checkout',
          glo = 'Git log --all --oneline --graph -n 20',
        },
      },
      {
        '0',
        { { '0', 'ws_precursor' }, { 'g^', 'opt.wrap.on()' } },
        default = '0^',
        mode = { 'n', 'x', 'o' },
      },
      { '$', { 'g$', 'opt.wrap.on()' }, mode = { 'n', 'o' } },
      { '$', { 'g$h', 'opt.wrap.on()' }, mode = 'x', default = '$h' },
      {
        '<Esc>',
        { { '<C-e>', 'pumvisible' }, { '<C-e>', 'blink_visible', remap = true } },
        mode = 'i',
      },
    },
    keys = {
      { 'g0', '0', mode = { 'n', 'x', 'o' } },
      { 'g$', '$', mode = { 'n', 'x', 'o' } },
      { 'gi', mode = { 'n', 'x', 'o' } },

      -- { ' ', mode = 'c' },
      -- <Space> ➜ expand an empty command line to 'lua ',
      -- ':eh' to ':edit (here)/' (no space!) and similar for 'vga'.
      -- mapping <Space> removes its ability to properly trigger abbreviations, so add
      -- it back in by defaulting to '<C-]> ', forcing the expansion if one exists.

      -- {
      --   ' ',
      --   ' ',
      --   ctx = {
      --     { 'lua ', 'cmdline.eq("")' },
      --     { '<C-]>', 'cmdline.eq("eh")' },
      --     { '<C-]>', 'cmdline.eq("vga")' },
      --     -- for eq and eqa above, this basically lets 'highlights' act as the
      --     -- default argument (when triggered with <Cr>), but removes it when
      --     -- triggering with <Space>
      --     { '<C-]><C-w>', 'cmdline.eq("eq")' }, -- match('eqa?')
      --     { '<C-]><C-w>', 'cmdline.eq("eqa")' },
      --     { '<C-]><C-w><Bs><Left>', 'cmdline.eq("T")' },
      --   },
      --   mode = 'c',
      -- },

      -- {
      --   'ctx.each(luasnip)',
      --   'ctx.require("luasnip").in_snippet()',
      --   mode = { 'i', 's' },
      --   pairs = {
      --     ['<Tab>'] = 'ctx.require("luasnip").jump(1)',
      --     ['<S-Tab>'] = 'ctx.require("luasnip").jump(-1)',
      --     ['<C-m>'] = '<Plug>luasnip-next-choice',
      --     ['<C-k>'] = '<Plug>luasnip-prev-choice',
      --   },
      -- },

      { '<Cr>', mode = { 'i', 's', 'c' } },
    },

    config = function()
      local map = function(...)
        vim.keymap.set({ 'n', 'x', 'o' }, ...)
      end
      local ctx = require('ctx')
      local contexts = require('ctx.builtin')
      local text = require('ctx.text')
      local cm = require('ctx.ContextManager')
      cm.add(ctx.opt.wrap.on)

      cm.add('ws_precursor', function()
        return (text.around_cursor('^', -1) or ''):match('^%s+$')
      end)

      -- <count>gi ➜ insert count characters before automatically exiting insert
      ctx.set('n', 'gi', {
        rhs = function()
          vim.cmd.startinsert()
          local nchars, max, auid = 0, vim.v.count, nil
          auid = vim.api.nvim_create_autocmd({ 'TextChangedI', 'TextChangedP', 'InsertLeave' }, {
            callback = function()
              nchars = nchars + 1
              if nchars >= max or not vim.fn.mode():match('[iI]') then
                vim.cmd.stopinsert()
                vim.api.nvim_del_autocmd(auid --[[@as number]])
              end
            end,
          })
        end,
        context = function()
          return vim.v.count > 0
        end,
      })

      local function cmdline_is(opts)
        return {
          rhs = opts.rhs,
          context = function()
            local cmdline = vim.split(vim.fn.getcmdline() --[[@as string]], ' ')
            -- Use getcmdpos() to get where we are instead of #cmdline?
            return vim.fn.getcmdcompltype() == 'command' and cmdline[#cmdline] == opts.cmdline
          end,
          cdesc = ('command = "%s"'):format(opts.cmdline),
        }
      end

      ctx.set('c', ' ', {
        cmdline_is({ rhs = 'lua ', cmdline = '' }),
        cmdline_is({ rhs = '<C-]>', cmdline = 'pi' }),
        cmdline_is({ rhs = '<C-]>', cmdline = 'eh' }),
        cmdline_is({ rhs = '<C-]>', cmdline = 'mh' }),
        cmdline_is({ rhs = '<C-]>', cmdline = 'vga' }),
        cmdline_is({ rhs = '<C-]><C-w>', cmdline = 'eq' }),
        cmdline_is({ rhs = '<C-]><C-w>', cmdline = 'eqa' }),
        cmdline_is({ rhs = '<C-]><C-w><Bs><Left><C-w>', cmdline = 'T' }),
      }, { default = '<C-]> ' })

      local function onewin()
        local layout = vim.fn.winlayout()
        return #layout == 2 and layout[1] == 'leaf'
      end

      ctx.set('n', '<C-l>', { rhs = 'gt', context = onewin }, { default = '<C-w>l' })
      ctx.set('n', '<C-h>', { rhs = 'gT', context = onewin }, { default = '<C-w>h' })

      -- I want @" to work on cmdline like it does in vim files for lua files
      local lua_yank = {}
      vim.api.nvim_create_autocmd('TextYankPost', {
        group = vim.api.nvim_create_augroup('mia-ctx-ft', { clear = true }),
        pattern = '*',
        callback = function()
          local reg = vim.v.event.regname == '' and '"' or vim.v.event.regname
          lua_yank[reg] = vim.bo.filetype == 'lua' and vim.v.event.regcontents
        end,
      })

      ctx.set('c', '<Cr>', {
        rhs = function()
          -- <C-c> exits cmdline but preserves history
          local reg = vim.fn.getcmdline():sub(-1)
          vim.api.nvim_feedkeys(vim.keycode('<C-c>'), 'n', false)
          -- get the register and execute the contents
          local contents = lua_yank[reg]
          -- if there's a print or something, scheduling gets out of the silent map
          vim.schedule(function()
            vim.cmd.lua(table.concat(contents, '; '))
          end)
        end,
        context = function()
          local reg = vim.fn.getcmdline():match('^@([%w"%*%+/])$')
          return reg and lua_yank[reg]
        end,
        remap = true,
      }, { default = '<C-]><Cr>', silent = true })

      -- ===========================================================================
      -- Custom autopairs

      -- local ls = require('luasnip')
      -- local context = 'lazy("luasnip").in_snippet'

      -- Context for when a pair is allowed. Here, there is no next character
      -- (in other words the cursor is at the end of the line) or the next character
      -- is a non word character.
      local pair_allowed = function()
        return (text.next() or ' '):match('%W')
      end

      -- Double quotes have an additional requirement: the previous character
      -- must not be a word character. So we'll still be able to use single quotes
      -- in comments, for example.
      local quote_allowed = function()
        return (text.prev() or ' '):match('%W') and pair_allowed()
      end

      -- 'lhs' is provided in the environment of the function, makes reusing
      -- contexts based on the keymap straightforward
      local completing_pair = function()
        return text.next() == ctx.lhs
      end

      -- context for when the two surrounding characters are one of the pairs
      local re = vim.regex([[^\%(\V()\|{}\|[]\|''\|""\)]]) --[[@as vim.regex]]
      local res = vim.regex([[^\%(\V(  )\|{  }\|[  ]\|'  '\|"  "\)]]) --[[@as vim.regex]]
      local pat = { pre = [=[([%[{('"])%s+$]=], post = [=[^%s+([%]})'"])]=] }
      local in_pair = function()
        return (
          re:match_str(text.around_cursor(-1, 0) or '') or res:match_str(text.around_cursor(-2, 1) or '')
        )
      end

      local in_nlpair = function()
        local _, pre, post = text.lines_around(-1, 1)
        pre, post = pre:match(pat.pre), post:match(pat.post)
        return pre and post and re:match_str(pre .. post)
      end

      -- local make_pair = function(pair)
      --   local open, close = unpack(vim.split(pair, ''))
      --   return {
      --     rhs = function() ls.lsp_expand(('%s$1%s$0'):format(open, close)) end,
      --     rdesc = 'Insert snippet pair ' .. pair,
      --   }
      -- end

      local make_pair = function(pair)
        return {
          rhs = pair .. '<C-]><C-g>U<Left>',
          rdesc = 'Insert snippet pair ' .. pair,
        }
      end

      -- Set the keybinds to insert the pairs
      ctx.add_each({ 'i', 's' }, {
        ['('] = make_pair('()'),
        ['['] = make_pair('[]'),
        ['{'] = make_pair('{}'),
      }, pair_allowed, { cdesc = 'Nextchar != word char', clear = true })

      local right = '<C-]><C-g>U<Right>'
      -- Completing a pair is just tapping the <Right> key.
      -- Or, jumping out of the snippet with <Tab>
      -- But also I want abbrevs to trigger, so add that in with <C-]>
      ctx.add_each({ 'i', 's' }, {
        [')'] = right,
        [']'] = right,
        ['}'] = right,
        ['"'] = right,
        ["'"] = right,
      }, completing_pair, { clear = true })

      ctx.add_each({ 'i', 's' }, {
        ['"'] = make_pair('""'),
        ["'"] = make_pair("''"),
      }, quote_allowed) -- appends

      -- If we're inside a pair, <BS> to delete both, <Cr> to insert an
      -- set newline, and <Space> to insert two spaces.
      ctx.set({ 'i', 's' }, '<BS>', {
        { rhs = '<BS><Del>', context = in_pair },
        { rhs = '<C-o>vwhobld', context = in_nlpair },
      })

      ctx.set({ 'i', 's' }, '<Space>', { '  <C-g>U<Left>', in_pair }, { default = '<C-]> ' })
      -- mapping <space> removes its abbrev trigger, <C-]> forces it

      local pumvisible = function()
        return vim.fn.pumvisible() ~= 0
      end
      -- I don't want completion to modify my keybinds, so use a plug mapping and then
      -- do it myself. see completion.lua for <Plug>(miaConfirmCmp) definition
      -- Wrapping cmp.visible so it doesn't fully load here
      local blink_visible = function()
        return require('blink.cmp').is_visible()
      end
      ctx.set('i', '<Cr>', {
        { rhs = '<Plug>(miaCmpConfirm)', context = blink_visible },
        { rhs = '<C-y>', context = pumvisible },
        { rhs = '<Cr><C-c>O', context = in_pair },
      })
    end,
  },
}
