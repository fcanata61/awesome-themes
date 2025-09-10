
-- █▀█ ▄▀█ █░░ █▀▀ ▀█▀ ▀█▀ █▀▀    █▀▀ █▀▀ █▄░█ █▀▀ █▀█ ▄▀█ ▀█▀ █ █▀█ █▄░█ 
-- █▀▀ █▀█ █▄▄ ██▄ ░█░ ░█░ ██▄    █▄█ ██▄ █░▀█ ██▄ █▀▄ █▀█ ░█░ █ █▄█ █░▀█ 

local clrutils = require("utils.color")

return function(theme, style)
  local cscheme = require("theme.colorschemes."..theme..".".. style)

  -- Generate 7 primary colors
  local pbase = cscheme.primary.base

  -- For light-theme colorschemes, dark/light are inverted.
  local darken   = cscheme.type == "dark" and clrutils.darken or clrutils.lighten
  local lighten  = cscheme.type == "dark" and clrutils.lighten or clrutils.darken

  cscheme.primary[900] = darken(pbase, 0.54)
  cscheme.primary[800] = darken(pbase, 0.48)
  cscheme.primary[700] = darken(pbase, 0.32)
  cscheme.primary[600] = darken(pbase, 0.16)
  cscheme.primary[500] = pbase
  cscheme.primary[400] = lighten(pbase, 0.16)
  cscheme.primary[300] = lighten(pbase, 0.32)
  cscheme.primary[200] = lighten(pbase, 0.48)
  cscheme.primary[100] = lighten(pbase, 0.54)

  -- Generate 9 neutral colors
  local ndark  = cscheme.neutral.dark
  local nlight = cscheme.neutral.light
  local nbase  = cscheme.neutral.base or clrutils.blend(ndark, nlight)

  cscheme.neutral[900] = ndark
  cscheme.neutral[700] = clrutils.blend(ndark, nbase)
  cscheme.neutral[500] = nbase
  cscheme.neutral[300] = clrutils.blend(nbase, nlight)
  cscheme.neutral[100] = nlight

  cscheme.neutral[800] = clrutils.blend(ndark, cscheme.neutral[700])
  cscheme.neutral[600] = clrutils.blend(cscheme.neutral[700], nbase)
  cscheme.neutral[400] = clrutils.blend(cscheme.neutral[300], nbase)
  cscheme.neutral[200] = clrutils.blend(nlight, cscheme.neutral[300])

  -- Generate 5 reds
  local red_base = cscheme.colors.red

  cscheme.red      = {}
  cscheme.red[500] = darken(red_base, 0.3)
  cscheme.red[400] = darken(red_base, 0.15)
  cscheme.red[300] = red_base
  cscheme.red[200] = lighten(red_base, 0.15)
  cscheme.red[100] = lighten(red_base, 0.3)

  -- Generate 5 greens
  local green_base = cscheme.colors.green

  cscheme.green = {}
  cscheme.green[500] = darken(green_base, 0.3)
  cscheme.green[400] = darken(green_base, 0.15)
  cscheme.green[300] = green_base
  cscheme.green[200] = lighten(green_base, 0.15)
  cscheme.green[100] = lighten(green_base, 0.3)

  -- Generate 5 yellows
  local yellow_base = cscheme.colors.yellow

  cscheme.yellow = {}
  cscheme.yellow[500] = darken(yellow_base, 0.3)
  cscheme.yellow[400] = darken(yellow_base, 0.15)
  cscheme.yellow[300] = yellow_base
  cscheme.yellow[200] = lighten(yellow_base, 0.15)
  cscheme.yellow[100] = lighten(yellow_base, 0.3)

  function cscheme.random_accent_color()
    local i = math.random(1, #cscheme.accents)
    return cscheme.accents[i]
  end

  return cscheme
end
