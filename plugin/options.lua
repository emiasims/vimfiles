-- settings that make a visual change, so do them immediately on starting.

local function _set(name, value)
  local ok, msg = pcall(function(n, v)
    vim.opt[n] = v
  end, name, value)
  if not ok then
    mia.err('Error setting option vim.opt[%s] = %s\n%s', vim.inspect(name), vim.inspect(value), msg)
  end
end

vim
  .iter({
    cmdheight = 1,
    colorcolumn = '80', -- must be string
    signcolumn = 'yes',
    number = true,
    relativenumber = true,
    showcmdloc = 'tabline',
    showtabline = 2,
    foldnestmax = 3,
    sessionoptions = { 'help', 'winsize', 'terminal', 'tabpages', 'skiprtp' },
    smoothscroll = true,

    synmaxcol = 200,
    report = 0,
    path = { '.', '**' },
    virtualedit = 'block',
    formatoptions = '1crlj',
    updatetime = 500,
    winaltkeys = 'no',
    viewoptions = { 'cursor', 'folds' },
    timeoutlen = 750,
    ttimeoutlen = 250, -- for key codes

    fileformats = { 'unix', 'dos', 'mac' },
    swapfile = false,
    shada = { "'300", '<500', 's100', 'h' },
    textwidth = 99,
    softtabstop = -1,
    tabstop = 2,
    shiftwidth = 2,
    matchtime = 3,
    breakat = '   ;:,!?',
    whichwrap = 'b,s,[,]',
    spellsuggest = { 'best', '10' },
    switchbuf = 'useopen',
    diffopt = { 'algorithm:histogram', 'linematch:60', 'closeoff' },
    -- completeopt = { 'menuone', 'noselect', 'noinsert' },
    completeopt = { 'menu', 'menuone', 'noselect' },
    clipboard = 'unnamed',
    shortmess = 'aAoOTIcF',
    scrolloff = 4,
    sidescrolloff = 2,
    pumheight = 20,
    cmdwinheight = 5,
    showbreak = '↘',
    wildmode = { 'longest:full', 'full' },
    wildignorecase = true,
    conceallevel = 2,
    foldlevelstart = 99,
    jumpoptions = 'stack',

    listchars = { nbsp = '⊗', tab = '▷‒', extends = '»', precedes = '«', trail = '⣿' },
    fillchars = { vert = '┃', fold = ' ' },

    undofile = true,
    shiftround = true,
    expandtab = true,
    ignorecase = true,
    smartcase = true,
    infercase = true,
    showmatch = true,
    linebreak = true,
    autowriteall = true,
    splitright = true,
    showfulltag = true,
    lazyredraw = true,
    cursorline = true,
    list = true,
    termguicolors = true,
    title = true,

    wrap = false,
    shell = 'bash',

    -- mostly default. cmdline vertical
    guicursor = { 'n-v:block', 'i-ci-ve-c:ver25', 'r-cr:hor20', 'o:hor50' },
  })
  :each(_set)

if vim.fn.executable('ag') == 1 then
  vim.opt.grepprg = 'ag --nogroup --nocolor'
end

-- backup stuff
if vim.env.SUDO_USER then
  vim.opt.shada = ''
  vim.opt.writebackup = false
else
  vim.opt.backupext = '.bak'
  -- vim.opt.patchmode = '.orig'
  vim.opt.backup = true

  -- default is ., and another. Remove .
  vim.opt.backupdir:remove('.')
  vim.fn.mkdir(vim.o.backupdir, 'p')

  -- now make sure it exists
  vim.opt.backupdir:append('.')
end

-- nvim uses modeline to set filetype for help.
-- I don't want modelines, so add a filetype for it
vim.schedule(function()
  vim.opt.modeline = false
  local is_text = require('vim.filetype.detect').txt
  local is_help = function(...)
    return is_text(...) or 'help'
  end
  vim.filetype.add({
    extension = { txt = is_help },
    pattern = { ['/doc/[^/]*%.txt$'] = is_help },
  })
end)

require('vim._extui').enable({})
