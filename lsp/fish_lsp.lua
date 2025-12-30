--- @type vim.lsp.Config
return {
  mason = { name = 'fish-lsp' },
  cmd = { 'fish-lsp', 'start' },
  filetypes = { 'fish' },
  root_markers = { 'config.fish', '.git' },
}
