local modes = {
  n          = { "NORMAL",    "StlModeN" },
  no         = { "NORMAL",    "StlModeN" },
  v          = { "VISUAL",    "StlModeV" },
  V          = { "V-LINE",    "StlModeV" },
  ["\22"]    = { "V-BLOCK",   "StlModeV" },
  s          = { "SELECT",    "StlModeV" },
  S          = { "S-LINE",    "StlModeV" },
  i          = { "INSERT",    "StlModeI" },
  ic         = { "INSERT",    "StlModeI" },
  R          = { "REPLACE",   "StlModeR" },
  Rv         = { "V-REPLACE", "StlModeR" },
  c          = { "COMMAND",   "StlModeC" },
  cv         = { "EX",        "StlModeC" },
  r          = { "PROMPT",    "StlModeC" },
  rm         = { "MORE",      "StlModeC" },
  ["r?"]     = { "CONFIRM",   "StlModeC" },
  ["!"]      = { "SHELL",     "StlModeT" },
  t          = { "TERMINAL",  "StlModeT" },
}

return function()
  local win = vim.g.statusline_winid or 0
  local buf = vim.api.nvim_win_get_buf(win)
  local ft  = vim.bo[buf].filetype

  if ft == "NvimTree" then
    return "%#StlBase#  File Explorer"
  end

  -- Mode
  local m         = vim.api.nvim_get_mode().mode
  local mode_info = modes[m] or { m:upper(), "StlModeN" }
  local stl       = "%#" .. mode_info[2] .. "#  " .. mode_info[1] .. " %#StlBase#"

  -- Git branch ()
  local branch = vim.b[buf].gitsigns_head
  if branch and branch ~= "" then
    stl = stl .. "   " .. branch .. " "
  end

  -- Filename ()
  local name  = vim.api.nvim_buf_get_name(buf)
  name        = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
  local flags = (vim.bo[buf].modified and " ●" or "") .. (vim.bo[buf].readonly and "  " or "")
  stl         = stl .. "   " .. name .. flags

  -- Right side
  stl = stl .. "%="

  -- Diagnostics (  )
  local counts = { 0, 0, 0, 0 }
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    counts[d.severity] = counts[d.severity] + 1
  end
  if counts[1] > 0 then stl = stl .. "%#StlDiagError#  " .. counts[1] .. " " end
  if counts[2] > 0 then stl = stl .. "%#StlDiagWarn#  " .. counts[2] .. " " end
  if counts[3] > 0 then stl = stl .. "%#StlDiagInfo#  " .. counts[3] .. " " end

  -- Filetype + position ( )
  stl = stl .. "%#StlRight#"
  if ft ~= "" then stl = stl .. "   " .. ft end
  stl = stl .. "   %l:%c "

  return stl
end
