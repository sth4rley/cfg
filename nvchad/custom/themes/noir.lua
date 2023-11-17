local M = {}

M.base_30 = {
  white = "#FFFFFF",
  darker_black = "#080808",
  black = "#121212", --  background das sugestoes/foreground do estado do editor!
  black2 = "#212121",
  one_bg = "#1c1c1c",
  one_bg2 = "#323232", -- bloco atual
  one_bg3 = "#ffff29",
  grey = "#363636",
  grey_fg = "#404040",
  grey_fg2 = "#4a4a4a",
  light_grey = "#525252",
  red = "#a7a7a7", -- msm green
  baby_pink = "#a72e5b",
  pink = "#ff75a0",
  line = "#1d1d1d", -- for lines like vertsplit
  green = "#a7a7a7", -- msm red
  vibrant_green = "#b9e75b",
  nord_blue = "#ff0088", -- !
  blue = "#25B0BC",
  seablue = "#169AC9",
  yellow = "#fdb830",
  sun = "#ffc038",
  purple = "#da70d6",
  dark_purple = "#ffffff", -- insert !
  teal = "#749689",
  orange = "#FFA500",
  cyan = "#6BE4E6",
  statusline_bg = "#212121", -- noir ok
  lightbg = "#323232", -- noir ok
  pmenu_bg = "#15bf84",
  folder_bg = "#0ff200",
}

M.base_16 = {
  base00 = "#121212", -- NOIR OK -- BG !
  base01 = "#2121ff", -- NOIR OK * debug1
  base02 = "#323232", -- NOIR OK * debug1 -- selecao !
  base03 = "#ff5353", -- NOIR OK * debug2
  base04 = "#ff7373", -- NOIR OK * debug2
  base05 = "#d5d5d5", -- NOIR OK * debug3 -- comando incompleto/comandos !
  base06 = "#a7ffa7", -- NOIR OK * debug3
  base07 = "#f5f5f5", -- NOIR OK * debug4 -- "box do autocomplete" !
  base08 = "#d5d5d5", -- Confirmed: Variables Confirmed !
  base09 = "#ff0088", -- Confirmed: Integers, Booleans !
  base0A = "#909090", -- Classes/declaracao de variavel !
  base0B = "#ff0088", -- Confirmed: Strings !
  base0C = "#d5d5d5", -- Escape characters, Regular expressions, {} (em lua) ! 
  base0D = "#d5d5d5", -- Functions, Methods, (.log(), nome da constant no js) !
  base0E = "#909090", -- Confirmed: Keywords, Storage, Selector, Markup (local do lua) ! 
  base0F = "#a7a7a7", -- Deprecated, Opening/Closing embedded language tags debug4 / \n !
}

M.type = "dark"

M = require("base46").override_theme(M, "noir")

return M
