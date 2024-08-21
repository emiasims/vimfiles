local settings = {
  report = 0,
  path = { '.', '**' },
  virtualedit = 'block',
  formatoptions = '1crlj',
  updatetime = 500,
  winaltkeys = 'no',
  viewoptions = { 'folds', 'cursor', 'slash', 'unix' },
  timeoutlen = 750,
  ttimeoutlen = 250, -- for key codes

  fileformats = { 'unix', 'dos', 'mac' },
  swapfile = false,
  shada = { "'300", '<10', '@50', 's100', 'h' },
  textwidth = 99,
  softtabstop = 2,
  tabstop = 2,
  shiftwidth = 2,
  matchtime = 3,
  breakat = '   ;:,!?',
  whichwrap = 'b,s,[,]',
  spellsuggest = { 'best', '10' },
  switchbuf = 'useopen',
  diffopt = { 'algorithm:histogram', 'filler', 'closeoff' },
  -- completeopt = { 'menuone', 'noselect', 'noinsert' },
  completeopt = { 'menu', 'menuone', 'noselect' },
  clipboard = 'unnamed',
  shortmess = 'aAoOTIcF',
  scrolloff = 4,
  sidescrolloff = 2,
  showtabline = 2,
  pumheight = 20,
  cmdheight = 1,
  cmdwinheight = 5,
  colorcolumn = '80', -- must be string
  signcolumn = 'yes',
  showbreak = '↘',
  wildmode = { 'longest:full', 'full' },
  conceallevel = 2,
  foldlevelstart = 99,
  foldnestmax = 3,
  jumpoptions = 'stack',

  listchars = { nbsp = '⊗', tab = '▷‒', extends = '»', precedes = '«', trail = '•' },
  fillchars = { vert = '┃', fold = ' ' },

  undofile = true,
  shiftround = true,
  expandtab = true,
  ignorecase = true,
  smartcase = true,
  infercase = true,
  wildignorecase = true,
  showmatch = true,
  linebreak = true,
  autowriteall = true,
  splitright = true,
  showfulltag = true,
  number = true,
  relativenumber = true,
  -- lazyredraw = true,
  cursorline = true,
  list = true,
  termguicolors = true,

  showcmdloc = 'tabline',

  sessionoptions = { 'blank', 'buffers', 'folds', 'tabpages', 'winsize', 'terminal' },

  wrap = false,
  shell = 'bash',

  foldmethod = 'expr',
  foldexpr = 'v:lua.vim.treesitter.foldexpr()',
  foldtext = [[v:lua.require'mia.fold'.text()]],

  -- mostly default. cmdline vertical
  guicursor = { 'n-v:block', 'i-ci-ve-c:ver25', 'r-cr:hor20', 'o:hor50' },
}

vim.iter(settings):each(function(name, value)
  vim.opt[name] = value
end)

if vim.fn.executable('ag') then
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
vim.opt.modeline = false
local is_text = require('vim.filetype.detect').txt
local is_help = function(...)
  return is_text(...) or 'help'
end
vim.filetype.add({
  extension = { txt = is_help },
  pattern = { ['/doc/[^/]*%.txt$'] = is_help },
})
