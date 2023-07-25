local group_names = {
  'Comment', 'Constant', 'String', 'Character', 'Number', 'Boolean', 'Float',
  'Identifier', 'Function', 'Statement', 'Conditional', 'Repeat', 'Label',
  'Operator', 'Keyword', 'Exception', 'PreProc', 'Include', 'Define', 'Macro',
  'PreCondit', 'Type', 'StorageClass', 'Structure', 'Typedef', 'Special',
  'SpecialChar', 'Tag', 'Delimiter', 'SpecialComment', 'Debug', 'Underlined',
  'Ignore', 'Error', 'Todo',
}

-- Shouldn't this be done already? idk why it isn't
for _, name in ipairs(group_names) do
  nvim.set_hl(0, '@' .. name:lower(), { link = name, default = true })
end
