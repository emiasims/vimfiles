local M = {}

local floor = math.floor

local function dec2rgb(dec)
  return floor(dec / 65536) / 255, floor(dec / 256) % 256 / 255, dec % 256 / 255
end

local function rgb2dec(r, g, b)
  return floor(r * 255) * 65536 + floor(g * 255) * 256 + floor(b * 255)
end

local function rgb2hsl(r, g, b)
  local max = math.max(r, g, b)
  local min = math.min(r, g, b)

  local c = max - min
  local l = (max + min) / 2
  local s = c / (1 - math.abs(2 * max - c - 1))

  local h
  if c == 0 then
    return 0, 0, l
  elseif max == r then
    h = (g - b) / c % 6
  elseif max == g then
    h = (b - r) / c + 2
  else
    h = (r - g) / c + 4
  end

  return h * 60, s, l
end

local function hsl2rgb(h, s, l)
  if s == 0 then
    return l, l, l -- achromatic
  end

  -- https://en.wikipedia.org/wiki/HSL_and_HSV#HSL_to_RGB

  -- if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
  local c = (1 - math.abs(2 * l - 1)) * s
  h = h / 60
  local x = c * (1 - math.abs(h % 2 - 1))

  -- local m = 0
  local m = l - c / 2 -- matches brightness
  c, x = c + m, x + m

  -- stylua: ignore start
  if h < 1 then return c, x, m
  elseif h < 2 then return x, c, m
  elseif h < 3 then return m, c, x
  elseif h < 4 then return m, x, c
  elseif h < 5 then return x, m, c
  end
  return c, m, x
  -- stylua: ignore end
end

local function desaturate(dec, sv, lv)
  local h, s, l = rgb2hsl(dec2rgb(dec))
  s = s * (1 - (sv or 0))
  l = l * (1 - (lv or 0))
  return rgb2dec(hsl2rgb(h, s, l))
end

local function build_desaturated_namespace()
  local ns = vim.api.nvim_create_namespace('mia-unfocus-colors')

  for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    if hl.fg or hl.bg then
      if hl.fg then
        hl.fg = desaturate(hl.fg, 0.15)
      end
      if hl.bg then
        hl.bg = desaturate(hl.bg, 0.15)
      end
      vim.api.nvim_set_hl(ns, name, hl)
    end
  end
  M.ns = ns
end

function M.winleave(window)
  if not M.ns then
    build_desaturated_namespace()
  end
  vim.api.nvim_win_set_hl_ns(window, M.ns)
end

function M.winenter(window)
  vim.api.nvim_win_set_hl_ns(window, 0)
end

local gid = vim.api.nvim_create_augroup('mia-colors', { clear = true })
vim.api.nvim_create_autocmd({ 'WinEnter', 'WinLeave' }, {
  group = gid,
  callback = function(ev)
    M[ev.event:lower()](vim.api.nvim_get_current_win())
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = gid,
  callback = function(ev)
    if M.ns then
      local hls = vim.api.nvim_get_hl(M.ns, {})
      for name, hl in pairs(hls) do
        vim.api.nvim_set_hl(M.ns, name, {})
      end
      M.ns = nil
    end
  end,
})

return M
