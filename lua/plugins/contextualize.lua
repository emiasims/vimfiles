return {
  'milisims/contextualize.nvim',
  dev = true,
  event = 'VeryLazy',

  config = function()
    local map = function(...) vim.keymap.set({ 'n', 'x', 'o' }, ...) end
    local ctx = require 'contextualize'
    local keymap = ctx.keymap
    local abbrev = ctx.abbrev
    -- local c = require('contextualize.contexts')
    local text = require 'contextualize.text'

    keymap.list({ 'n', 'x', 'o' }, '0', {
      {
        rhs = '0',
        context = function() return (text.around_cursor('^', -1) or ''):match('^%s+$') end,
        name = 'Only whitespace before cursor',
        -- desc = 'Go to col 0', -- doesn't work correctly
      },
      {
        rhs = 'g^',
        context = function() return vim.o.wrap end,
        name = "'wrap' is set",
        desc = 'Go to start of wrapped line',
      },
    }, { default = '0^' }) -- '0' scrolls to the far left, '^' goes to the first bit of text.
    map('g0', '0')

    keymap.set({ 'n', 'o' }, '$', 'g$', function() return vim.o.wrap end)
    keymap.set('x', '$', 'g$h', function() return vim.o.wrap end, { default = "$h" })
    map('g$', '$')

    -- Many keymaps in a specific context
    -- Result will be cnoreabbrev <expr> lhs <Plug>(map)
    abbrev.multi(
      'c',
      {
        he = 'help',
        eft = 'EditFtplugin',
        eq = 'EditQuery', -- mia.tslib
        ['e!'] = 'mkview | edit!',
        use = 'UltiSnipsEdit',
        ase = 'AutoSourceEnable',
        asd = 'AutoSourceDisable',
        sr = 'SetRepl',
        tr = 'TermRepl',
        vga = 'vimgrep // **/*.<C-r>=expand("%:e")<Cr><C-Left><Left><Left>',
        cqf = 'Clearqflist',
        w2 = 'w',
        dws = 'mkview | silent! %s/\\s\\+$// | loadview | update',
        eh = "edit <C-r>=expand('%:h')<Cr>/",
        T = "execute 'term fish'|startinsert<C-left><Right><Right><Right><Right>",
        term = 'term fish',
        f = 'Telescope fd',
        o = 'Telescope fd cwd=~/org',
        u = 'Telescope undo',
        l = 'Telescope buffers',
        t = 'Telescope tags',
        mr = 'Telescope oldfiles',
        A = 'Telescope live_grep',
        h = 'Telescope help_tags',
        ev = 'Telescope fd cwd=' .. vim.fn.stdpath 'config',
        evr = 'Telescope fd cwd=' .. os.getenv 'VIMRUNTIME',
        evs = 'Telescope fd cwd=' .. vim.fn.stdpath('data') .. '/lazy',
        zo = 'lua require("mia.zotero").pick()',
        zc = 'lua require("mia.zotero").cite()',
      },
      -- Basically, when a command can be completed, I want the above expansions
      function() return vim.fn.getcmdcompltype() == 'command' end
    )

    local function cmdline_is(str)
      return {
        function()
          local cmdline = vim.split(vim.fn.getcmdline(), ' ')
          -- Use getcmdpos() to get where we are instead of #cmdline
          return vim.fn.getcmdcompltype() == 'command' and cmdline[#cmdline] == str
        end,
        name = ('command = "%s"'):format(str),
      }
    end

    -- I want <Space> to expand an empty command line to 'lua ',
    -- ':eh' to ':edit (here)/' (no space!) and similar for 'vga'.
    -- mapping <Space> removes its ability to properly expand abbreviations, so add
    -- it back in by defaulting to '<C-]> ', forcing the expansion if one exists.
    keymap.list('c', ' ', {
      { rhs = 'lua ', context = cmdline_is '' },
      { rhs = '<C-]>', context = cmdline_is 'eh' },
      { rhs = '<C-]>', context = cmdline_is 'vga' },
    }, { default = '<C-]> ' })


    -- ===========================================================================
    -- Custom autopairs

    -- Context for when a pair is allowed. Here, there is no next character
    -- (in other words the cursor is at the end of the line) or the next character
    -- is a non word character.
    local pair_allowed = function()
      return (text.next() or ' '):match '%W'
    end

    -- Double quotes have an additional requirement: the previous character
    -- must not be a word character. So we'll still be able to use single quotes
    -- in comments, for example.
    local quote_allowed = function()
      return (text.prev() or ' '):match '%W' and pair_allowed()
    end

    -- 'lhs' is provided in the environment of the function, makes reusing
    -- contexts based on the keymap straightforward
    local completing_pair = {
      function()
        return text.next() == ctx.lhs -- if using fenv, lhs instead of context.lhs is fine.
      end,
      name = function() -- lhs can also be used in names
        return ('Nextchar == "%s"'):format(ctx.lhs)
      end,
    }

    -- context for when the two surrounding characters are one of the pairs
    local re = vim.regex [[^\%(\V()\|{}\|[]\|''\|""\)]]
    local within_pair = {
      function()
        return re:match_str(text.around_cursor(-1, 0) or '')
      end,
      name = 'Inside pair'
    }

    -- Set up undo-preserving <Left> and <Right>
    local left, right = '<C-g>U<Left>', '<C-g>U<Right>'

    -- Set the keybinds to insert the pairs
    keymap.multi({ 'i', 's' }, {
      ['('] = '()' .. left,
      ['['] = '[]' .. left,
      ['{'] = '{}' .. left,
    }, { pair_allowed, name = 'Nextchar != word char' })

    -- Completing a pair is just tapping the <Right> key.
    keymap.multi({ 'i', 's' }, {
      [')'] = right,
      [']'] = right,
      ['}'] = right,
      -- ['"'] = right,
      -- ["'"] = right,
    }, completing_pair)

    keymap.list({ 'i', 's' }, "'", {
      { right, completing_pair },
      { "''" .. left, quote_allowed }
    })

    keymap.list({ 'i', 's' }, '"', {
      { rhs = right, context = completing_pair },
      { rhs = '""' .. left, context = quote_allowed },
    })

    -- If we're inside a pair, <BS> to delete both, <Cr> to insert an
    -- additional newline, and <Space> to insert two spaces.
    keymap.set({ 'i', 's' }, '<BS>', { '<BS><Del>', desc = "Delete pair" }, within_pair)
    keymap.set({ 'i', 's' }, '<BS>', { '<BS><Del>', desc = "Delete pair" }, within_pair)
    keymap.set({ 'i', 's' }, '<Space>', '  ' .. left, within_pair, { default = '<C-]> ' })

    local pumvisible = { function() return vim.fn.pumvisible() ~= 0 end, name = 'pumvisible' }
    -- I don't want cmp.nvim to modify my keybinds, so use a plug mapping and then
    -- do it myself. see completion.lua for <Plug>(miaConfirmCmp) definition
    keymap.list('i', '<Cr>', {
      { rhs = '<Plug>(miaConfirmCmp)', context = require('cmp').visible },
      { rhs = '<C-y>', context = pumvisible },
      { rhs = '<Cr><C-c>O', context = within_pair },
    })

    local ls = require('luasnip')

    -- stylua: ignore
    keymap.multi({ 'i', 's' }, {
      ['<Tab>'] = { function() ls.jump(1) end, desc = 'Jump to next node', },
      ['<S-Tab>'] = { function() ls.jump(-1) end, desc = 'Jump to previous node', },
    }, ls.in_snippet, { name = 'in luasnip' })

    keymap.set('i', '<Esc>', '<C-e>', pumvisible)
  end
}
