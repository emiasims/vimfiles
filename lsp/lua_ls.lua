--- @type vim.lsp.Config
return {
  mason = { name = 'lua-language-server', tools = { 'stylua' } },
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    '.emmyrc.json',
    '.luarc.json',
    '.luarc.jsonc',
    '.luacheckrc',
    '.stylua.toml',
    'stylua.toml',
    'selene.toml',
    'selene.yml',
    '.git',
  },
  settings = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      hint = { enable = true },
      codelens = { enable = true },
      format = {
        enable = false, -- TODO true
        defaultConfig = { -- must be strings
          -- see https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
          indent_size = '2',
          quote_style = 'single',
          trailing_table_separator = 'smart',
          align_continuous_assign_statement = 'false',
          align_continuous_rect_table_field = 'false',
          align_array_table = 'false',
          space_before_inline_comment = '2',
        },
      },
    },
  },
}
