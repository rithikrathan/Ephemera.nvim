-- ============================================================================
-- RATHAN'S EPHEMERA VANILLA (STANDALONE INIT.LUA)
-- ============================================================================

if vim.loader then vim.loader.enable() end

-- ============================================================================
-- 1. OPTIONS & GLOBALS
-- ============================================================================
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
vim.opt.mouse = "a"
vim.opt.timeoutlen = 273
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.g.netrw_winsize = 25
vim.g.netrw_banner = 1
vim.g.netrw_localcopydircmd = 'cp -r'
vim.g.netrw_keepdir = true
vim.opt.expandtab = false
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.updatetime = 400
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.autoread = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", trail = ".", nbsp = "␣" }
vim.opt.cmdheight = 1
vim.opt.guicursor = "n:block,i:hor20,v:block,r:hor50"

-- Vanilla fuzzy finding setups
vim.opt.path:append("**")
vim.opt.wildmenu = true

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars = { foldopen = "▾", foldclose = "▸", foldsep = "┊", fold = " " }

function _G.foldText()
    local fs, fe = vim.v.foldstart, vim.v.foldend
    local line = vim.fn.getline(fs)
    local line_count = fe - fs + 1
    local total_lines = vim.api.nvim_buf_line_count(0)
    local percentage = math.floor((line_count / total_lines) * 100)
    return string.format("╰┈➤  %s ... %d lines (%d%%)", line, line_count, percentage)
end
vim.opt.foldtext = "v:lua.foldText()"

vim.fn.sign_define("DiagnosticSignError", { text = "❖", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚑", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "✯", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "⧐", texthl = "DiagnosticSignInfo" })

_G.create_floating_window = function()
    local stats = vim.api.nvim_list_uis()[1]
    local width = math.floor(stats.width * 0.8)
    local height = math.floor(stats.height * 0.8)
    local gap_from_bottom = 5
    local col = math.floor((stats.width - width) / 2)
    local row = stats.height - height - gap_from_bottom
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor', width = width, height = height,
        row = row, col = col, style = 'minimal', border = 'rounded'
    })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff3322' })
    return buf, win
end

vim.g.use_git_plugins = false
vim.g.is_transparent = true
_G.statusMessage = "@rathan"

-- ============================================================================
-- 2. THEME & HIGHLIGHTS (Exact Ephemera Palette)
-- ============================================================================
local function setup_theme()
    local colors = {
        fg = "#ddcccc", bg = "#04040d", bgl = "#090909", black = "#000000", white = "#ffffff",
        eob = "#3c3c3c", border = "#ff1e00", title = "#ff1e00", cursor = "#ffa0a0", cursorLine = "#121212",
        visual = "#690f0f", line_nr = "#ff1010", comment = "#696969", string = "#e4b2ab", func = "#ff6347",
        kw = "#ff2828", identifier = "#d2d2d2", type = "#ff420f", type_builtin = "#ff420f", operator = "#d63e3e",
        bracket = "#ff6969", preprocessor = "#4b8902", bool = "#ffa07a", constant = "#f59064", search_highlight = "#ffaa00",
        search_bg = "#5631a6", inc_search_bg = "#ff3e0b", inc_search_fg = "#440000", cur_search_bg = "#ff5555",
        glow_color = "#ffeeee", pmenu_bg = "#17171d", pmenu_sel_bg = "#fa3e19", pmenu_fg = "#fc6142",
        added = "#4b8902", changed = "#ff8800", removed = "#ff0000", error = "#ff0000", warning = "#ffee00",
        hint = "#00ffee", info = "#14ff6a", bufferline_selection = "#fd1b1b", cyan = "#00FFFF", purple_light = "#b294bb",
        quote_fg = "#a1a1a1", orange1 = "#ff9e64", orange2 = "#ff8800", orange3 = "#ff5500", orange4 = "#db4b4b",
        red1 = "#ff0000", red2 = "#ff4444", red3 = "#ff6565", red4 = "#c53b53", red_light = "#ff5555",
        green1 = "#00ff99", green2 = "#50fa7b", green3 = "#73daca", green4 = "#2e8b57", blue1 = "#00e1ff",
        blue2 = "#61afef", blue3 = "#7aa2f7", blue4 = "#3d59a1", purple1 = "#ff00ff", purple2 = "#bd93f9",
        purple3 = "#c678dd", purple4 = "#9d7cd8",
    }
    local bg_color = vim.g.is_transparent and "NONE" or colors.bg
    local float_bg = vim.g.is_transparent and "NONE" or colors.pmenu_bg

    local highlight_groups = {
        Normal = { fg = colors.fg, bg = bg_color },
        Folded = { fg = colors.bool, bg = bg_color, italic = true, bold = true },
        FoldColumn = { fg = colors.type, bg = bg_color },
        Cursor = { fg = colors.cursor, bg = bg_color }, CursorLine = { bg = colors.cursorLine },
        LineNr = { fg = colors.line_nr }, Visual = { bg = colors.visual },
        EndOfBuffer = { fg = bg_color, bg = bg_color }, WinSeparator = { fg = colors.kw, bg = bg_color },
        MsgSeparator = { bg = colors.bgl }, MsgArea = { fg = colors.constant, bg = bg_color, italic = true, bold = true },
        ModeMsg = { fg = colors.constant, bold = true }, Search = { bg = colors.search_bg, fg = colors.white, bold = true },
        IncSearch = { bg = colors.inc_search_bg, fg = colors.inc_search_fg, bold = true },
        CurSearch = { bg = colors.cur_search_bg, fg = colors.black, bold = true },
        Pmenu = { fg = colors.pmenu_fg, bg = colors.pmenu_bg },
        PmenuSel = { fg = colors.pmenu_bg, bg = colors.pmenu_sel_bg, bold = true },
        NormalFloat = { fg = colors.fg, bg = float_bg }, FloatBorder = { fg = colors.border, bg = float_bg },
        Comment = { fg = colors.comment, italic = true, bold = true }, String = { fg = colors.string },
        Function = { fg = colors.func }, Keyword = { fg = colors.kw }, Identifier = { fg = colors.identifier },
        Type = { fg = colors.type }, PreProc = { fg = colors.preprocessor }, Boolean = { fg = colors.bool },
        Constant = { fg = colors.constant }, Operator = { fg = colors.operator }, Delimiter = { fg = colors.bracket },
        ModeVenn = { fg = colors.bg, bg = colors.preprocessor, italic = true, bold = true },
        ModeMul = { fg = colors.bg, bg = colors.blue2, italic = true, bold = true },
        ModeNorm = { fg = colors.bg, bg = colors.kw, italic = true, bold = true }, SepNormA = { fg = colors.kw, bg = colors.pmenu_bg },
        InfoNorm = { fg = colors.fg, bg = colors.pmenu_bg }, SepNormB = { fg = colors.pmenu_bg, bg = colors.bgl },
        ModeIns = { fg = colors.bg, bg = colors.func, italic = true, bold = true }, SepInsA = { fg = colors.func, bg = colors.pmenu_bg },
        InfoIns = { fg = colors.fg, bg = colors.pmenu_bg }, SepInsB = { fg = colors.pmenu_bg, bg = colors.bgl },
        ModeVis = { fg = colors.bg, bg = colors.type, italic = true, bold = true }, SepVisA = { fg = colors.type, bg = colors.pmenu_bg },
        InfoVis = { fg = colors.fg, bg = colors.pmenu_bg }, SepVisB = { fg = colors.pmenu_bg, bg = colors.bgl },
        StatusBody = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },
        SlRef = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },
        ["@function"] = { fg = colors.func }, ["@method"] = { fg = colors.func }, ["@function.builtin"] = { fg = colors.func },
        ["@function.call"] = { fg = colors.func }, ["@keyword"] = { fg = colors.kw }, ["@keyword.function"] = { fg = colors.kw },
        ["@keyword.return"] = { fg = colors.kw }, ["@conditional"] = { fg = colors.kw }, ["@repeat"] = { fg = colors.kw },
        ["@constant"] = { fg = colors.constant }, ["@constant.builtin"] = { fg = colors.constant },
        ["@string"] = { fg = colors.string }, ["@string.regex"] = { fg = colors.string }, ["@string.escape"] = { fg = colors.operator },
        ["@number"] = { fg = colors.constant }, ["@boolean"] = { fg = colors.bool }, ["@variable"] = { fg = colors.identifier },
        ["@variable.builtin"] = { fg = colors.identifier }, ["@parameter"] = { fg = colors.identifier },
        ["@parameter.reference"] = { fg = colors.identifier }, ["@field"] = { fg = colors.identifier },
        ["@property"] = { fg = colors.identifier }, ["@type"] = { fg = colors.type }, ["@type.builtin"] = { fg = colors.type_builtin },
        ["@class"] = { fg = colors.type }, ["@enum"] = { fg = colors.type }, ["@namespace"] = { fg = colors.identifier },
        ["@struct"] = { fg = colors.type }, ["@module"] = { fg = colors.identifier }, ["@attribute"] = { fg = colors.identifier },
        ["@punctuation.delimiter"] = { fg = colors.bracket }, ["@punctuation.bracket"] = { fg = colors.bracket },
        ["@punctuation.special"] = { fg = colors.operator }, ["@operator"] = { fg = colors.operator },
        ["@comment"] = { fg = colors.comment }, ["@annotation"] = { fg = colors.preprocessor }, ["@tag"] = { fg = colors.func },
        ["@tag.attribute"] = { fg = colors.identifier }, ["@tag.delimiter"] = { fg = colors.bracket },
        ["@constructor"] = { fg = colors.func }, ["@constructor.lua"] = { fg = colors.bracket }, ["@decorator"] = { fg = colors.preprocessor },
        TelescopeNormal = { fg = colors.fg, bg = "NONE" }, TelescopeBorder = { fg = colors.comment, bg = "NONE" },
        TelescopePromptNormal = { fg = colors.pmenu_fg, bg = "NONE" }, TelescopePromptBorder = { fg = colors.border, bg = "NONE" },
        TelescopePromptTitle = { fg = colors.title, bg = "NONE", bold = true }, TelescopePromptCounter = { fg = colors.cursor, bg = "NONE" },
        TelescopeSelectionCaret = { fg = colors.operator, bg = colors.visual }, TelescopeSelection = { fg = colors.fg, bg = colors.visual, bold = true },
        TelescopeMatching = { fg = colors.operator, bg = "NONE", bold = true }, CmpItemAbbr = { fg = colors.fg, bg = bg_color },
        CmpItemAbbrMatch = { fg = colors.cursor, bg = bg_color, bold = true }, CmpItemAbbrDeprecated = { fg = colors.comment, bg = bg_color, italic = true },
        CmpItemAbbrMatchFuzzy = { fg = colors.visual, bg = bg_color, bold = true }, CmpItemMenu = { fg = colors.comment, bg = bg_color },
        CmpBorder = { fg = colors.red_light }, OilDir = { fg = colors.bool, bold = true, italic = true },
        OilPermission = { fg = colors.comment }, OilSize = { fg = colors.constant }, OilDate = { fg = colors.comment },
        OilFile = { fg = colors.string, italic = true }, OilSocket = { fg = colors.type }, OilLink = { fg = colors.string },
        OilLinkTarget = { fg = colors.kw }, OilCreate = { fg = colors.func }, OilDelete = { fg = colors.error },
        OilMove = { fg = colors.kw }, OilCopy = { fg = colors.string }, OilChange = { fg = colors.changed },
        OilRestore = { fg = colors.info }, OilPurge = { fg = colors.error }, OilTrash = { fg = colors.warning },
        OilTrashSourcePath = { fg = colors.comment }, OilFloatBorder = { fg = colors.comment },
        GitSignsAdd = { fg = colors.added, bg = "NONE" }, GitSignsChange = { fg = colors.changed, bg = "NONE" },
        GitSignsDelete = { fg = colors.removed, bg = "NONE" }, LspSignatureActiveParameter = { bg = bg_color, italic = true },
        DiagnosticError = { fg = colors.error }, DiagnosticWarn = { fg = colors.warning }, DiagnosticHint = { fg = colors.hint },
        DiagnosticInfo = { fg = colors.info }, DiagnosticVirtualTextError = { fg = colors.error },
        DiagnosticVirtualTextWarn = { fg = colors.warning }, DiagnosticVirtualTextHint = { fg = colors.hint },
        DiagnosticVirtualTextInfo = { fg = colors.info }, DiagnosticUnderlineError = { gui = "underline", sp = colors.error },
        DiagnosticUnderlineWarn = { gui = "underline", sp = colors.warning }, DiagnosticUnderlineHint = { gui = "underline", sp = colors.hint },
        DiagnosticUnderlineInfo = { gui = "underline", sp = colors.info }, MultipleCursorsCursor = { bg = colors.cyan, fg = colors.black },
        MultipleCursorsVisual = { bg = colors.purple_light, fg = colors.black }, MultiCursorCursor = { bg = colors.cyan, fg = colors.black },
        MultiCursorVisual = { bg = colors.purple_light, fg = colors.black }, MultiCursorSign = { link = "SignColumn" },
        MultiCursorMatchPreview = { link = "Search" }, MultiCursorDisabledCursor = { bg = colors.cyan, fg = colors.black },
        MultiCursorDisabledVisual = { bg = colors.purple_light, fg = colors.black }, MultiCursorDisabledSign = { link = "SignColumn" },
        FlashLabel = { bg = colors.orange1, fg = colors.black, bold = true }, WelcomeRose = { fg = colors.red_light, bold = true },
        WelcomeStem = { fg = colors.green2, bold = true }, WelcomeQuote = { fg = colors.quote_fg, italic = true },
        AerialLine = { fg = colors.red2, bg = colors.bg, bold = true }, AerialLineNC = { fg = colors.comment, bg = colors.bg },
        AerialGuide = { fg = colors.comment }, AerialSymbolsl = { fg = colors.func, bg = colors.bgl, bold = true },
        AerialTextsl = { fg = colors.type, bg = colors.bgl, bold = true },
    }
    local kinds = { "Text", "Method", "Function", "Constructor", "Field", "Variable", "Class", "Interface", "Module", "Property", "Unit", "Value", "Enum", "Keyword", "Snippet", "Color", "File", "Reference", "Folder", "EnumMember", "Constant", "Struct", "Event", "Operator", "TypeParameter" }
    for _, kind in ipairs(kinds) do highlight_groups["CmpItemKind" .. kind] = { fg = colors.kw } end

    for group, conf in pairs(highlight_groups) do
        if conf.link then
            vim.api.nvim_set_hl(0, group, { link = conf.link })
        else
            local gui_opts = { fg = conf.fg, bg = conf.bg, sp = conf.sp, bold = conf.bold, italic = conf.italic }
            if conf.gui then gui_opts[conf.gui] = true end
            if group == "Function" or group == "Keyword" or group == "@function" or group == "@keyword" then
                gui_opts.bold = true
                gui_opts.sp = colors.glow_color
            end
            vim.api.nvim_set_hl(0, group, gui_opts)
        end
    end
end
setup_theme()

-- ============================================================================
-- 3. VANILLA HARPOON ENGINE & VANILLA TELESCOPE
-- ============================================================================
_G.VanillaHarpoon = {}
local function harpoon_add()
    local path = vim.fn.expand("%:p")
    if path ~= "" then
        for _, p in ipairs(_G.VanillaHarpoon) do if p == path then return end end
        table.insert(_G.VanillaHarpoon, path); print("󰀱 Added to Harpoon")
    end
end
local function harpoon_select(idx)
    if _G.VanillaHarpoon[idx] then vim.cmd("edit " .. vim.fn.fnameescape(_G.VanillaHarpoon[idx])) end
end
vim.api.nvim_create_user_command('HarpoonClr', function() _G.VanillaHarpoon = {}; print("󰀱 Harpoon list nuked.") end, {})
vim.api.nvim_create_user_command('HarpoonOnly', function()
    local lookup = {}
    for _, p in ipairs(_G.VanillaHarpoon) do lookup[p] = true end
    local closed = 0
    local cur_buf = vim.api.nvim_get_current_buf()
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and bufnr ~= cur_buf then
            local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p")
            if not lookup[path] and not vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
                vim.api.nvim_buf_delete(bufnr, { force = false }); closed = closed + 1
            end
        end
    end
    print(string.format("󰀱 Kept Harpoon buffers. Closed %d others.", closed))
end, {})

-- ============================================================================
-- 4. KEYBINDS (Exact Match to Ephemera)
-- ============================================================================
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move cursor right" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "Move cursor down" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "Move cursor up" })
vim.keymap.set("i", "<A-o>", '<Esc>o')
vim.keymap.set("i", "<A-O>", '<Esc>O')
vim.keymap.set("n", "<leader>cp", function() print("Copilot disabled (Vanilla Mode)") end, { desc = "Toggle Copilot Placeholder" })
vim.keymap.set("n", "[c", function() print("TS Context Jump (Vanilla Mode)") end)
vim.keymap.set("n", "<leader>u", ":undolist<CR>", { desc = "Native Undotree" })
vim.keymap.set({ "n", "v", "t", "i" }, "<A-n>", '<CR>', { remap = true })
vim.keymap.set("v", "<leader>y", '"+ygv', { remap = true })
vim.keymap.set("n", "<leader>p", '"+p', { remap = true })
vim.keymap.set({ "n", "v", "t", "i" }, "<F5>", ':w | nohl | make<CR>', { remap = true })
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set({ "n", "i" }, "<A-[>", "zt")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({ "v", "i" }, "<leader><Tab>", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("t", "<leader><Tab>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", "yyp", { desc = "Duplicate current line" })
vim.keymap.set("i", "<leader>tn", "<C-o>", { desc = "Temporary normal mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "g_")
vim.keymap.set("v", "<leader>dd", "y'>p")

-- Wraps
vim.keymap.set("v", "<leader>wp", ":s/\\%V.*\\%V/(&)/ | nohl<CR>")
vim.keymap.set("v", "<leader>wpp", ":s/\\%V.*\\%V/{&}/ | nohl<CR>")
vim.keymap.set("v", "<leader>wqq", ':s/\\%V.*\\%V/"&"/ | nohl<CR>')
vim.keymap.set("v", "<leader>wq", ":s/\\%V.*\\%V/'&'/ | nohl<CR>")
vim.keymap.set("v", "<leader>wb", ":s/\\%V.*\\%V/`&`/ | nohl<CR>")

vim.keymap.set("i", "<leader>fjk", "<><left>")
vim.keymap.set("n", "ct", 'vitc')
vim.keymap.set("i", "<A-=>", ' := ')
vim.keymap.set("n", "vt", 'vit')

-- Splits
vim.keymap.set("n", "<leader>h", ":split<CR>")
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<A-h>", "<C-w><C-h>")
vim.keymap.set("n", "<A-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Files & Native execution
vim.keymap.set("n", "<leader>nf", function()
    local netrw_dir = vim.fn.expand("%:p:h")
    local filename = vim.fn.input("New file: ")
    if filename ~= "" then
        local filepath = netrw_dir .. "/" .. filename
        vim.fn.system("touch " .. vim.fn.shellescape(filepath)); print("Created: " .. filepath)
    end
end)
vim.keymap.set('n', '<leader>x', function() os.execute('xdg-open ' .. vim.fn.expand('%:p:h')) end)
vim.keymap.set('n', '<leader>xx', function()
    local app = vim.fn.input("Open with: ")
    if app ~= "" then os.execute(app .. " " .. vim.fn.shellescape(vim.fn.expand('%:p')) .. " &") end
end)
vim.keymap.set('n', '<leader>X', function()
    local app = vim.fn.input("Open with: "); local dir = vim.fn.expand('%:p:h')
    if app ~= "" then os.execute(vim.fn.shellescape(app) .. " " .. vim.fn.shellescape(dir) .. " &") end
end)

-- Replace Word & Terminal
vim.keymap.set("n", "<leader>rw", function()
    local word = vim.fn.expand("<cword>")
    local replacement = vim.fn.input("Replace '" .. word .. "' with: ")
    if replacement ~= "" then vim.cmd("%s/\\<" .. word .. "\\>/" .. replacement .. "/gc") end
end)
vim.keymap.set('n', '<leader>t', function()
    local buf, win = _G.create_floating_window()
    vim.keymap.set({ "n", "t" }, "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    vim.fn.termopen(vim.o.shell, { cwd = vim.fn.expand('%:p:h') }); vim.cmd('startinsert')
end)
vim.keymap.set("n", "<leader>r", function()
    local arg = vim.fn.input("Arg: ")
    local buf, win = _G.create_floating_window()
    vim.keymap.set("t", "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    local job = vim.fn.termopen(vim.o.shell); vim.fn.chansend(job, "make run " .. arg .. "\n"); vim.cmd("startinsert")
end)

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local opts = { buffer = event.buf }
        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
        vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
        vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
        vim.keymap.set({ "n", "v" }, "<leader>va", vim.lsp.buf.code_action, opts)
    end,
})

-- Harpoon Keybinds (Vanilla Bridge)
vim.keymap.set("n", "<leader>a", harpoon_add)
vim.keymap.set("n", "<leader>s", function() _G.VanillaHarpoon = {}; print("Harpoon Cleared") end)
for i = 1, 4 do vim.keymap.set("n", "<leader>" .. i, function() harpoon_select(i) end) end
vim.keymap.set("n", "<A-[>", function() print("Harpoon Prev placeholder") end)
vim.keymap.set("n", "<A-]>", function() print("Harpoon Next placeholder") end)

-- Telescope Keybinds (Vanilla Bridge)
vim.keymap.set("n", "<leader>ff", ":find *", { desc = "Vanilla find files" })
vim.keymap.set("n", "<leader>fgi", ":!git ls-files<CR>", { desc = "Vanilla git files" })
vim.keymap.set("n", "<leader>fg", function()
    local pattern = vim.fn.input("Grep > "); if pattern ~= "" then vim.cmd("grep! -r " .. pattern .. " ."); vim.cmd("copen") end
end, { desc = "Vanilla live grep" })
vim.keymap.set("n", "<leader>fb", ":ls<CR>:b<Space>", { desc = "Vanilla buffers" })
vim.keymap.set("n", "<leader>fh", ":help ", { desc = "Vanilla help tags" })
vim.keymap.set("n", "<leader>jdf", ":Explore<CR>", { desc = "Vanilla file explore" })
vim.keymap.set("n", "<leader>gr", function()
    local p = vim.fn.input("Grep >"); if p ~= "" then vim.cmd("vimgrep /"..p.."/g **/*"); vim.cmd("copen") end
end)
vim.keymap.set("n", "<leader>gq", function()
    local p = vim.fn.input("Grep >"); if p ~= "" then vim.cmd("vimgrep /"..p.."/g **/*"); vim.cmd("copen") end
end)

-- Plugin Mock Keymaps
vim.keymap.set("n", "<leader>gs", ":!git status<CR>")
vim.keymap.set("n", "<leader>gg", ":echo 'GitGutter Disabled'<CR>")
vim.keymap.set("n", "<leader>gt", ":echo 'Git Line Highlights Disabled'<CR>")
vim.keymap.set("n", "<leader>m", ":echo 'Minimap Disabled'<CR>")
vim.keymap.set("n", "<leader>tt", "<cmd>sp | term<CR>")

vim.keymap.set('n', '<C-P>', function()
    local path = vim.api.nvim_buf_get_name(0); if path == "" then return end
    local rel = vim.fn.fnamemodify(path, ':.'); print(rel); vim.fn.setreg('+', vim.fn.shellescape(rel))
end)

vim.keymap.set("n", "]]]", function() print(vim.fn.expand('%:p:h')) end)

-- Toggle Logic Core
local function toggle_logic()
    local toggle_map = {
        ["true"] = "false", ["0"] = "1", ["True"] = "False", ["TRUE"] = "FALSE", ["yes"] = "no", ["Yes"] = "No", ["YES"] = "NO",
        ["on"] = "off", ["On"] = "Off", ["ON"] = "OFF", ["=="] = "!=", ["==="] = "!==", ["&&"] = "||", ["and"] = "or",
        [">"] = "<", [">="] = "<=", ["+"] = "-", ["++"] = "--", ["+="] = "-=", ["public"] = "private", ["protected"] = "private",
        ["static"] = "dynamic", ["const"] = "let", ["readonly"] = "readwrite", ["enable"] = "disable", ["enabled"] = "disabled",
        ["start"] = "stop", ["open"] = "close", ["opened"] = "closed", ["show"] = "hide", ["visible"] = "hidden", ["valid"] = "invalid",
        ["success"] = "failure", ["attach"] = "detach", ["lock"] = "unlock", ["bind"] = "unbind", ["top"] = "bottom", ["left"] = "right",
        ["up"] = "down", ["high"] = "low", ["height"] = "width", ["inner"] = "outer", ["inside"] = "outside", ["min"] = "max",
        ["minimum"] = "maximum", ["horizontal"] = "vertical", ["row"] = "column", ["inline"] = "block", ["flex"] = "grid",
        ["around"] = "between", ["relative"] = "absolute", ["first"] = "last", ["prev"] = "next", ["previous"] = "next",
        ["head"] = "tail", ["push"] = "pop", ["shift"] = "unshift", ["get"] = "post", ["put"] = "delete", ["master"] = "main",
        ["stage"] = "unstage", ["pull"] = "push", ["define"] = "undefine",
    }
    local lookup = {}
    for k, v in pairs(toggle_map) do lookup[k] = v; lookup[v] = k end
    local full_word = vim.fn.expand("<cWORD>")
    local lead, core, trail = full_word:match("^(%W*)([%w_!=<>%&%|%+%-%*%/^%%#]+)(%W*)$")
    if core and lookup[core] then
        vim.cmd("normal! ciW" .. lead .. lookup[core] .. trail)
    else
        print("No toggle found for core: " .. (core or "nil"))
    end
end
vim.keymap.set("n", "<leader>i", toggle_logic, { desc = "Smart Toggle Inverse" })

-- ============================================================================
-- 5. COMMANDS & AUTOCOMMANDS (Exact Match)
-- ============================================================================
local ft_map = { sv = "systemverilog", v = "verilog", pyde = "python", pde = "processing" }
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = vim.tbl_map(function(ext) return "*." .. ext end, vim.tbl_keys(ft_map)),
    callback = function(opts)
        local ext = vim.fn.fnamemodify(opts.file, ":e")
        if ft_map[ext] then vim.bo.filetype = ft_map[ext] end
    end,
})

vim.api.nvim_create_autocmd("ModeChanged", {
    pattern = "*:[vV]",
    callback = function()
        if vim.b.venn_enabled then vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-v>", true, false, true), "n", false) end
    end,
})

vim.api.nvim_create_user_command("ReloadConfig", function() vim.cmd("source $MYVIMRC"); print("Configuration Reloaded.") end, {})
vim.api.nvim_create_autocmd("TextYankPost", { callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 120 } end })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "netrw",
    callback = function()
        vim.keymap.set("n", "<leader>d", function()
            local dir = vim.b.netrw_curdir
            local target = vim.fn.expand("<cfile>")
            if target ~= "" then vim.fn.system({ "cp", "-r", dir .. "/" .. target, dir .. "/" .. target .. ".bak" }); vim.cmd("edit " .. vim.fn.fnameescape(dir)); print("Backup created.") end
        end, { buffer = true, remap = false })
        vim.keymap.set('n', '<C-P>', function()
            local path = vim.fn.fnamemodify(vim.b.netrw_curdir .. "/" .. vim.fn.expand('<cfile>'), ':.'); print(path); vim.fn.setreg('+', path)
        end, { buffer = true })
    end
})

local window_fixes = { ["FileType"] = { "qf", "undotree", "diff", "help", "man" }, ["TermOpen"] = { "*" }, ["User"] = { "FzfStatusLine" } }
for event, patterns in pairs(window_fixes) do
    vim.api.nvim_create_autocmd(event, { pattern = patterns, callback = function() vim.opt_local.statusline = "%!v:lua.EphemeraStatusLine()" end })
end
vim.api.nvim_create_autocmd("FileType", { pattern = "undotree", callback = function() vim.wo.statusline = vim.o.statusline end })

local status_lookup = { wtf = "what the fuck mate", ok = "All systems operational", error = "Critical failure detected", busy = "Working on it..." }
vim.api.nvim_create_user_command('SetStatus', function(opts)
    local mode, payload = opts.args:match("^(%S+)%s*(.*)$")
    pcall(vim.api.nvim_del_augroup_by_name, "StatusSmartUpdate")
    if mode == "text" then _G.statusMessage = payload; vim.cmd("redrawstatus")
    elseif mode == "msg" then local msg = status_lookup[payload]; if msg then _G.statusMessage = msg; vim.cmd("redrawstatus") end
    elseif mode == "aerial" then _G.statusMessage = "Aerial disabled in Vanilla"; vim.cmd("redrawstatus") end
end, { nargs = '+', complete = function(ArgLead, CmdLine)
    local args = vim.split(CmdLine, "%s+"); if #args == 2 then return { "text", "msg", "aerial" } end; if #args == 3 and args[2] == "msg" then return vim.tbl_keys(status_lookup) end
end })

vim.api.nvim_create_user_command('LockIn', function()
    local current_scrolloff = vim.opt.scrolloff:get()
    if current_scrolloff < 999 then vim.opt.scrolloff = 999; print("Cursor Locked: Center") else vim.opt.scrolloff = 5; print("Cursor Unlocked") end
end, { desc = "Toggle typewriter-style center cursor lock" })
vim.api.nvim_create_user_command('UnFiget', function() print("Fidget disabled") end, { desc = "disable the fige notification" })

-- ============================================================================
-- 6. STATUSLINE (Animations & Harpoon Vanilla Integration)
-- ============================================================================
_G.git_branch = ""
_G.Modules = {}
function Modules.set_bridge_hl(name, fg_group, bg_group, is_sep)
    local fg_data = vim.api.nvim_get_hl(0, { name = fg_group, link = false })
    local bg_data = vim.api.nvim_get_hl(0, { name = bg_group, link = false })
    local opts = { bg = bg_data.bg }
    if is_sep then opts.fg = fg_data.bg else opts.fg = fg_data.fg end
    vim.api.nvim_set_hl(0, name, opts)
    return name
end

function Modules.render_left_core()
    local m, state, label = vim.fn.mode(), "Norm", "NORMAL"
    if m == 'i' then state, label = "Ins", "INSERT"
    elseif m:match("^[vV\22]") then state, label = "Vis", "VISUAL"
    elseif m == 'c' then label = "COMMAND" elseif m == 'R' then label = "REPLACE" elseif m == 't' then label = "TERMINAL" end

    local mode_group, mid_sep_group = "Mode" .. state, "Sep" .. state .. "A"
    local info_state, info_group = state, "Info" .. state
    local end_sep_group = "Sep" .. info_state .. "Trans"

    Modules.set_bridge_hl(mid_sep_group, mode_group, info_group, true)
    Modules.set_bridge_hl(end_sep_group, info_group, "StatusBody", true)

    local mode_block = string.format("%%#%s# %s %%#%s#", mode_group, label, mid_sep_group)
    local branch = (_G.git_branch ~= "") and (_G.git_branch .. "┆ ") or " "
    local mod = vim.bo.modified and " 𔒝 " or ""

    local fname = vim.fn.expand("%:t"); local filename_text = (fname == "") and "[No Name]" or fname
    local icon_comp = "%#" .. info_group .. "#📜 "
    local info_content = (branch ~= " ") and (branch .. icon_comp .. filename_text) or (" " .. icon_comp .. filename_text)

    return table.concat({ mode_block, "%#" .. info_group .. "#" .. info_content .. mod .. "%r ", "%#" .. end_sep_group .. "# %#StatusBody#" })
end

_G.StatState = { mode = 1 }
function Modules.get_diag(severity) return #vim.diagnostic.get(0, { severity = severity }) end
function Modules.get_stat_section()
    local mode = _G.StatState.mode
    if mode == 1 then return " %l:%c %p%% "
    elseif mode == 2 then
        Modules.set_bridge_hl("SlDiagErr", "DiagnosticError", "StatusBody", false)
        Modules.set_bridge_hl("SlDiagWarn", "DiagnosticWarn", "StatusBody", false)
        local err, warn = Modules.get_diag(vim.diagnostic.severity.ERROR), Modules.get_diag(vim.diagnostic.severity.WARN)
        return string.format(" %%#SlDiagErr#✖ %d %%#SlDiagWarn#⚠ %d %%#StatusBody#", err, warn)
    elseif mode == 3 then
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        return "🖧 " .. ((#clients > 0) and clients[1].name or "❌") .. ""
    elseif mode == 4 then return " %y " end
    return ""
end

_G.AddState = { mode = 1, key_log = { "   ", "   ", "   ", "   " } }
function Modules.get_harpoon_tabs()
    local items = _G.VanillaHarpoon
    local current_path = vim.fn.expand("%:p")
    local output = ""
    local m, state = vim.fn.mode(), "Norm"
    if m == 'i' then state = "Ins" elseif m:match("^[vV\22]") then state = "Vis" end
    local mode_data = vim.api.nvim_get_hl(0, { name = "Mode" .. state, link = false })
    local body_data = vim.api.nvim_get_hl(0, { name = "StatusBody", link = false })

    vim.api.nvim_set_hl(0, "SlHarpoonActive", { fg = mode_data.fg, bg = mode_data.bg, bold = true, italic = true })
    vim.api.nvim_set_hl(0, "SlHarpoonActiveBars", { fg = mode_data.bg, bg = body_data.bg, bold = true, italic = true })

    for i = 1, 4 do
        local path = items[i]
        local label, is_active = "-", false
        if path then
            if path == current_path then is_active = true end
            local fname = vim.fn.fnamemodify(path, ":t")
            label = #fname > 7 and (fname:sub(1, 5) .. "..") or fname
        end
        if is_active then
            local display = string.format("%d.%s", i, label)
            output = output .. string.format(" %%#SlHarpoonActiveBars#%%#SlHarpoonActive#%s%%#SlHarpoonActiveBars#%%#StatusBody#", display)
        else
            output = output .. string.format(" %d.%s", i, label)
        end
    end
    return "┆" .. output
end

function Modules.get_additional_section()
    local mode = _G.AddState.mode
    if mode == 1 then return Modules.get_harpoon_tabs()
    elseif mode == 2 then
        local log = _G.AddState.key_log
        Modules.set_bridge_hl("SlRose", "Keyword", "StatusBody", false)
        return string.format("┆ %%#SlRose#%s%%#StatusBody# %s %s %s ", log[1], log[2], log[3], log[4])
    elseif mode == 3 then return os.date("┆ %a %b %d %I:%M %p") end
    return ""
end

local key_aliases = { ["<BSLASH>"]="Bsl", ["\\"]="Bsl", ["<SPACE>"]="Spc", [" "]="Spc", ["<CR>"]="Ret", ["<TAB>"]="Tab", ["<ESC>"]="Esc", ["<BS>"]="Bks", ["<UP>"]=" Up", ["<DOWN>"]="Dwn", ["<LEFT>"]="Lft", ["<RIGHT>"]="Rgt" }
vim.on_key(function(char)
    if not char then return end
    local raw = vim.fn.keytrans(char)
    if raw == "" or raw == "<Ignore>" then return end
    local clean = key_aliases[raw:upper()] or raw
    if not key_aliases[raw:upper()] then clean = clean:gsub("<", ""):gsub(">", ""):gsub("C%-", "^"):gsub("M%-", "A-") end
    if #clean > 3 then clean = clean:sub(1, 3) end
    clean = string.format("%3s", clean)
    table.remove(_G.AddState.key_log)
    table.insert(_G.AddState.key_log, 1, clean)
    if _G.AddState.mode == 2 then vim.schedule(function() pcall(vim.cmd, "redrawstatus") end) end
end, vim.api.nvim_create_namespace("EphemeraKeyLogger"))

local frames = { " ₍^. .^₎⟆ ", " ₍^. .^₎  ", " ⟅₍^. .^₎ ", " ₍^. .^₎  " }
local static_txt = { "꧁  ✧ 🌹✧ ꧂", " ꧁  ⎝𓆩༺  ✧ ༻  𓆪⎠꧂  ", " ˗ˏˋ 💤 ˎˊ˗ ", "────୨ৎ────", " ─── ★ ─── ", "  ( ˘ ³˘)♥ ", "· · ─ ·𖥸· ─ · ·", "ﮩ٨ـﮩﮩ٨ـ 🌹 ﮩ٨ـﮩﮩﮩ٨ـ", "╭∩╮( •̀_•́ )╭∩╮" }
_G.AnimState = { output = static_txt[1], idx = 1, timer = vim.loop.new_timer(), augroup = vim.api.nvim_create_augroup("StatusAnim", { clear = true }) }

local function tick()
    _G.AnimState.idx = (_G.AnimState.idx % #frames) + 1; _G.AnimState.output = frames[_G.AnimState.idx]; vim.cmd("redrawstatus")
end

function _G.SetAnimMode(arg)
    local parts = vim.split(arg or "", " ", { trimempty = true })
    local mode, val = parts[1] or "static", tonumber(parts[2])
    _G.AnimState.timer:stop(); vim.api.nvim_clear_autocmds({ group = _G.AnimState.augroup })
    if mode == "time" then _G.AnimState.timer:start(0, val or 200, vim.schedule_wrap(tick))
    elseif mode == "input" then
        _G.AnimState.output = frames[1]
        vim.api.nvim_create_autocmd({ "CursorMoved", "InsertCharPre" }, { group = _G.AnimState.augroup, callback = tick })
    elseif mode == "static" then _G.AnimState.output = static_txt[val or 1] or static_txt[1]; vim.cmd("redrawstatus") end
end

vim.api.nvim_create_user_command("SlAnimMode", function(o) _G.SetAnimMode(o.args) end, { nargs = 1, complete = function() return { "time", "input", "static" } end })

local function update_git()
    vim.system({ "git", "branch", "--show-current" }, { text = true }, function(out)
        vim.schedule(function()
            if out.code == 0 then local b = vim.trim(out.stdout); _G.git_branch = (b ~= "") and ("   " .. b .. " ") or "" else _G.git_branch = "" end
            vim.cmd("redrawstatus")
        end)
    end)
end
update_git(); vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, { callback = update_git })

vim.keymap.set("n", "\\", function() _G.StatState.mode = (_G.StatState.mode % 4) + 1; vim.cmd("redrawstatus") end, { silent = true })
vim.keymap.set("n", "|", function() _G.AddState.mode = (_G.AddState.mode % 3) + 1; vim.cmd("redrawstatus") end, { silent = true })

function _G.EphemeraStatusLine()
    local width = vim.o.columns
    local left_core = Modules.render_left_core()
    local left_extra = "%#SlRef#" .. (_G.statusMessage or "")
    local middle_part = (_G.AnimState.output or "")
    local right_part = Modules.get_stat_section() .. " " .. Modules.get_additional_section() .. " "
    if width < 70 then return left_core end
    if width < 90 then return left_core .. "%=" .. right_part end
    return left_core .. left_extra .. "%=" .. middle_part .. "%=" .. right_part
end
vim.opt.statusline = "%!v:lua.EphemeraStatusLine()"

-- ============================================================================
-- 7. WELCOME DASHBOARD (Exact Port)
-- ============================================================================
local WelcomeScreen = {}
WelcomeScreen.config = {
    header_text = {
        [[ '||''''|          ||                                      ]],
        [[  ||    .          ||                                      ]],
        [[  ||'''|  '||''|,  ||''|, .|''|, '||),,(|,  .|''|, '||''|  '''|.  ]],
        [[  ||       ||  ||  ||  || ||..||  || || ||  ||..||  ||    .|''||  ]],
        [[ .||....|  ||..|' .||  || `|...  .||    ||. `|...  .||.   `|..||. ]],
        [[           ||                                              ]],
        [[          .||                                              ]],
    },
    quote = "It is only with the heart that one can see rightly; what is essential is invisible to the eye.",
    buttons = {
        { "n", "🗎  New File", ":ene <BAR> startinsert  " },
        { "l", "⟲   LastFile", "`0" },
        { "e", "🗁  Explorer", ":Explore" },
        { "f", "🔍  Find File", ":find *" },
        { "r", "🗐  Recent", ":browse oldfiles" },
        { "c", "⚙️  Config", ":e $MYVIMRC  " },
        { "q", "➜]  Quit", ":qa  " },
    },
    flower_art = {
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠖⠋⠉⠉⠳⡴⠒⠒⠒⠲⠤⢤⣀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⡴⠚⡩⠟⠓⠒⡖⠲⡄⠀⠀⠈⡆ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⢠⠒⠾⢥⣀⣇⣚⣹⡤⡟⠀⡇⢠⠀⢠⠇ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣄⣀⠀⡇⠀⠀⠀⠀⠀⢀⡜⠁⣸⢠⠎⣰⣃ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡍⠀⠉⠉⠛⠦⣄⠀⢀⡴⣫⠴⠋⢹⡏⡼⠁⠈⠙⢦⡀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣟⣒⣋⣉⣉⡭⠟⢡⠏⡼⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⢀⠏⣸⠁⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⢠⠇⠀⠀⠀ ]],
        [[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠓⠚⠀⠀⠀ ]],
    },
    hl = { header="Keyword", quote="WelcomeQuote", quotemark="Keyword", key="DiagnosticHint", label="Comment", flower="WelcomeRose", stem="WelcomeStem", bracket="Delimiter", sep="WinSeparator" }
}

local function wrap_text(text, limit)
    local lines, cur = {}, ""
    for w in text:gmatch("%S+") do
        if vim.fn.strdisplaywidth(cur .. " " .. w) > limit then table.insert(lines, cur); cur = w else cur = (#cur > 0) and (cur .. " " .. w) or w end
    end
    if #cur > 0 then table.insert(lines, cur) end
    return lines
end

function WelcomeScreen.draw()
    local buf = vim.api.nvim_get_current_buf()
    local ns_id = vim.api.nvim_create_namespace("Ephemera_welcome")
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe'); vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false); vim.api.nvim_buf_set_option(buf, 'filetype', 'dashboard')
    vim.opt_local.number, vim.opt_local.relativenumber, vim.opt_local.list, vim.opt_local.cursorline, vim.opt_local.wrap, vim.opt_local.signcolumn = false, false, false, false, false, "no"
    vim.opt_local.statusline = " "; vim.opt_local.fillchars = { eob = " " }
    vim.opt_local.winhighlight = "StatusLine:Normal,StatusLineNC:Normal,EndOfBuffer:Normal"

    local block_keys = { 'h','j','k','l','<Up>','<Down>','<Left>','<Right>','w','b','e','ge','0','$','^','<C-u>','<C-d>','<C-f>','<C-b>','<C-y>','<C-e>','zt','zz','zb','<PageUp>','<PageDown>','gg','G','H','M','L','{','}','(',')','%','<ScrollWheelUp>','<ScrollWheelDown>','<ScrollWheelLeft>','<ScrollWheelRight>','<LeftMouse>','<RightMouse>','<MiddleMouse>','<2-LeftMouse>','<3-LeftMouse>','<4-LeftMouse>','i','I','a','A','o','O','v','V','<C-v>','r','R','s','S','c','C','x','X','d','D','y','Y','p','P','u','<C-r>','/','?','n','N','*','#','<CR>','<kEnter>' }
    for _, key in ipairs(block_keys) do vim.keymap.set({ 'n', 'v', 'o' }, key, '<nop>', { buffer = buf, silent = true }) end

    local win_w, win_h = vim.api.nvim_win_get_width(0), vim.api.nvim_win_get_height(0)
    local draw_queue = {}
    local function queue(row, col, text, hl, meta) if row >= 0 and row < win_h then table.insert(draw_queue, {r=row, c=math.max(0, col), t=text, hl=hl, m=meta}) end end

    local header_w, rose_w, max_btn_w = 0, 0, 0
    for _, l in ipairs(WelcomeScreen.config.header_text) do header_w = math.max(header_w, vim.fn.strdisplaywidth(l)) end
    for _, l in ipairs(WelcomeScreen.config.flower_art) do rose_w = math.max(rose_w, vim.fn.strdisplaywidth(l)) end
    for _, btn in ipairs(WelcomeScreen.config.buttons) do max_btn_w = math.max(max_btn_w, vim.fn.strdisplaywidth(string.format("[ %s ]  %s", btn[1], btn[2]))) end

    local quote_lines = wrap_text(WelcomeScreen.config.quote, header_w)
    if #quote_lines > 0 then quote_lines[1] = '"'..quote_lines[1]; quote_lines[#quote_lines] = quote_lines[#quote_lines]..'"' end

    local left_h = #WelcomeScreen.config.header_text + 1 + #quote_lines + 2 + #WelcomeScreen.config.buttons
    local start_row = math.max(0, math.floor((win_h - math.max(left_h, #WelcomeScreen.config.flower_art)) / 2))
    local show_rose = (win_w >= header_w + 4 + 1 + 4 + rose_w + 4)
    local left_col_x = show_rose and math.max(2, math.floor((win_w - (header_w + 9 + rose_w)) / 2)) or math.max(2, math.floor((win_w - header_w) / 2))
    local right_col_x, sep_col_x = left_col_x + header_w + 9, left_col_x + header_w + 4

    for i, line in ipairs(WelcomeScreen.config.header_text) do queue(start_row + i - 1, left_col_x, line, WelcomeScreen.config.hl.header) end
    local quote_y = start_row + #WelcomeScreen.config.header_text + 1
    for i, line in ipairs(quote_lines) do queue(quote_y + i - 1, left_col_x + math.max(0, math.floor((header_w - vim.fn.strdisplaywidth(line)) / 2)), line, nil, {q=true, s=(i==1), e=(i==#quote_lines)}) end
    local btn_y = quote_y + #quote_lines + 2
    for i, btn in ipairs(WelcomeScreen.config.buttons) do queue(btn_y + i - 1, left_col_x + math.max(0, math.floor((header_w - max_btn_w) / 2)), string.format("[ %s ]  %s", btn[1], btn[2]), nil, {b=true, k=btn[1]}) end

    if show_rose then
        for i = start_row, math.max(btn_y + #WelcomeScreen.config.buttons - 1, start_row + #WelcomeScreen.config.flower_art - 1) do queue(i, sep_col_x, "│", WelcomeScreen.config.hl.sep) end
        for i, line in ipairs(WelcomeScreen.config.flower_art) do queue(start_row + i - 1, right_col_x, line, (i < 11) and WelcomeScreen.config.hl.flower or WelcomeScreen.config.hl.stem) end
    end

    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    local empty = {}; for i=1, win_h do empty[i] = string.rep(" ", win_w) end; vim.api.nvim_buf_set_lines(buf, 0, -1, false, empty)

    table.sort(draw_queue, function(a, b) return a.r == b.r and a.c > b.c or a.r < b.r end)
    for _, item in ipairs(draw_queue) do
        pcall(vim.api.nvim_buf_set_text, buf, item.r, item.c, item.r, item.c + vim.fn.strdisplaywidth(item.t), { item.t })
        local end_b = item.c + #item.t
        if item.m and item.m.b then
            vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.bracket, item.r, item.c, item.c+1)
            vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.key, item.r, item.c+2, item.c+2+#item.m.k)
            vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.bracket, item.r, item.c+3+#item.m.k, item.c+4+#item.m.k)
            vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.label, item.r, item.c+6+#item.m.k, end_b)
        elseif item.m and item.m.q then
            local s, e = item.c, end_b
            if item.m.s then vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.quotemark, item.r, s, s+1); s=s+1 end
            if item.m.e then vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.quotemark, item.r, e-1, e); e=e-1 end
            if s<e then vim.api.nvim_buf_add_highlight(buf, ns_id, WelcomeScreen.config.hl.quote, item.r, s, e) end
        elseif item.hl then vim.api.nvim_buf_add_highlight(buf, ns_id, item.hl, item.r, item.c, end_b) end
    end
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    for _, btn in ipairs(WelcomeScreen.config.buttons) do vim.api.nvim_buf_set_keymap(buf, 'n', btn[1], btn[3] .. "<CR>", { noremap = true, silent = true }) end
end

vim.api.nvim_create_autocmd("VimEnter", { callback = function() if vim.fn.argc() == 0 then WelcomeScreen.draw() end end })
vim.api.nvim_create_autocmd("VimResized", { callback = function() if vim.bo.filetype == "dashboard" then WelcomeScreen.draw() end end })

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================
print("rathan's standalone vanilla config Ephemera_vanilla has been loaded")
