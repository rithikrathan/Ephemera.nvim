local M = {}

M.config = {
    transparent = true,
    glow = true,
    show_end_of_buffer = false,
    colors = {},
}

local function get_highlight_groups()
    local colors = M.config.colors
    local bg_color = M.config.transparent and "NONE" or colors.bg
    local float_bg = M.config.transparent and "NONE" or colors.pmenu_bg

    return {
        Normal                      = { fg = colors.fg, bg = bg_color },
        Folded                      = { fg = colors.bool, bg = bg_color, italic = true, bold = true },
        FoldColumn                  = { fg = colors.type, bg = bg_color },
        Cursor                      = { fg = colors.cursor, bg = bg_color },
        CursorLine                  = { bg = colors.cursorLine },
        LineNr                      = { fg = colors.line_nr },
        Visual                      = { bg = colors.visual },
        EndOfBuffer                 = { fg = M.config.show_end_of_buffer and colors.eob or colors.bg, bg = bg_color },
        WinSeparator                = { fg = colors.kw, bg = bg_color },

        MsgSeparator                = { bg = colors.bgl },
        MsgArea                     = { fg = colors.constant, bg = bg_color, italic = true, bold = true },
        ModeMsg                     = { fg = colors.constant, bold = true },

        Search                      = { bg = colors.search_bg, fg = colors.white, bold = true },
        IncSearch                   = { bg = colors.inc_search_bg, fg = colors.inc_search_fg, bold = true },
        CurSearch                   = { bg = colors.cur_search_bg, fg = colors.black, bold = true },

        Pmenu                       = { fg = colors.pmenu_fg, bg = colors.pmenu_bg },
        PmenuSel                    = { fg = colors.pmenu_bg, bg = colors.pmenu_sel_bg, bold = true },
        NormalFloat                 = { fg = colors.fg, bg = float_bg },
        FloatBorder                 = { fg = colors.border, bg = float_bg },

        Comment                     = { fg = colors.comment, italic = true, bold = true },
        String                      = { fg = colors.string, italic = true },
        Function                    = { fg = colors.func },
        Keyword                     = { fg = colors.kw, bold = true },
        Identifier                  = { fg = colors.identifier },
        Type                        = { fg = colors.type },
        PreProc                     = { fg = colors.preprocessor },
        Boolean                     = { fg = colors.bool },
        Constant                    = { fg = colors.constant },
        Operator                    = { fg = colors.operator },
        Delimiter                   = { fg = colors.bracket, bold = true },

        ModeVenn                    = { fg = colors.bg, bg = colors.preprocessor, italic = true, bold = true },
        ModeMul                     = { fg = colors.bg, bg = colors.blue2, italic = true, bold = true },

        ModeNorm                    = { fg = colors.bg, bg = colors.kw, italic = true, bold = true },
        SepNormA                    = { fg = colors.kw, bg = colors.pmenu_bg },
        InfoNorm                    = { fg = colors.fg, bg = colors.pmenu_bg },
        SepNormB                    = { fg = colors.pmenu_bg, bg = colors.bgl },

        ModeIns                     = { fg = colors.bg, bg = colors.func, italic = true, bold = true },
        SepInsA                     = { fg = colors.func, bg = colors.pmenu_bg },
        InfoIns                     = { fg = colors.fg, bg = colors.pmenu_bg },
        SepInsB                     = { fg = colors.pmenu_bg, bg = colors.bgl },

        ModeVis                     = { fg = colors.bg, bg = colors.type, italic = true, bold = true },
        SepVisA                     = { fg = colors.type, bg = colors.pmenu_bg },
        InfoVis                     = { fg = colors.fg, bg = colors.pmenu_bg },
        SepVisB                     = { fg = colors.pmenu_bg, bg = colors.bgl },

        ModeCommand                 = { fg = colors.bg, bg = colors.border, italic = true, bold = true },
        SepCommandA                 = { fg = colors.kw, bg = colors.pmenu_bg },
        InfoCommand                 = { fg = colors.fg, bg = colors.pmenu_bg },
        SepCommandB                 = { fg = colors.pmenu_bg, bg = colors.bgl },

        ModeRead                    = { fg = colors.bg, bg = colors.purple2, italic = true, bold = true },
        SepReadA                    = { fg = colors.purple2, bg = colors.pmenu_bg },
        InfoRead                    = { fg = colors.fg, bg = colors.pmenu_bg },
        SepReadB                    = { fg = colors.pmenu_bg, bg = colors.bgl },

        StatusBody                  = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },
        SlRef                       = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },

        ["@function"]               = { fg = colors.func },
        ["@method"]                 = { fg = colors.func },
        ["@function.builtin"]       = { fg = colors.func },
        ["@function.call"]          = { fg = colors.func },
        ["@keyword"]                = { fg = colors.kw, bold = true },
        ["@keyword.function"]       = { fg = colors.kw, bold = true },
        ["@keyword.return"]         = { fg = colors.kw, bold = true },
        ["@conditional"]            = { fg = colors.kw, bold = true },
        ["@repeat"]                 = { fg = colors.kw, bold = true },
        ["@constant"]               = { fg = colors.constant },
        ["@constant.builtin"]       = { fg = colors.constant },
        ["@string"]                 = { fg = colors.string, italic = true },
        ["@string.regex"]           = { fg = colors.string, italic = true },
        ["@string.escape"]          = { fg = colors.operator },
        ["@number"]                 = { fg = colors.constant },
        ["@boolean"]                = { fg = colors.bool },
        ["@variable"]               = { fg = colors.identifier },
        ["@variable.builtin"]       = { fg = colors.identifier },
        ["@parameter"]              = { fg = colors.identifier },
        ["@parameter.reference"]    = { fg = colors.identifier },
        ["@field"]                  = { fg = colors.identifier },
        ["@property"]               = { fg = colors.identifier },
        ["@type"]                   = { fg = colors.type },
        ["@type.builtin"]           = { fg = colors.type_builtin },
        ["@class"]                  = { fg = colors.type },
        ["@enum"]                   = { fg = colors.type },
        ["@namespace"]              = { fg = colors.identifier },
        ["@struct"]                 = { fg = colors.type },
        ["@module"]                 = { fg = colors.identifier },
        ["@attribute"]              = { fg = colors.identifier },
        ["@punctuation.delimiter"]  = { fg = colors.bracket, bold = true },
        ["@punctuation.bracket"]    = { fg = colors.bracket, bold = true },
        ["@punctuation.special"]    = { fg = colors.operator },
        ["@operator"]               = { fg = colors.operator },
        ["@comment"]                = { fg = colors.comment },
        ["@annotation"]             = { fg = colors.preprocessor },
        ["@tag"]                    = { fg = colors.func },
        ["@tag.attribute"]          = { fg = colors.identifier },
        ["@tag.delimiter"]          = { fg = colors.bracket },
        ["@constructor"]            = { fg = colors.func },
        ["@constructor.lua"]        = { fg = colors.bracket },
        ["@decorator"]              = { fg = colors.preprocessor },

        TelescopeNormal             = { fg = colors.fg, bg = "NONE" },
        TelescopeBorder             = { fg = colors.comment, bg = "NONE" },
        TelescopePromptNormal       = { fg = colors.pmenu_fg, bg = "NONE" },
        TelescopePromptBorder       = { fg = colors.border, bg = "NONE" },
        TelescopePromptTitle        = { fg = colors.title, bg = "NONE", bold = true },
        TelescopePromptCounter      = { fg = colors.cursor, bg = "NONE" },
        TelescopeSelectionCaret     = { fg = colors.operator, bg = colors.visual },
        TelescopeSelection          = { fg = colors.fg, bg = colors.visual, bold = true },
        TelescopeMatching           = { fg = colors.operator, bg = "NONE", bold = true },

        CmpItemAbbr                 = { fg = colors.fg, bg = bg_color },
        CmpItemAbbrMatch            = { fg = colors.cursor, bg = bg_color, bold = true },
        CmpItemAbbrDeprecated       = { fg = colors.comment, bg = bg_color, italic = true },
        CmpItemAbbrMatchFuzzy       = { fg = colors.visual, bg = bg_color, bold = true },
        CmpItemMenu                 = { fg = colors.comment, bg = bg_color },
        CmpBorder                   = { fg = colors.red_light },

        OilDir                      = { fg = colors.bool, bold = true, italic = true },
        OilPermission               = { fg = colors.comment },
        OilSize                     = { fg = colors.constant },
        OilDate                     = { fg = colors.comment },
        OilFile                     = { fg = colors.string, italic = true },
        OilSocket                   = { fg = colors.type },
        OilLink                     = { fg = colors.string },
        OilLinkTarget               = { fg = colors.kw },
        OilCreate                   = { fg = colors.func },
        OilDelete                   = { fg = colors.error },
        OilMove                     = { fg = colors.kw },
        OilCopy                     = { fg = colors.string },
        OilChange                   = { fg = colors.changed },
        OilRestore                  = { fg = colors.info },
        OilPurge                    = { fg = colors.error },
        OilTrash                    = { fg = colors.warning },
        OilTrashSourcePath          = { fg = colors.comment },
        OilFloatBorder              = { fg = colors.comment },

        GitSignsAdd                 = { fg = colors.added, bg = "NONE" },
        GitSignsChange              = { fg = colors.changed, bg = "NONE" },
        GitSignsDelete              = { fg = colors.removed, bg = "NONE" },

        LspSignatureActiveParameter = { bg = bg_color, italic = true },
        DiagnosticError             = { fg = colors.error },
        DiagnosticWarn              = { fg = colors.warning },
        DiagnosticHint              = { fg = colors.hint },
        DiagnosticInfo              = { fg = colors.info },
        DiagnosticVirtualTextError  = { fg = colors.error },
        DiagnosticVirtualTextWarn   = { fg = colors.warning },
        DiagnosticVirtualTextHint   = { fg = colors.hint },
        DiagnosticVirtualTextInfo   = { fg = colors.info },
        DiagnosticUnderlineError    = { gui = "underline", sp = colors.error },
        DiagnosticUnderlineWarn     = { gui = "underline", sp = colors.warning },
        DiagnosticUnderlineHint     = { gui = "underline", sp = colors.hint },
        DiagnosticUnderlineInfo     = { gui = "underline", sp = colors.info },

        MultipleCursorsCursor       = { bg = colors.cyan, fg = colors.black },
        MultipleCursorsVisual       = { bg = colors.purple_light, fg = colors.black },

        MultiCursorCursor           = { bg = colors.cyan, fg = colors.black },
        MultiCursorVisual           = { bg = colors.purple_light, fg = colors.black },
        MultiCursorSign             = { link = "SignColumn" },
        MultiCursorMatchPreview     = { link = "Search" },
        MultiCursorDisabledCursor   = { bg = colors.cyan, fg = colors.black },
        MultiCursorDisabledVisual   = { bg = colors.purple_light, fg = colors.black },
        MultiCursorDisabledSign     = { link = "SignColumn" },

        FlashLabel                  = { bg = colors.orange1, fg = colors.black, bold = true },

        WelcomeRose                 = { fg = colors.red_light, bold = true },
        WelcomeStem                 = { fg = colors.green2, bold = true },
        WelcomeQuote                = { fg = colors.quote_fg, italic = true },

        AerialLine                  = { fg = colors.red2, bg = colors.bg, bold = true },
        AerialLineNC                = { fg = colors.comment, bg = colors.bg },
        AerialGuide                 = { fg = colors.comment },
        AerialSymbolsl              = { fg = colors.func, bg = colors.bgl, bold = true },
        AerialTextsl                = { fg = colors.type, bg = colors.bgl, bold = true },

        CmpItemKindText             = { fg = colors.kw },
        CmpItemKindMethod           = { fg = colors.kw },
        CmpItemKindFunction         = { fg = colors.kw },
        CmpItemKindConstructor      = { fg = colors.kw },
        CmpItemKindField            = { fg = colors.kw },
        CmpItemKindVariable         = { fg = colors.kw },
        CmpItemKindClass            = { fg = colors.kw },
        CmpItemKindInterface        = { fg = colors.kw },
        CmpItemKindModule           = { fg = colors.kw },
        CmpItemKindProperty         = { fg = colors.kw },
        CmpItemKindUnit             = { fg = colors.kw },
        CmpItemKindValue            = { fg = colors.kw },
        CmpItemKindEnum             = { fg = colors.kw },
        CmpItemKindKeyword          = { fg = colors.kw },
        CmpItemKindSnippet          = { fg = colors.kw },
        CmpItemKindColor            = { fg = colors.kw },
        CmpItemKindFile             = { fg = colors.kw },
        CmpItemKindReference        = { fg = colors.kw },
        CmpItemKindFolder           = { fg = colors.kw },
        CmpItemKindEnumMember       = { fg = colors.kw },
        CmpItemKindConstant         = { fg = colors.kw },
        CmpItemKindStruct           = { fg = colors.kw },
        CmpItemKindEvent            = { fg = colors.kw },
        CmpItemKindOperator         = { fg = colors.kw },
        CmpItemKindTypeParameter    = { fg = colors.kw },

        EphemeraBanner              = { fg = colors.banner, bold = true, italic = true },
    }
end

local function apply_highlights()
    local highlight_groups = get_highlight_groups()

    for group, conf in pairs(highlight_groups) do
        local cmd = string.format("highlight %s guifg=%s guibg=%s", group, conf.fg or "NONE", conf.bg or "NONE")
        if conf.sp then cmd = cmd .. " guisp=" .. conf.sp end
        local gui = {}
        if conf.bold then table.insert(gui, "bold") end
        if conf.italic then table.insert(gui, "italic") end
        if conf.gui then table.insert(gui, conf.gui) end
        if M.config.glow and (group == "Function" or group == "Keyword" or group == "@function" or group == "@keyword") then
            table.insert(gui, "bold")
            cmd = cmd .. " guisp=" .. M.config.colors.glow_color
        end
        if #gui > 0 then cmd = cmd .. " gui=" .. table.concat(gui, ",") end
        vim.cmd(cmd)
    end
end

function M.setup(theme_name)
    local json_path = vim.fn.stdpath("config") .. "/lua/Ephemera/themes/" .. theme_name .. ".json"
    local ok, raw = pcall(vim.fn.readfile, json_path)

    if not ok or vim.tbl_isempty(raw) then
        vim.notify("Theme file not found: " .. json_path, vim.log.levels.ERROR)
        return
    end

    local ok_decode, theme_data = pcall(vim.json.decode, table.concat(raw, "\n"))
    if not ok_decode then
        vim.notify("Failed to parse theme JSON: " .. theme_name, vim.log.levels.ERROR)
        return
    end

    M.config.colors = theme_data.colors or {}
    M.config.transparent = theme_data.transparent or false
    M.config.glow = theme_data.glow or false
    M.config.show_end_of_buffer = theme_data.show_end_of_buffer or false

    apply_highlights()
end

M.toggle_transparency = function()
    M.config.transparent = not M.config.transparent
    apply_highlights()
    print("Transparency: " .. (M.config.transparent and "ON" or "OFF"))
end

vim.api.nvim_create_user_command("ToggleTransparency", M.toggle_transparency, {})

return M
