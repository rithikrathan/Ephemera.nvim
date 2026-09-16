--  STATUSLINE
-- ============================================================================
-- ============================================================================

-- --- 1. LEFT INFO SECTION (WITH FILETYPE MAP) ---
local ft_map = {
    -- ["oil"]             = { name = "Explorer", icon = "", color = "#fabd2f" },
    ["oil"]             = { name = "Explorer", icon = "📂", color = "#fabd2f" },
    ["run"]     = { name = "Run", icon = "", color = "#09a409" },
    -- ["compilation"]     = { name = "Compilation", icon = "", color = "#09a409" },
    ["fzf"]             = { name = "Fuzzy Find", icon = "꩜ ", color = "#fabd2f" },
    ["qf"]              = { name = "Quickfix", icon = "🔧", color = "#fabd2f" },
    ["aerial"]          = { name = "Aerial", icon = "𑣲𝑨", color = "#fabd2f" },
    ["TelescopePrompt"] = { name = "Telescope", icon = "🔭", color = "#83a598" },
    ["alpha"]           = { name = "Dashboard", icon = "󰕮", color = "#d3869b" }, -- what is this???
    ["tabBar"]           = { name = "Tabs", icon = "󰕮", color = "#fb4934" },
    ["checkhealth"]     = { name = "Health", icon = "✚", color = "#fb4934" },
    ["lazy"]            = { name = "Lazy", icon = "🦦", color = "#8ec07c" },
    ["mason"]           = { name = "Mason", icon = "🧱", color = "#b8bb26" },
    ["help"]            = { name = "Help", icon = "󰋖", color = "#d3869b" },
    ["scratch"]         = { name = "ScratchPad", icon = "📝", color = "#ff9966" },
    ["note"]            = { name = "NotePad", icon = "📑", color = "#ff9966" },
    ["Reference"]       = { name = "Reference", icon = "📓", color = "#ff9966" },
    ["gnote"]           = { name = "Global_Note", icon = "📑", color = "#ff9966" },
    -- NOTE:these are search and command in text buffer  so we can use
    -- vim motions not to be confused with the lsp stuffs
    ["bufcmd"]          = { name = "Command", icon = "</>", color = "#09a409" },
    ["bufsearch"]       = { name = "Search", icon = "🔍", color = "#0990a2" },
}

_G.git_branch = ""

function _G.EphemeraStatusLine()
    local width        = vim.o.columns
    local show_right   = width >= 70
    local show_full    = width >= 90

    -- 1. LEFT SIDE: Mode, Git, File
    local left_core    = Modules.render_left_core()
    local left_extra   = "%#SlRef#" .. (_G.statusMessage or "")

    -- 2. MIDDLE: Animation / Static Decor
    local middle_part  = (_G.AnimState.output or "")

    -- 3. RIGHT SIDE: Stats & Additional
    local stat_content = Modules.stat_section()
    local add_content  = Modules.get_additional_section()

    local right_part   = stat_content .. " " .. add_content .. " "

    -- Final Assembly
    if not show_right then return left_core end
    if not show_full then return left_core .. "%=" .. right_part end

    return left_core .. left_extra .. "%=" .. middle_part .. "%=" .. right_part
end

vim.opt.statusline = "%!v:lua.EphemeraStatusLine()"

-- ============================================================================
--  MODULE DEFINITIONS
-- ============================================================================
_G.Modules = {}

-- --- HELPER: DYNAMIC HIGHLIGHT BRIDGE ---
-- Creates a highlight group where FG comes from 'fg_group' and BG comes from 'bg_group'
function Modules.set_bridge_hl(name, fg_group, bg_group, is_sep)
    local fg_data = vim.api.nvim_get_hl(0, { name = fg_group, link = false })
    local bg_data = vim.api.nvim_get_hl(0, { name = bg_group, link = false })

    local opts = { bg = bg_data.bg }
    if is_sep then
        opts.fg = fg_data.bg -- For separators: Previous BG becomes Current FG
    else
        opts.fg = fg_data.fg -- For text: Keep FG, adopt new BG
    end

    vim.api.nvim_set_hl(0, name, opts)
    return name
end

function Modules.render_left_core()
    local m, state, label = vim.fn.mode(), "Norm", "NORMAL"
    if m == 'i' then
        state, label = "Ins", "INSERT"
    elseif m:match("^[vV\22]") then
        state, label = "Vis", "VISUAL"
    elseif m == 'c' then
        state, label = "Command", "COMMAND"
    elseif m == 'R' then
        state, label = "Ins", "REPLACE"
    elseif m == 't' then
        state, label = "Command", "TERMINAL"
    end

    -- 1. MODE OVERRIDE
    local is_custom = false

    -- Pre-calculate multicursor status
    local mc_ns = vim.api.nvim_get_namespaces()["multiple-cursors"]

    -- Plugin 1: Standard Namespace/Extmark approach
    local has_extmark_cur = mc_ns and (#vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, {}) > 0)

    -- Plugin 2: jake-stewart/multicursor.nvim
    local jake_ok, jake_api = pcall(require, "multicursor-nvim")
    local has_jake_cur = jake_ok and jake_api.hasCursors()

    -- The unified boolean for your statusline
    local has_multicursor = has_extmark_cur or has_jake_cur

    if vim.g.read_mode then
        label, state = "READ", "Read"
        is_custom = true
    elseif vim.b.venn_enabled then
        label, state = "VENN", "Venn"
        is_custom = true
    elseif has_multicursor then
        label, state = "MULTI_CURSOR", "Mul"
        is_custom = true
    end

    -- Define highlight group names
    local mode_group    = "Mode" .. state
    local mid_sep_group = "Sep" .. state .. "A"

    -- logic fix: use "InfoNorm" or "InfoVis" for custom modes instead of "InfoVenn"
    local info_state    = is_custom and (m:match("^[vV\22]") and "Vis" or "Norm") or state
    local info_group    = "Info" .. info_state
    local end_sep_group = "Sep" .. info_state .. "Trans"

    -- DYNAMICALLY CREATE SEPARATOR HIGHLIGHTS
    -- 1. Bridge Custom Mode -> Standard Info (Transitions from VENN/MULTI colors to Normal/Visual colors)
    Modules.set_bridge_hl(mid_sep_group, mode_group, info_group, true)

    -- 2. Bridge Standard Info -> StatusBody
    Modules.set_bridge_hl(end_sep_group, info_group, "StatusBody", true)

    -- Construct the Mode Block
    local mode_block = string.format(
        "%%#%s# %s %%#%s#",
        mode_group, label, mid_sep_group
    )

    local branch = (_G.git_branch ~= "") and (_G.git_branch .. "┆ ") or " "
    local mod = vim.bo.modified and " 𔒝 " or ""

    local filename_text, icon, icon_hl = "", "", info_group
    local ft = vim.bo.filetype
    local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

    if ft_map[ft] then
        local entry = ft_map[ft]
        filename_text = entry.name
        icon = entry.icon
        -- Manual Icon Highlight
        local mode_bg = vim.api.nvim_get_hl(0, { name = info_group }).bg
        vim.api.nvim_set_hl(0, "SlCustomIcon" .. ft, { fg = entry.color, bg = mode_bg, bold = true })
        icon_hl = "SlCustomIcon" .. ft
    else
        local fname = vim.fn.expand("%:t")
        filename_text = (fname == "") and "[No Name]" or fname
        if devicons_ok then
            local d_icon, d_hl = devicons.get_icon(fname, vim.fn.expand("%:e"), { default = true })
            icon = d_icon or ""
            local d_hl_data = vim.api.nvim_get_hl(0, { name = d_hl or "" })
            local mode_bg = vim.api.nvim_get_hl(0, { name = info_group }).bg
            vim.api.nvim_set_hl(0, "SlIcon" .. (d_hl or "Def"), { fg = d_hl_data.fg, bg = mode_bg, bold = true })
            icon_hl = "SlIcon" .. (d_hl or "Def")
        else
            icon = "📜"
        end
    end

    local icon_comp = "%#" .. icon_hl .. "#" .. icon .. "%#" .. info_group .. "# "
    local info_content = (branch ~= " ") and (branch .. icon_comp .. filename_text ) or
        (" " .. icon_comp .. filename_text)

    return table.concat({
        mode_block,
        "%#" .. info_group .. "#" .. info_content .. mod .. "%r ",
        "%#" .. end_sep_group .. "# %#StatusBody#"
    })
end

-- function Modules.render_left_core()
-- 	local m, state, label = vim.fn.mode(), "Norm", "NORMAL"
-- 	if m == 'i' then
-- 		state, label = "Ins", "INSERT"
-- 	elseif m:match("^[vV\22]") then
-- 		state, label = "Vis", "VISUAL"
-- 	elseif m == 'c' then
-- 		label = "COMMAND"
-- 	elseif m == 'R' then
-- 		label = "REPLACE"
-- 	elseif m == 't' then
-- 		label = "TERMINAL"
-- 	end

-- 	-- 1. MODE OVERRIDE
-- 	if vim.b.venn_enabled then
-- 		label, state = "VENN", "Venn"
-- 	else
-- 		local mc_ns = vim.api.nvim_get_namespaces()["multiple-cursors"]
-- 		if mc_ns and #vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, {}) > 0 then
-- 			label, state = "MULTI_CURSOR", "Mul"
-- 		end
-- 	end

-- 	-- Define highlight group names
-- 	local mode_group    = "Mode" .. state
-- 	local info_group    = "Info" .. state
-- 	local mid_sep_group = "Sep" .. state .. "A"     -- The separator after the label ()
-- 	local end_sep_group = "Sep" .. state .. "Trans" -- The separator at the end ()

-- 	-- DYNAMICALLY CREATE SEPARATOR HIGHLIGHTS
-- 	-- 1. Bridge Mode -> Info (This fixes the first separator )
-- 	Modules.set_bridge_hl(mid_sep_group, mode_group, info_group, true)

-- 	-- 2. Bridge Info -> StatusBody (This fixes the tail )
-- 	Modules.set_bridge_hl(end_sep_group, info_group, "StatusBody", true)

-- 	-- Construct the Mode Block with the correct separator highlight
-- 	local mode_block = string.format(
-- 		"%%#%s# %s %%#%s#",
-- 		mode_group, label, mid_sep_group
-- 	)

-- 	local branch = (_G.git_branch ~= "") and (_G.git_branch .. "┆ ") or " "
-- 	local mod = vim.bo.modified and " 𔒝 " or ""

-- 	local filename_text, icon, icon_hl = "", "", info_group
-- 	local ft = vim.bo.filetype
-- 	local devicons_ok, devicons = pcall(require, "nvim-web-devicons")

-- 	if ft_map[ft] then
-- 		local entry = ft_map[ft]
-- 		filename_text = entry.name
-- 		icon = entry.icon
-- 		-- Manual Icon Highlight
-- 		local mode_bg = vim.api.nvim_get_hl(0, { name = info_group }).bg
-- 		vim.api.nvim_set_hl(0, "SlCustomIcon" .. ft, { fg = entry.color, bg = mode_bg, bold = true })
-- 		icon_hl = "SlCustomIcon" .. ft
-- 	else
-- 		local fname = vim.fn.expand("%:t")
-- 		filename_text = (fname == "") and "[No Name]" or fname
-- 		if devicons_ok then
-- 			local d_icon, d_hl = devicons.get_icon(fname, vim.fn.expand("%:e"), { default = true })
-- 			icon = d_icon or ""
-- 			local d_hl_data = vim.api.nvim_get_hl(0, { name = d_hl or "" })
-- 			local mode_bg = vim.api.nvim_get_hl(0, { name = info_group }).bg
-- 			vim.api.nvim_set_hl(0, "SlIcon" .. (d_hl or "Def"), { fg = d_hl_data.fg, bg = mode_bg, bold = true })
-- 			icon_hl = "SlIcon" .. (d_hl or "Def")
-- 		else
-- 			icon = "📜"
-- 		end
-- 	end

-- 	local icon_comp = "%#" .. icon_hl .. "#" .. icon .. "%#" .. info_group .. "# "
-- 	local info_content = (branch ~= " ") and (branch .. icon_comp .. filename_text) or
-- 		(" " .. icon_comp .. filename_text)

-- 	return table.concat({
-- 		mode_block,
-- 		"%#" .. info_group .. "#" .. info_content .. mod .. "%r ",
-- 		"%#" .. end_sep_group .. "# %#StatusBody#"
-- 		-- "%#" .. sep_group .. "# %#StatusBody#"
-- 		-- "%#" .. sep_group .. # %#StatusBody#"
-- 	})
-- end

-- --- 2. STAT SECTION ---
_G.StatState = { mode = 1 }

function Modules.stat_section()
    local mode = _G.StatState and _G.StatState.mode or 1

        if mode == 1 then     -- position and percentage
            local tab_disp = ""
            if vim.fn.tabpagenr("$") > 1 and _G.tabName then
                tab_disp = "󰓩 " .. _G.tabName()
            end
            local tab_part = (tab_disp ~= "") and ("  " .. tab_disp) or ""
            return  "%l:%c %p%% " .. tab_part

    elseif mode == 2 then -- diagnostics
        -- Patch Diagnostic Highlights
        Modules.set_bridge_hl("SlDiagErr", "DiagnosticError", "StatusBody", false)
        Modules.set_bridge_hl("SlDiagWarn", "DiagnosticWarn", "StatusBody", false)

        local err  = Modules.get_diag(vim.diagnostic.severity.ERROR) or 0
        local warn = Modules.get_diag(vim.diagnostic.severity.WARN) or 0
        return string.format(" %%#SlDiagErr#✖ %d %%#SlDiagWarn#⚠ %d %%#StatusBody#", err, warn)
    elseif mode == 3 then -- current language server connected
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        local lsp_name = (clients and #clients > 0) and clients[1].name or "❌"
        return "🖧 " .. lsp_name .. ""
    elseif mode == 4 then -- filetype
        return " %y "
    end
    return ""
end

-- --- 3. ADDITIONAL SECTION ---
_G.AddState = { mode = 1, key_log = { "   ", "   ", "   ", "   " } }

function Modules.get_harpoon_tabs()
    local harpoon_ok, harpoon = pcall(require, "harpoon")
    if not harpoon_ok then return " Harpoon? " end

    local items = harpoon:list().items
    local current_path = vim.fn.expand("%:p")
    local output = ""

    -- 1. Capture Dynamic Colors
    local m = vim.fn.mode()
    local state = "Norm"
    if m == 'i' then
        state = "Ins"
    elseif m:match("^[vV\22]") then
        state = "Vis"
    elseif m:match("c") then
        state =
        "Command"
    end

    -- Get the actual color values
    local mode_data = vim.api.nvim_get_hl(0, { name = "Mode" .. state, link = false })
    local body_data = vim.api.nvim_get_hl(0, { name = "StatusBody", link = false })

    vim.api.nvim_set_hl(0, "SlHarpoonActive", {
        fg = mode_data.fg,
        bg = mode_data.bg,
        bold = true,
        italic = true
    })

    vim.api.nvim_set_hl(0, "SlHarpoonActiveBars", {
        fg = mode_data.bg, -- shape color
        bg = body_data.bg, -- outside background
        bold = true,
        italic = true
    })

    for i = 1, 4 do
        local item = items[i]
        local label = "-"
        local is_active = false

        if item and item.value then
            if vim.fn.fnamemodify(item.value, ":p") == current_path then
                is_active = true
            end

            -- Truncate filename
            local fname = vim.fn.fnamemodify(item.value, ":t")
            label = #fname > 7 and (fname:sub(1, 5) .. "..") or fname
        end

        if is_active then
            local L = ""
            local R = ""
            -- local R = ""❯❯❯❯
            local display = string.format("%d.%s", i, label)

            -- Active: Bars use SlHarpoonActiveBars, Text uses SlHarpoonActive
            output = output .. string.format(
                " %%#SlHarpoonActiveBars#%s%%#SlHarpoonActive#%s%%#SlHarpoonActiveBars#%s%%#StatusBody#",
                L, display, R
            )
        else
            output = output .. string.format(" %d.%s", i, label)
        end
    end
    return "" .. output
end

function Modules.get_additional_section()
    local mode = _G.AddState and _G.AddState.mode or 1

    if mode == 1 then     -- harpoon buffer marks
        return Modules.get_harpoon_tabs()
    elseif mode == 2 then -- key logger, meh not the perfect
        local log = (_G.AddState and _G.AddState.key_log) or { "   ", "   ", "   ", "   " }
        Modules.set_bridge_hl("SlRose", "keyword", "StatusBody", false)
        local rose_group = "SlRose"
        return string.format("┆ %%#%s#%s%%#StatusBody# %s %s %s ", rose_group, log[1], log[2], log[3], log[4])
    elseif mode == 3 then -- date and time
        return os.date("┆ %a %b %d %I:%M %p")
    end
    return ""
end

-- --- 4. KEY LOGGER ENGINE ---
local key_aliases = {
    ["<BSLASH>"] = "Bsl",
    ["\\"] = "Bsl",
    ["<SPACE>"] = "Spc",
    [" "] = "Spc",
    ["<CR>"] = "Ret",
    ["<TAB>"] = "Tab",
    ["<ESC>"] = "Esc",
    ["<BS>"] = "Bks",
    ["<UP>"] = " Up",
    ["<DOWN>"] = "Dwn",
    ["<LEFT>"] = "Lft",
    ["<RIGHT>"] = "Rgt"
}

vim.on_key(function(char)
    if not char then return end
    local raw = vim.fn.keytrans(char)
    if raw == "" or raw == "<Ignore>" then return end

    local clean = key_aliases[raw:upper()] or raw
    if not key_aliases[raw:upper()] then
        clean = clean:gsub("<", ""):gsub(">", ""):gsub("C%-", "^"):gsub("M%-", "A-")
    end
    if #clean > 3 then clean = clean:sub(1, 3) end
    clean = string.format("%3s", clean)

    table.remove(_G.AddState.key_log)
    table.insert(_G.AddState.key_log, 1, clean)

    if _G.AddState.mode == 2 then
        vim.schedule(function() pcall(vim.cmd, "redrawstatus") end)
    end
end, vim.api.nvim_create_namespace("EphemeraKeyLogger"))

-- --- 5. ANIMATION & DECOR ENGINE ---
local frames = { " ₍^. .^₎⟆ ", " ₍^. .^₎  ", " ⟅₍^. .^₎ ", " ₍^. .^₎  " }
local static_txt = {
    "꧁  ✧ 🌹✧ ꧂", " ꧁  ⎝𓆩༺  ✧ ༻  𓆪⎠꧂  ", " ˗ˏˋ 💤 ˎˊ˗ ",
    "────୨ৎ────", " ─── ★ ─── ", "  ( ˘ ³˘)♥ ",
    "· · ─ ·𖥸· ─ · ·", "ﮩ٨ـﮩﮩ٨ـ 🌹 ﮩ٨ـﮩﮩﮩ٨ـ", "╭∩╮( •̀_•́ )╭∩╮"
}

_G.AnimState = {
    output = static_txt[1],
    idx = 1,
    timer = vim.loop.new_timer(),
    augroup = vim.api.nvim_create_augroup("StatusAnim", { clear = true })
}

local function tick()
    _G.AnimState.idx = (_G.AnimState.idx % #frames) + 1
    _G.AnimState.output = frames[_G.AnimState.idx]
    vim.cmd("redrawstatus")
end

function _G.SetAnimMode(arg)
    local parts = vim.split(arg or "", " ", { trimempty = true })
    local mode = parts[1] or "static"
    local val = tonumber(parts[2])

    -- Cleanup
    _G.AnimState.timer:stop()
    vim.api.nvim_clear_autocmds({ group = _G.AnimState.augroup })

    if mode == "time" then
        _G.AnimState.timer:start(0, val or 200, vim.schedule_wrap(tick))
    elseif mode == "input" then
        _G.AnimState.output = frames[1]
        vim.api.nvim_create_autocmd({ "CursorMoved", "InsertCharPre" }, {
            group = _G.AnimState.augroup, callback = tick
        })
    elseif mode == "static" then
        _G.AnimState.output = static_txt[val or 1] or static_txt[1]
        vim.cmd("redrawstatus")
    end
end

vim.api.nvim_create_user_command("SlAnimMode", function(o) _G.SetAnimMode(o.args) end, {
    nargs = 1,
    complete = function() return { "time", "input", "static" } end
})

-- --- 6. UTILS, GIT & BINDINGS ---
function Modules.get_diag(severity)
    if vim.diagnostic.get_count then return vim.diagnostic.get_count(0, { severity = severity }) end
end

local function update_git()
    vim.system({ "git", "branch", "--show-current" }, { text = true }, function(out)
        vim.schedule(function()
            if out.code == 0 then
                local b = vim.trim(out.stdout)
                _G.git_branch = (b ~= "") and ("   " .. b .. " ") or ""
            else
                _G.git_branch = ""
            end
            vim.cmd("redrawstatus")
        end)
    end)
end

update_git()
vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, { callback = update_git })

function Modules.toggle_stat()
    local modes = 5
    _G.StatState.mode = (_G.StatState.mode % modes) + 1
    vim.cmd("redrawstatus")
end

function Modules.toggle_add()
    -- Cycles: 1=Clock, 2=Keys, 3=Harpoon
    local modes = 4
    _G.AddState.mode = (_G.AddState.mode % modes) + 1
    vim.cmd("redrawstatus")
end

vim.keymap.set("n", "\\", Modules.toggle_stat, { silent = true })
vim.keymap.set("n", "|", Modules.toggle_add, { silent = true })
