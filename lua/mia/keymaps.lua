require 'astronauta.keymap'

local nnoremap = vim.keymap.nnoremap

nnoremap { '<F5>', '<Cmd>update|mkview|edit|TSBufEnable highlight<Cr>' }
