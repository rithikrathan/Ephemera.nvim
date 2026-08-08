local M = {}

local ns = vim.api.nvim_create_namespace("EphemeraReadMode")
local augroup = vim.api.nvim_create_augroup("EphemeraReadMode", { clear = true })
local saved_guicursor = nil
local mark_ids = {}

local function update_virtual_lines()
  if not vim.g.read_mode then return end

  local buf = vim.api.nvim_get_current_buf()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1

  for _, id in ipairs(mark_ids) do
    pcall(vim.api.nvim_buf_del_extmark, buf, ns, id)
  end
  mark_ids = {}

  local above_id = vim.api.nvim_buf_set_extmark(buf, ns, math.max(0, cursor_line - 1), 0, {
    virt_lines = {{{""}}},
    virt_text_pos = "overlay",
    hl_mode = "combine",
  })
  table.insert(mark_ids, above_id)

  local below_id = vim.api.nvim_buf_set_extmark(buf, ns, cursor_line, 0, {
    virt_lines = {{{""}}},
    virt_text_pos = "overlay",
    hl_mode = "combine",
  })
  table.insert(mark_ids, below_id)

  vim.cmd("redrawstatus")
end

function M.enable()
  if vim.g.read_mode then return end
  vim.g.read_mode = true

  saved_guicursor = vim.opt.guicursor:get()
  vim.opt.guicursor = "n:hor20,i:hor20,v:hor50,r:hor50"

  vim.b._read_mode_saved_modifiable = vim.bo.modifiable
  vim.bo.modifiable = false

  local colors = require("Ephemera.colorScheme").config.colors

  vim.api.nvim_set_hl(0, "CursorLine", { fg = colors.bool , bg = colors.cursorline })

  update_virtual_lines()

  vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    callback = update_virtual_lines,
  })

  vim.api.nvim_create_autocmd("InsertEnter", {
    group = augroup,
    callback = function()
      if vim.g.read_mode then
        vim.notify("Editing disabled in Read Mode", vim.log.levels.WARN)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    callback = function()
      if vim.g.read_mode then
        vim.notify("Writing disabled in Read Mode", vim.log.levels.WARN)
        vim.v.errmsg = "Writing disabled in Read Mode"
        return true
      end
    end,
  })

  vim.cmd("redrawstatus")
end

function M.disable()
  if not vim.g.read_mode then return end
  vim.g.read_mode = false

  if saved_guicursor then
    vim.opt.guicursor = saved_guicursor
    saved_guicursor = nil
  end

  if vim.b._read_mode_saved_modifiable ~= nil then
    vim.bo.modifiable = vim.b._read_mode_saved_modifiable
    vim.b._read_mode_saved_modifiable = nil
  end

  mark_ids = {}
  vim.api.nvim_clear_autocmds({ group = augroup })
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    pcall(vim.api.nvim_buf_clear_namespace, buf, ns, 0, -1)
  end

  require("Ephemera.colorScheme").setup(require("Ephemera.themes.current").name)

  vim.cmd("redrawstatus")
end

function M.toggle()
  if vim.g.read_mode then
    M.disable()
    vim.cmd("LockIn")
  else
    M.enable()
    vim.cmd("LockIn")
  end
end

return M
