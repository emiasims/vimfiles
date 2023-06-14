vim.g['sneak#label'] = 1
vim.g['sneak#absolute_dir'] = 1
vim.g['sneak#use_ic_scs'] = 1

local keys = {}
for c in ('fFtTsS'):gmatch('.') do
  for m in ('nxo'):gmatch('.') do
    keys[#keys+1] = { c, '<Plug>Sneak_' .. c, mode = m }
  end
end

return {
  'justinmk/vim-sneak',
  keys = keys,
  config = function()
  end
}
