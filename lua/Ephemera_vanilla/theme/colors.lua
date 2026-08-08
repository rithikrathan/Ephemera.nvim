local M = {}

M.config = {
	transparent = true, -- Default setting
	glow = true,

	colors = {
		fg = "#ffeeee",
		bg = "#04040d",
		cursor = "#ffa0a0",
		cursorLine = "#121212",
		glow_color = "#ffeeee",
		line_nr = "#ff1010",
		visual = "#690f0f",
		comment = "#696969",
		string = "#e4b2ab",
		func = "#ff6347",
		kw = "#ff2828",
		identifier = "#d2d2d2",
		type = "#ff420f",
		type_builtin = "#ff420f",
		search_highlight = "#ffaa00",
		operator = "#d63e3e",
		bracket = "#ff6969",
		preprocessor = "#4b8902",

		bool = "#ffa07a",
		constant = "#f59064",
		added = "#baffc9",
		changed = "#ffffba",
		removed = "#ffb3ba",

		pmenu_bg = "#17171d",
		pmenu_sel_bg = "#fa3e19",
		pmenu_fg = "#fc6142",

		bgl = "#090909",

		eob = "#3c3c3c",
		border = "#ff1e00",
		title = "#ff1e00",

		bufferline_selection = "#fd1b1b",
		error = "#ff0000",
		warning = "#ffee00",
		hint = "#00ffee",
		info = "#14ff6a",

		orange1 = "#ff9e64",
		orange2 = "#ff8800",
		orange3 = "#ff5500",
		orange4 = "#db4b4b",

		red1    = "#ff0000",
		red2    = "#ff4444",
		red3    = "#ff6565",
		red4    = "#c53b53",
		green1 = "#00ff99",
		green2 = "#50fa7b",
		green3 = "#73daca",
		green4 = "#2e8b57",

		blue1  = "#00e1ff",
		blue2  = "#61afef",
		blue3  = "#7aa2f7",
		blue4  = "#3d59a1",

		purple1 = "#ff00ff",
		purple2 = "#bd93f9",
		purple3 = "#c678dd",
		purple4 = "#9d7cd8",	

		plugins = {
			gitsigns = true,
			nvim_cmp = true,
			treesitter = true,
			nvimtree = true,
			telescope = true,
			lualine = true,
			bufferline = true,
			oil = true,
			whichkey = true,
			nvim_notify = true,
		},
	},
}

M.extend = function(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
end

-- Toggle Transparency Command
M.toggle_transparency = function()
	M.config.transparent = not M.config.transparent
	M.setup()
	print("Transparency: " .. (M.config.transparent and "ON" or "OFF"))
end

-- Apply the colorscheme
function M.setup(user_config)
	M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
	local colors = M.config.colors

	-- Dynamic Backgrounds for Transparency
	local bg_color = M.config.transparent and "NONE" or colors.bg
	local float_bg = M.config.transparent and "NONE" or colors.pmenu_bg

	local highlight_groups = {
		Normal = { fg = colors.fg, bg = bg_color },
		Cursor = { fg = colors.cursor, bg = bg_color },
		CursorLine = { bg = colors.cursorLine },
		LineNr = { fg = colors.line_nr },
		Visual = { bg = colors.visual },
		MsgArea = { fg = colors.constant, bg = bg_color, italic = true, bold = true },
		ModeMsg = { fg = colors.constant, bold = true },

		-- Comments (Now Bold & Italic)
		Comment = { fg = colors.comment, italic = true, bold = true },

		String = { fg = colors.string },
		Function = { fg = colors.func },
		Keyword = { fg = colors.kw },
		Identifier = { fg = colors.identifier },
		Type = { fg = colors.type },
		PreProc = { fg = colors.preprocessor },
		Boolean = { fg = colors.bool },
		Constant = { fg = colors.constant },

		Search = { fg = colors.search_highlight, bg = "NONE", bold = true },
		IncSearch = { fg = colors.search_highlight, bg = "NONE", bold = true },
		Operator = { fg = colors.operator },
		Delimiter = { fg = colors.bracket },

		-- POPUP MENUS & FLOATING WINDOWS
		Pmenu = { fg = colors.pmenu_fg, bg = colors.pmenu_bg },
		PmenuSel = { fg = colors.pmenu_bg, bg = colors.pmenu_sel_bg, bold = true },

		-- NormalFloat handles Telescope, Lazy, etc.
		NormalFloat = { fg = colors.fg, bg = float_bg },
		FloatBorder = { fg = colors.border, bg = float_bg },

		-- STATUSLINE HIGHLIGHTS
		-- NORMAL:
		ModeNorm = { fg = colors.bg, bg = colors.kw, italic = true, bold = true },
		SepNormA = { fg = colors.kw, bg = colors.pmenu_bg },
		InfoNorm = { fg = colors.fg, bg = colors.pmenu_bg },
		SepNormB = { fg = colors.pmenu_bg, bg = colors.bgl },

		-- INSERT: Bright Orange Background -> Dark Text
		ModeIns = { fg = colors.bg, bg = colors.func, italic = true, bold = true },
		SepInsA = { fg = colors.func, bg = colors.pmenu_bg },
		InfoIns = { fg = colors.fg, bg = colors.pmenu_bg },
		SepInsB = { fg = colors.pmenu_bg, bg = colors.bgl },

		-- VISUAL: Deep Dark Red Background -> White Text
		ModeVis = { fg = colors.bg, bg = colors.type, italic = true, bold = true },
		SepVisA = { fg = colors.type, bg = colors.pmenu_bg },
		InfoVis = { fg = colors.fg, bg = colors.pmenu_bg },
		SepVisB = { fg = colors.pmenu_bg, bg = colors.bgl },

		-- BODY: Blends into void
		StatusBody = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },
		SlRef = { fg = colors.comment, bg = colors.bgl, bold = true, italic = true },

		-- OIL NVIM
    
		OilDir        = { fg = colors.bool, bold = true,italic = true },
		OilPermission = { fg = colors.comment },
		OilSize       = { fg = colors.constant },
		OilDate       = { fg = colors.comment },
		
		OilFile       = { fg = colors.string, italic = true, bold = true },

		OilSocket     = { fg = colors.type },   -- Orange-Red
		OilLink       = { fg = colors.string }, -- Pinkish
		
		OilFloatBorder = { fg = colors.border },
		NormalFloat    = { bg = bg_color },

		-- WELCOME SCREEN
		WelcomeRose = { fg = "#ff5555", bold = true }, -- Red Flower
		WelcomeStem = { fg = "#50fa7b", bold = true }, -- Green Stem
		WelcomeQuote = { fg = "#a1a1a1", italic = true },

		-- Treesitter
		["@function"] = { fg = colors.func },
		["@keyword"] = { fg = colors.kw },
		["@identifier"] = { fg = colors.identifier },
		["@operator"] = { fg = colors.operator },

		-- EndOfBuffer
		EndOfBuffer = {
			fg = M.config.show_end_of_buffer and colors.eob or colors.bg,
			bg = bg_color,
		},

		-- Custom Highlights
		Folded = { fg = "#eb7659", bg = M.config.transparent and "NONE" or "#201010", bold = true, italic = true },
		FoldColumn = { fg = colors.kw, bg = colors.bgl },
		LineNrFold = { fg = colors.kw, bg = colors.bgl },

		-- Search & Highlight
		Search = { bg = "#5631a6", fg = "#ffffff", bold = true },
		CurSearch = { bg = "#ff5555", fg = "#090909", bold = true },
		IncSearch = { bg = "#ff3e0b", fg = "#440000", bold = true },

		-- Flash.nvim
		FlashLabel = { bg = "#FF9E64", fg = "#000000", bold = true },

		-- Multiple Cursors
		MultipleCursorsCursor = { bg = "#00FFFF", fg = "#000000" },
		MultipleCursorsVisual = { bg = "#b294bb", fg = "#000000" },

		CmpBorder = { fg = "#ff5555" },

		-- LSP Diagnostics
		DiagnosticError = { fg = colors.error },
		DiagnosticWarn = { fg = colors.warning },
		DiagnosticHint = { fg = colors.hint },
		DiagnosticInfo = { fg = colors.info },
		DiagnosticVirtualTextError = { fg = colors.error },
		DiagnosticVirtualTextWarn = { fg = colors.warning },
		DiagnosticVirtualTextHint = { fg = colors.hint },
		DiagnosticVirtualTextInfo = { fg = colors.info },

		DiagnosticUnderlineError = { gui = "underline", sp = colors.error },
		DiagnosticUnderlineWarn = { gui = "underline", sp = colors.warning },
		DiagnosticUnderlineHint = { gui = "underline", sp = colors.hint },
		DiagnosticUnderlineInfo = { gui = "underline", sp = colors.info },
	}

	local function apply_highlight(group_name, config)
		local cmd = "highlight " .. group_name

		if config.fg then cmd = cmd .. " guifg=" .. config.fg end
		if config.bg then cmd = cmd .. " guibg=" .. config.bg end
		if config.sp then cmd = cmd .. " guisp=" .. config.sp end

		-- Logic to handle bold/italic booleans and convert to 'gui=...'
		local gui_attrs = {}
		if config.gui then table.insert(gui_attrs, config.gui) end
		if config.bold then table.insert(gui_attrs, "bold") end
		if config.italic then table.insert(gui_attrs, "italic") end
		if config.underline then table.insert(gui_attrs, "underline") end

		if #gui_attrs > 0 then
			cmd = cmd .. " gui=" .. table.concat(gui_attrs, ",")
		end

		-- Glow Logic (adds bold/color to specific groups)
		if M.config.glow and (
				group_name == "Function" or group_name == "Keyword"
				or group_name == "Identifier" or group_name == "Operator"
				or group_name == "@function" or group_name == "@keyword"
				or group_name == "@identifier" or group_name == "@operator"
			) then
			-- Appending glow styles; safe to append usually
			cmd = cmd .. " gui=bold guisp=" .. colors.glow_color
		end

		vim.cmd(cmd)
	end

	-- Apply all highlights
	for group_name, config in pairs(highlight_groups) do
		apply_highlight(group_name, config)
	end

	-- Create User Command for toggling
	vim.api.nvim_create_user_command("ToggleTransparency", M.toggle_transparency, {})
end

return M