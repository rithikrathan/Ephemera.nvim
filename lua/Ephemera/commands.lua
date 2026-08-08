-- ============================================================================
--  AUTOCOMMANDS
-- ============================================================================

-- 1. FILETYPE DETECTION (Single Autocommand Table)
local ft_map = {
  sv    = "systemverilog",
  v     = "verilog",
  pyde  = "python",
  pde   = "processing",
  -- pde   = "java",
  l     = "c",
  y     = "c",
  gnote = "gnote",
}

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = vim.tbl_map(function(ext) return "*." .. ext end, vim.tbl_keys(ft_map)),
  callback = function(opts)
    local ext = vim.fn.fnamemodify(opts.file, ":e")
    if ft_map[ext] then
      vim.bo.filetype = ft_map[ext]
    end
  end,
})

-- vennvim
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:[vV]",
  callback = function()
    if vim.b.venn_enabled then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-v>", true, false, true), "n", false)
    end
  end,
})

-- 2. GENERAL UTILITIES (Yank, Reload, Netrw)
vim.api.nvim_create_user_command("ReloadConfig", function()
  vim.cmd("source $MYVIMRC")
  print("Configuration Reloaded.")
end, {})

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank { higroup = "IncSearch", timeout = 120 }
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "netrw",
  callback = function()
    -- Backup Keybind
    vim.keymap.set("n", "<leader>d", function()
      local dir = vim.b.netrw_curdir
      local target = vim.fn.expand("<cfile>")
      if target ~= "" then
        vim.fn.system({ "cp", "-r", dir .. "/" .. target, dir .. "/" .. target .. ".bak" })
        vim.cmd("edit " .. vim.fn.fnameescape(dir))
        print("Backup created.")
      end
    end, { buffer = true, remap = false })

    -- Copy Path Keybind
    vim.keymap.set('n', '<C-P>', function()
      local path = vim.fn.fnamemodify(vim.b.netrw_curdir .. "/" .. vim.fn.expand('<cfile>'), ':.')
      print(path)
      vim.fn.setreg('+', path)
    end, { buffer = true })
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "csv",
  callback = function()
    vim.cmd("CsvViewToggle delimiter=, display_mode=border header_lnum=1")
  end
})


-- 3. STATUSLINE RESTORATION (Fixes "White Bar" & Missing Statusline)
local window_fixes = {
  ["FileType"] = { "qf", "undotree", "diff", "help", "man" },
  ["TermOpen"] = { "*" },
  ["User"]     = { "FzfStatusLine" },
}

for event, patterns in pairs(window_fixes) do
  vim.api.nvim_create_autocmd(event, {
    pattern = patterns,
    callback = function()
      vim.opt_local.statusline = "%!v:lua.EphemeraStatusLine()"
    end,
  })
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.opt_local.statusline = "%!v:lua.EphemeraStatusLine()"
  end,
})

-- Banner highlight (buffer-scoped decorations — no per-redraw cost)
-- _G.EphemeraBannerNS = vim.api.nvim_create_namespace("EphemeraBanner")
-- 
-- local function highlight_banner_lines(buf)
--   local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
--   for i, line in ipairs(lines) do
--     if line:match("%s*%S*%s*=-=-=-=-=-=-=-= %[.*%] =-=-=-=-=-=-=-=") then
--       vim.api.nvim_buf_add_highlight(buf, _G.EphemeraBannerNS, "EphemeraBanner", i - 1, 0, -1)
--     end
--   end
-- end
-- 
-- vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
--   callback = function(args)
--     if vim.bo[args.buf].buftype ~= "" then return end
--     highlight_banner_lines(args.buf)
--   end,
-- })

-- ============================================================================
--  USER DEFINED COMMANDS:
-- ============================================================================
-- set tab size
vim.api.nvim_create_user_command("SetTabs", function()
  -- Ask the user for a number
  vim.ui.input({ prompt = "Tabs → " }, function(input)
    local n = tonumber(input)
    if not n or n <= 0 then
      vim.notify("❌  Invalid number", vim.log.levels.ERROR)
      return
    end
    -- Apply the value to the relevant options
    vim.opt.tabstop    = n
    vim.opt.shiftwidth = n
    vim.opt.expandtab  = true -- optional, leave tabs as spaces
    -- vim.notify("⏱  Tab size set to " .. n, vim.log.levels.INFO)
  end)
end, {})

-- Setstatus
_G.statusMessage = ""
local last_recorded_symbol = ""

local status_lookup = {
  wtf = "what the fuck mate",
  ok = "All systems operational",
  error = "Critical failure detected",
  busy = "Working on it..."
}

local function useAerial()
  local has_aerial, aerial = pcall(require, "aerial")
  if not has_aerial then return end

  local output = ""

  if aerial.get_location then
    local symbols = aerial.get_location(true)
    if symbols and #symbols > 0 then
      local s = symbols[#symbols]
      local icon = s.icon or s.kind

      -- Bridged to your AerialSymbolsl group
      -- output = "%#AerialSymbolsl#" .. icon .. "%#StatusBody# " .. s.name
      output = string.format("%%#AerialSymbolsl#%s%%#StatusBody# %s", icon, s.name)
    end
    -- elseif aerial.get_status then
    --     output = aerial.get_status() or ""
  end

  if output == last_recorded_symbol then return end

  _G.statusMessage = output
  last_recorded_symbol = output
  vim.cmd("redrawstatus")
end

vim.api.nvim_create_user_command('SetStatus', function(opts)
  local mode, payload = opts.args:match("^(%S+)%s*(.*)$")

  pcall(vim.api.nvim_del_augroup_by_name, "StatusSmartUpdate")

  if mode == "text" then
    _G.statusMessage = payload
    vim.cmd("redrawstatus")
  elseif mode == "msg" then
    local msg = status_lookup[payload]
    if msg then
      _G.statusMessage = msg
      vim.cmd("redrawstatus")
    end
  elseif mode == "aerial" then
    last_recorded_symbol = ""
    useAerial()

    local group = vim.api.nvim_create_augroup("StatusSmartUpdate", { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorHold", "BufEnter", "InsertLeave" }, {
      group = group,
      callback = useAerial
    })
  end
end, {
  nargs = '+',
  complete = function(ArgLead, CmdLine)
    local args = vim.split(CmdLine, "%s+")
    if #args == 2 then return { "text", "msg", "aerial" } end
    if #args == 3 and args[2] == "msg" then return vim.tbl_keys(status_lookup) end
  end
})

-- clear buffers in the harpoon list
vim.api.nvim_create_user_command('HarpoonClr', function()
  local has_harpoon, harpoon = pcall(require, "harpoon")
  if not has_harpoon then
    print("Harpoon not found")
    return
  end
  harpoon:list():clear()
  print("󰀱 Harpoon list nuked.")
end, { desc = "Clear all buffers from Harpoon list" })

-- close all buffers that are open and not in harpoon list

vim.api.nvim_create_user_command('HarpoonOnly', function()
  local has_harpoon, harpoon = pcall(require, "harpoon")
  if not has_harpoon then
    print("Harpoon not found")
    return
  end

  local harpoon_list = harpoon:list()
  local harpoon_files = {}

  -- 1. Create a lookup table of files in Harpoon
  for _, item in ipairs(harpoon_list.items) do
    -- Store the absolute path to ensure accurate comparison
    local full_path = vim.fn.fnamemodify(item.value, ":p")
    harpoon_files[full_path] = true
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local buffers = vim.api.nvim_list_bufs()
  local closed_count = 0

  -- 2. Iterate and compare
  for _, bufnr in ipairs(buffers) do
    if vim.api.nvim_buf_is_loaded(bufnr) and bufnr ~= current_buf then
      local buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")

      -- If the buffer is NOT in Harpoon and NOT modified
      if not harpoon_files[buf_path] then
        if not vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
          vim.api.nvim_buf_delete(bufnr, { force = false })
          closed_count = closed_count + 1
        end
      end
    end
  end

  print(string.format("󰀱 Kept Harpoon buffers. Closed %d others.", closed_count))
end, { desc = "Close all buffers not marked in Harpoon" })

-- Lock the cursorline to the center like a typewriter
vim.api.nvim_create_user_command('LockIn', function()
  local current_scrolloff = vim.opt.scrolloff:get()

  if current_scrolloff < 999 then
    vim.opt.scrolloff = 999
    print("Cursor Locked: Center")
  else
    vim.opt.scrolloff = 5
    print("Cursor Unlocked")
  end
end, { desc = "Toggle typewriter-style center cursor lock" })

vim.api.nvim_create_user_command('ToggleStatusLine', function()
  if vim.opt.laststatus:get() == 0 then
    vim.opt.laststatus = 3
    print("Statusline visible")
  else
    vim.opt.laststatus = 0
    print("Statusline hidden")
  end
end, { desc = 'Toggle the status line on and off' })


---=-=-=-=-=-=-=-=-=-=-= [AUTOOCOMANDS] =-=-=-=-=-=-=-=-=--
-- Force compilation buffer to the far right
vim.api.nvim_create_autocmd("FileType", {
  pattern = "compilation",
  callback = function()
    vim.cmd("wincmd L")
    vim.api.nvim_win_set_width(0, 65)     -- Adjust '50' to your preferred width
  end,
})

-- disable figet
vim.api.nvim_create_user_command('UnFiget', function()
  require("fidget").notification.toggle()
end, { desc = "disable the fige notification" })

vim.api.nvim_create_user_command('Ephemera', function(opts)
  local subcmd = opts.fargs[1]

  if subcmd == "theme" then
    require("Ephemera.custom.themePicker").open()
  elseif subcmd == "header" then
    require("Ephemera.custom.header").add()
  elseif subcmd == "updateHeader" then
    require("Ephemera.custom.header").update()
  else
    vim.notify("Unknown subcommand: " .. subcmd, vim.log.levels.WARN)
  end
end, {
  nargs = "*",
  complete = function(_, cmd)
    return vim.tbl_filter(function(s) return s:find("^" .. cmd) end, { "theme", "header", "updateHeader" })
  end,
  desc = "Ephemera commands",
})

-- Toggle Read Mode
vim.api.nvim_create_user_command('ToggleReadMode', function()
  require("Ephemera.custom.readMode").toggle()
end, { desc = "Toggle Read Mode (focus reading dense paragraphs)" })

-- LiveTerminal session

_G.MyTermChannel = nil
_G.MyTermCmd = nil
_G.MyTermBuf = nil

vim.api.nvim_create_user_command("LiveTerm", function()
  vim.ui.input({ prompt = "Command: " }, function(input)
    if not input or input == "" then return end
    _G.MyTermCmd = input

    vim.cmd("vsplit | term")
    _G.MyTermBuf = vim.api.nvim_get_current_buf()
    _G.MyTermChannel = vim.b.terminal_job_id

    vim.cmd("wincmd p")

    local function run_and_pin()
      if not _G.MyTermChannel or not vim.api.nvim_buf_is_valid(_G.MyTermBuf) then return end

      pcall(vim.fn.chansend, _G.MyTermChannel, "\x03")

      vim.defer_fn(function()
        if not _G.MyTermChannel or not vim.api.nvim_buf_is_valid(_G.MyTermBuf) then return end

        local start_line = vim.api.nvim_buf_line_count(_G.MyTermBuf)

        pcall(vim.fn.chansend, _G.MyTermChannel, _G.MyTermCmd .. "\r")

        vim.defer_fn(function()
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == _G.MyTermBuf then
              pcall(vim.api.nvim_win_set_cursor, win, { start_line, 0 })
              vim.api.nvim_win_call(win, function()
                vim.cmd("normal! zt")
              end)
            end
          end
        end, 50)
      end, 100)
    end

    run_and_pin()

    vim.api.nvim_create_augroup("LiveTermGroup", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "QuickFixCmdPost" }, {
      group = "LiveTermGroup",
      pattern = "*",
      callback = run_and_pin,
    })
  end)
end, {})

-- buffCommandModes
vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = vim.api.nvim_create_augroup("MinimalCmdWin", { clear = true }),
  pattern = "*",
  callback = function(args)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(args.buf) then
        vim.api.nvim_win_set_height(0, 1)
        vim.cmd("normal! G")
        vim.cmd("startinsert!")
      end
    end)

    -- 1. Identify the window type (':', '/', or '?')
    local cmd_type = args.match

    -- 2. Assign distinct filetypes based on the type
    if cmd_type == ":" then
      vim.bo[args.buf].filetype = "bufcmd"
    elseif cmd_type == "/" or cmd_type == "?" then
      vim.bo[args.buf].filetype = "bufsearch"
    end

    -- Window styling
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"

    vim.keymap.set("n", "<Esc>", "<Cmd>q<CR>", { buffer = args.buf, silent = true })
    vim.keymap.set("i", "<Esc>", "<Esc><Cmd>q<CR>", { buffer = args.buf, silent = true })
  end,
})

