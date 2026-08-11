local M = {}

local TAB_WIDTH = 45
local CARD_LINES = 6

local TAB_ICON = "󰓩"
local HSPLIT_ICON = "⇅ "
local VSPLIT_ICON = "⇄ "
local FLOAT_ICON = "󰊕 "

M.win = nil
M.buf = nil
M.prev_win = nil
M.ns = nil
M.enabled = false
M.seen = {}
M.cursor_line = nil

_G.tabName = function(tabnr)
    tabnr = tabnr or vim.api.nvim_tabpage_get_number(0)
    local label = vim.fn.gettabvar(tabnr, "label", "")
    if label ~= "" then return label end
    return "tab" .. tabnr
end

local HL = {
    Active = "EphemeraTabActive",
    Inactive = "Constant",
    Icon = "EphemeraTabIcon",
    Count = "EphemeraTabCount",
    File = "EphemeraTabIcon",
    New = "EphemeraTabCount",
    Border = "EphemeraTabBorder",
}

local function apply_hls()
    local function fg(group)
        local hl = vim.api.nvim_get_hl(0, { name = group })
        return hl.fg or "NONE"
    end

    local grey = fg("Comment")
    local red = fg("DiagnosticError")

    vim.api.nvim_set_hl(0, HL.Active, { fg = red, bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, HL.Icon, { fg = grey, bg = "NONE" })
    vim.api.nvim_set_hl(0, HL.Count, { fg = grey, bg = "NONE" })
    vim.api.nvim_set_hl(0, HL.Border, { fg = fg("FloatBorder"), bg = "NONE" })
end

local function card_geometry()
    local width = math.min(TAB_WIDTH, math.max(1, vim.o.columns - 6))
    local height = math.min(CARD_LINES + 2, math.max(1, vim.o.lines - vim.o.cmdheight - 5))
    local col = math.max(0, math.floor((vim.o.columns - width) / 2))
    local bottom = vim.o.lines - vim.o.cmdheight - 4
    local row = math.max(0, math.min(bottom - height + 1, vim.o.lines - height - 1))
    return { width = width, height = height, col = col, row = row }
end

local function split_width()
    return math.max(8, math.floor(card_geometry().width / 2))
end

local function trunc_to(s, width)
    if vim.fn.strdisplaywidth(s) <= width then return s end
    local out, w = "", 0
    for c in s:gmatch("[^\128-\191]") do
        local cw = vim.fn.strdisplaywidth(c)
        if w + cw > width then break end
        out, w = out .. c, w + cw
    end
    return out
end

local function tabpage_of(tabnr)
    for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
        if vim.api.nvim_tabpage_get_number(tp) == tabnr then return tp end
    end
    return nil
end

local function normal_windows(tabnr)
    local tp = tabpage_of(tabnr)
    if not tp then return {} end
    local wins = {}
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tp)) do
        local cfg = vim.api.nvim_win_get_config(w)
        if cfg.relative == "" and not (M.win and vim.api.nvim_win_is_valid(M.win) and w == M.win) then
            wins[#wins + 1] = w
        end
    end
    return wins
end

local function split_counts(tabnr)
    local h, v = 0, 0
    local normal = normal_windows(tabnr)
    for i = 1, #normal do
        for j = i + 1, #normal do
            local pi = vim.api.nvim_win_get_position(normal[i])
            local pj = vim.api.nvim_win_get_position(normal[j])
            if pi[1] == pj[1] then v = v + 1 end -- same row -> side by side (vsplit)
            if pi[2] == pj[2] then h = h + 1 end -- same col -> stacked (hsplit)
        end
    end
    return h, v
end

local function float_count(tabnr)
    local tp = tabpage_of(tabnr)
    if not tp then return 0 end
    local n = 0
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tp)) do
        local cfg = vim.api.nvim_win_get_config(w)
        if cfg.relative ~= "" and vim.api.nvim_win_get_buf(w) ~= M.buf then
            n = n + 1
        end
    end
    return n
end

local function tab_file(tabnr)
    local normal = normal_windows(tabnr)
    local tp = tabpage_of(tabnr)
    local win = normal[1] or (tp and vim.api.nvim_tabpage_get_win(tp))
    if not win then return "" end
    local fname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
    return (fname ~= "") and vim.fn.fnamemodify(fname, ":t") or "[No Name]"
end

local function file_icon(fname)
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if not ok then return "📜" end
    local icon = devicons.get_icon(fname, vim.fn.fnamemodify(fname, ":e"), { default = true })
    if not icon then return "📜" end
    return icon
end

local function render()
    local buf = M.buf
    if not (buf and vim.api.nvim_buf_is_valid(buf)) then return end

    local tab_count = vim.fn.tabpagenr("$")
    local current = vim.api.nvim_tabpage_get_number(0)
    local pad = (M.mode == "split") and split_width() or TAB_WIDTH
    local narrow = card_geometry().width < 45

    local name_cap = pad - 8
    local names = {}
    local max_name = 0
    for t = 1, tab_count do
        local name = _G.tabName(t)
        if tab_count > 1 and t == current then name = "[" .. name .. "]" end
        local short = name
        if vim.fn.strdisplaywidth(" " .. name) > name_cap then
            short = trunc_to(name, math.max(1, name_cap - 1))
        end
        names[t] = short
        max_name = math.max(max_name, vim.fn.strdisplaywidth(short))
    end
    local name_col = max_name + 2

    local lines, marks = {}, {}

    for t = 1, tab_count do
        local active = t == current
        local short_name = names[t]
        local name_w = vim.fn.strdisplaywidth(short_name)

        local toks, w = {}, 0
        local function add(text, hl)
            toks[#toks + 1] = { text = text, hl = hl }
            w = w + vim.fn.strdisplaywidth(text)
        end

        add(" ")
        -- add(TAB_ICON, HL.Icon)
        add(TAB_ICON, active and HL.Active or HL.Inactive)
        add(" " .. short_name, active and HL.Active or HL.Inactive)

        if M.mode ~= "split" and not narrow then
            add(string.rep(" ", name_col - name_w))

            local h, v = split_counts(t)
            if h > 0 then
                add(HSPLIT_ICON, HL.Icon)
                add(tostring(h), HL.Count)
            end
            if v > 0 then
                add(" ")
                add(VSPLIT_ICON, HL.Icon)
                add(tostring(v), HL.Count)
            end

            local nf = float_count(t)
            if nf > 0 then
                add(" ")
                add(FLOAT_ICON, HL.Icon)
                add(tostring(nf), HL.Count)
            end

            local avail = pad - w - 1
            if avail >= 2 then
                local fname = tab_file(t)
                local ficon = file_icon(fname)
                local iconw = vim.fn.strdisplaywidth(ficon)
                if avail >= 2 + iconw then
                    add(" ")
                    add(ficon, HL.Icon)
                    add(" ")
                    add(trunc_to(fname, avail - 2 - iconw), HL.File)
                end
            end
        end

        local body, row_marks = "", {}
        for _, tok in ipairs(toks) do
            if tok.hl then row_marks[#row_marks + 1] = { #body, #tok.text, tok.hl } end
            body = body .. tok.text
        end

        local text = body .. string.rep(" ", pad - vim.fn.strdisplaywidth(body))

        lines[#lines + 1] = text
        local segs = {}
        for _, s in ipairs(row_marks) do segs[#segs + 1] = s end
        marks[#marks + 1] = segs
    end

    local new_text = "[+] new tab"
    lines[#lines + 1] = new_text
    marks[#marks + 1] = { { 0, #new_text, HL.New } }

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
    for line_idx, segs in ipairs(marks) do
        for _, seg in ipairs(segs) do
            vim.api.nvim_buf_set_extmark(buf, M.ns, line_idx - 1, seg[1], {
                end_row = line_idx - 1,
                end_col = seg[1] + seg[2],
                hl_group = seg[3],
            })
        end
    end

    return tab_count, current
end

local function act_on_line(line)
    local tab_count = vim.fn.tabpagenr("$")
    M.cursor_line = line
    if line <= tab_count then
        vim.cmd(line .. "tabnext")
    elseif line == tab_count + 1 then
        vim.cmd("tabnew")
        render()
    end
end

local function close_tab_at(line)
    local tab_count = vim.fn.tabpagenr("$")
    if line <= tab_count and tab_count > 1 then
        local choice = vim.fn.confirm("Close tab " .. _G.tabName(line) .. "?", "&Yes\n&No", 2)
        if choice ~= 1 then return end
        if line <= vim.fn.tabpagenr("$") and vim.fn.tabpagenr("$") > 1 then
            vim.cmd(line .. "tabclose")
            render()
        end
    end
end

local function set_tab_label(tabnr, name)
    vim.api.nvim_tabpage_set_var(tabnr, "label", name)
    render()
    vim.cmd("redrawstatus")
end

function M.rename(tabnr, name)
    if not name then
        vim.ui.input({ prompt = "Rename tab " .. tabnr .. ": ", default = _G.tabName(tabnr) }, function(input)
            if input == nil then return end
            set_tab_label(tabnr, input)
        end)
    else
        set_tab_label(tabnr, name)
    end
end

local function setup_buffer(buf)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].buflisted = false
    vim.bo[buf].modifiable = false
    vim.bo[buf].swapfile = false
    vim.bo[buf].undolevels = -1

    vim.keymap.set("n", "<CR>", function()
        act_on_line(vim.api.nvim_win_get_cursor(0)[1])
    end, { buffer = buf, desc = "Select/new tab" })

    vim.keymap.set("n", "<LeftMouse>", function()
        local pos = vim.fn.getmousepos()
        if pos and pos.winid == vim.api.nvim_get_current_win() then
            vim.api.nvim_win_set_cursor(0, { pos.line, math.max(pos.column - 1, 0) })
            act_on_line(pos.line)
        end
    end, { buffer = buf, desc = "Click tab bar" })

    vim.keymap.set("n", "x", function()
        close_tab_at(vim.api.nvim_win_get_cursor(0)[1])
    end, { buffer = buf, desc = "Close tab under cursor" })

    vim.keymap.set("n", "r", function()
        local line = vim.api.nvim_win_get_cursor(0)[1]
        if line <= vim.fn.tabpagenr("$") then M.rename(line) end
    end, { buffer = buf, desc = "Rename tab" })

    vim.keymap.set("n", "q", function() M.close() end, { buffer = buf, desc = "Close tab bar" })
    vim.keymap.set("n", "<Esc>", function() M.close() end, { buffer = buf, desc = "Close tab bar" })

    vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = buf,
        callback = function()
            if M.buf == vim.api.nvim_get_current_buf() then
                M.cursor_line = vim.api.nvim_win_get_cursor(0)[1]
            end
        end,
    })

    for _, key in ipairs({ "i", "a", "I", "A", "o", "O", "R", "s", "S", "c", "C", "d", "D", "X", "p", "P" }) do
        vim.keymap.set("n", key, "<Nop>", { buffer = buf })
    end
end

local function tabbar_win_in(tabpage)
    if not (M.buf and vim.api.nvim_buf_is_valid(M.buf)) then return nil end
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        if vim.api.nvim_win_get_buf(w) == M.buf then return w end
    end
    return nil
end

local function apply_win_opts(win, mode)
    vim.api.nvim_win_call(win, function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
        vim.opt_local.cursorline = true
        vim.opt_local.scrolloff = 0
        vim.opt_local.winhighlight = (mode == "split") and ("WinSeparator:" .. HL.Border) or ("FloatBorder:" .. HL.Border)
    end)
end

local function open_win_in_tab(tabpage, mode)
    local win
    if mode == "split" then
        local cur = vim.api.nvim_get_current_tabpage()
        if cur ~= tabpage then
            vim.cmd("noau tabnext " .. vim.api.nvim_tabpage_get_number(tabpage))
        end
        vim.cmd("noau vertical topleft 1split")
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, M.buf)
        vim.api.nvim_win_set_width(win, split_width())
        vim.opt_local.winfixwidth = true
        if cur ~= tabpage then
            vim.cmd("noau tabnext " .. vim.api.nvim_tabpage_get_number(cur))
        end
    else
        local g = card_geometry()
        win = vim.api.nvim_open_win(M.buf, false, {
            relative = "editor",
            row = g.row,
            col = g.col,
            width = g.width,
            height = g.height,
            style = "minimal",
            border = "single",
            focusable = true,
        })
    end
    apply_win_opts(win, mode)
    return win
end

local function focus_bar(tabpage, opts)
    opts = opts or {}
    local win = tabbar_win_in(tabpage) or open_win_in_tab(tabpage, M.mode)
    M.win = win
    local tab_count, current = render()
    vim.api.nvim_set_current_win(win)
    if opts.preserve and M.cursor_line then
        vim.api.nvim_win_set_cursor(win, { math.min(M.cursor_line, tab_count), 0 })
    else
        vim.api.nvim_win_set_cursor(win, { math.min(current, math.max(tab_count, 1)), 0 })
    end
    return win
end

function M.close()
    M.enabled = false
    if M.buf and vim.api.nvim_buf_is_valid(M.buf) then
        for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
            local win = tabbar_win_in(tp)
            if win then pcall(vim.api.nvim_win_close, win, true) end
        end
    end

    local prev = M.prev_win
    M.win, M.buf, M.prev_win, M.mode = nil, nil, nil, nil
    M.seen = {}
    M.cursor_line = nil

    if prev and vim.api.nvim_win_is_valid(prev) then
        if vim.api.nvim_win_get_tabpage(prev) == vim.api.nvim_get_current_tabpage() then
            pcall(vim.api.nvim_set_current_win, prev)
        end
    end
end

function M.open(mode)
    mode = mode or "float"
    if M.enabled then
        if M.mode == mode then
            M.close()
            return
        end
        M.close()
    end

    apply_hls()
    M.prev_win = vim.api.nvim_get_current_win()
    M.buf = vim.api.nvim_create_buf(false, true)
    M.ns = vim.api.nvim_create_namespace("EphemeraTabBar")
    setup_buffer(M.buf)
    M.mode = mode
    M.enabled = true

    M.seen = {}
    for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
        M.seen[tp] = true
    end

    focus_bar(vim.api.nvim_get_current_tabpage(), { preserve = false })
end

function M.toggle(mode)
    M.open(mode or "float")
end

function M.setup()
    apply_hls()

    vim.opt.showtabline = 0
    vim.keymap.set({ "n", "t" }, "<A-t>", function() M.toggle("float") end, { desc = "Toggle tab bar (float)" })
    vim.api.nvim_create_user_command("Tab", function()
        M.toggle("split")
    end, { desc = "Toggle tab bar (split)" })
    vim.api.nvim_create_user_command("TabRename", function(opts)
        local tabnr = vim.api.nvim_tabpage_get_number(0)
        if opts.args ~= "" then
            M.rename(tabnr, opts.args)
        else
            M.rename(tabnr)
        end
    end, { nargs = "*", desc = "Rename current tab" })

    vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_hls })
    vim.api.nvim_create_autocmd("TabEnter", {
        callback = function()
            if not M.enabled then return end
            local tabpage = vim.api.nvim_get_current_tabpage()
            if not M.seen[tabpage] then
                M.seen[tabpage] = true
                M.prev_win = vim.api.nvim_get_current_win()
                return
            end
            M.prev_win = vim.api.nvim_get_current_win()
            focus_bar(tabpage, { preserve = true })
        end,
    })
    vim.api.nvim_create_autocmd("TabNewEntered", {
        callback = function()
            if not M.enabled then return end
            local tabpage = vim.api.nvim_get_current_tabpage()
            M.seen[tabpage] = true
            M.prev_win = vim.api.nvim_get_current_win()
            focus_bar(tabpage, { preserve = true })
        end,
    })
    vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if not M.enabled then return end
            local g = card_geometry()
            for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
                local win = tabbar_win_in(tp)
                if win then
                    if M.mode == "float" then
                        vim.api.nvim_win_set_config(win, {
                            relative = "editor",
                            row = g.row,
                            col = g.col,
                            width = g.width,
                            height = g.height,
                        })
                    end
                end
            end
            if M.win and vim.api.nvim_win_is_valid(M.win) then
                if M.mode == "split" then
                    vim.api.nvim_win_set_width(M.win, split_width())
                end
            end
            render()
        end,
    })
end

return M
