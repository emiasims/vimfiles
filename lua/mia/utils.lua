local M = { _required = {} }

local function doglobal(global, name, suffix, printme)
  local tmp = require(name)
  for _,part in ipairs(vim.fn.split(suffix, '\\.')) do
    tmp = tmp[part]
  end

  if printme and suffix == '' then
    print(string.format('%s = require("%s")', global, name))
  elseif printme then
    print(string.format('%s = require("%s").%s', global, name, suffix))
  end

  _G[global] = tmp
  end

-- Acts like global = require(name)[sfx1][sfx2][...]
-- Where the sfxn are just split(suffix, '\.')
-- Makes reloading globals possible
function requireas(global, name, suffix)
  local suffix = suffix or ''
  doglobal(global, name, suffix)

  if M._required[name] == nil then M._required[name] = {} end
  M._required[name][global] = suffix
end

function reload(name)
  package.loaded[name] = nil
  require(name)
  print(string.format('Sourced: require("%s")', name))
  if M._required[name] == nil then return end
  for global,suffix in pairs(M._required[name]) do
    doglobal(global, name, suffix, true)
  end
end

function P(v)
  print(vim.inspect(v))
  return v
end

return M
