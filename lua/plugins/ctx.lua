return {
  'milisims/ctx.nvim',
  dev = true,
  event = 'VeryLazy',

  config = function()
    local map = function(...) vim.keymap.set({ 'n', 'x', 'o' }, ...) end
    local ctx = require 'ctx'
    local text = require 'ctx.text'

    ctx.set({ 'n', 'x', 'o' }, '0', {
      {
        rhs = '0',
        context = function() return (text.around_cursor('^', -1) or ''):match '^%s+$' end,
        cdesc = 'Only whitespace before cursor',
        rdesc = 'Go to col 0',  -- doesn't work correctly
      },
      {
        rhs = 'g^',
        context = ctx.opt.wrap.on,
        cdesc = "'wrap' is set",
        rdesc = 'Go to start of wrapped line',
      },
    }, { default = '0^' })
    map('g0', '0')

    ctx.set({ 'n', 'o' }, '$', { 'g$', ctx.opt.wrap.on })
    ctx.add('x', '$', { 'g$h', ctx.opt.wrap.on }, { default = '$h', clear = true })
    map('g$', '$')

    -- Many keymaps in a specific context
    -- Result will be cnoreabbrev <expr> lhs <Plug>(map)
    ctx.add_each(
      'ca',
      {
        he = 'help',
        eft = 'EditFtplugin',
        eq = 'vsp|TSEditQuery highlights',
        eqa = 'vsp|TSEditQueryUserAfter highlights',
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
        hi = 'Telescope highlights',
        ev = 'Telescope fd cwd=' .. vim.fn.stdpath 'config',
        evp = 'Telescope fd cwd=' .. vim.fn.stdpath 'config' .. '/mia_plugins',
        evr = 'Telescope fd cwd=' .. vim.env.VIMRUNTIME,
        evs = 'Telescope fd cwd=' .. vim.fn.stdpath 'data' .. '/lazy',
        zo = 'lua require("mia.zotero").pick()',
        zc = 'lua require("mia.zotero").cite()',

        -- For fugitive.vim, from cmdline config abbreviations
        git = 'Git',
        gst = 'Telescope git_status',
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
      -- Basically, when a command can be completed, I want the above expansions
      function() return vim.fn.getcmdcompltype() == 'command' end,
      { clear = true, cdesc = 'At command line start' }
    )

    local function cmdline_is(opts)
      return {
        rhs = opts.rhs,
        context = function()
          local cmdline = vim.split(vim.fn.getcmdline(), ' ')
          -- Use getcmdpos() to get where we are instead of #cmdline?
          return vim.fn.getcmdcompltype() == 'command' and cmdline[#cmdline] == opts.context
        end,
        cdesc = ('command = "%s"'):format(opts.context),
      }
    end

    -- I want <Space> to expand an empty command line to 'lua ',
    -- ':eh' to ':edit (here)/' (no space!) and similar for 'vga'.
    -- mapping <Space> removes its ability to properly expand abbreviations, so add
    -- it back in by defaulting to '<C-]> ', forcing the expansion if one exists.
    ctx.set('c', ' ', {
      cmdline_is { rhs = 'lua ', context = '' },
      cmdline_is { rhs = '<C-]>', context = 'eh' },
      cmdline_is { rhs = '<C-]>', context = 'vga' },
      cmdline_is { rhs = '<C-]><C-w>', context = 'eq' },
      cmdline_is { rhs = '<C-]><C-w>', context = 'eqa' },
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
    local completing_pair = function()
      return text.next() == ctx.lhs
    end

    -- context for when the two surrounding characters are one of the pairs
    local re = vim.regex [[^\%(\V()\|{}\|[]\|''\|""\)]]
    local res = vim.regex [[^\%(\V(  )\|{  }\|[  ]\|'  '\|"  "\)]]
    local pat = { pre = [=[([%[{('"])%s+$]=], post = [=[^%s+([%]})'"])]=] }
    local in_pair = function()
      return (re:match_str(text.around_cursor(-1, 0) or '')
        or res:match_str(text.around_cursor(-2, 1) or ''))
    end

    -- cdesc = 'Inside pair'
    local in_nlpair = function()
      local _, pre, post = text.lines_around(-1, 1)
      pre, post = pre:match(pat.pre), post:match(pat.post)
      return pre and post and re:match_str(pre .. post)
    end
    -- cdesc = "Inside multiline pair"

    -- Set up undo-preserving <Left> and <Right>
    local left, right = '<C-g>U<Left>', '<C-g>U<Right>'

    -- Set the keybinds to insert the pairs
    ctx.add_each({ 'i', 's' }, {
      ['('] = '()' .. left,
      ['['] = '[]' .. left,
      ['{'] = '{}' .. left,
    }, pair_allowed, { cdesc = 'Nextchar != word char', clear = true })

    -- Completing a pair is just tapping the <Right> key.
    ctx.add_each({ 'i', 's' }, {
      [')'] = right,
      [']'] = right,
      ['}'] = right,
      ['"'] = right,
      ["'"] = right,
    }, completing_pair, { clear = true })

    ctx.add_each({ 'i', 's' }, {
      ['"'] = '""' .. left,
      ["'"] = "''" .. left,
    }, quote_allowed)  -- appends

    -- If we're inside a pair, <BS> to delete both, <Cr> to insert an
    -- set newline, and <Space> to insert two spaces.
    ctx.set({ 'i', 's' }, '<BS>', {
      { rhs = '<BS><Del>', context = in_pair },
      { rhs = '<C-o>vwhobld', context = in_nlpair },
    })

    ctx.set({ 'i', 's' }, '<Space>',
      { '  ' .. left, in_pair },
      { default = '<C-]> ' })
    -- mapping <space> removes its abbrev trigger, <C-]> forces it

    local pumvisible = function() return vim.fn.pumvisible() ~= 0 end
    -- I don't want cmp.nvim to modify my keybinds, so use a plug mapping and then
    -- do it myself. see completion.lua for <Plug>(miaConfirmCmp) definition
    -- Wrapping cmp.visible so it doesn't fully load here
    local cmp_visible = function() return require 'cmp'.visible() end
    ctx.set('i', '<Cr>', {
      { rhs = '<Plug>(miaConfirmCmp)', context = cmp_visible },
      { rhs = '<C-y>', context = pumvisible },
      { rhs = '<Cr><C-c>O', context = in_pair },
    })

    local ls = require 'luasnip'

    -- stylua: ignore
    ctx.add_each({ 'i', 's' }, {
      ['<Tab>'] = { function() ls.jump(1) end, rdesc = 'Jump to next node' },
      ['<S-Tab>'] = { function() ls.jump(-1) end, rdesc = 'Jump to previous node' },
    }, ls.in_snippet, { cdesc = 'in luasnip', clear = true })

    ctx.set('i', '<Esc>', { '<C-e>', pumvisible })
  end,
}
