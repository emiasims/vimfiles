---@type vim.lsp.Config
return {
  mason = true,
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
  settings = { organizeImports = false },
  -- disable ruff as hover provider to avoid conflicts with pyright
  on_attach = function(client)
    client.server_capabilities.hoverProvider = false
  end,
}
