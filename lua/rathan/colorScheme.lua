--colorscheme configurations
local colorScheme = require("darkvoid")
local isTransparentandGlow = true
colorScheme.setup({
	transparent = isTransparentandGlow,
	glow = isTransparentandGlow,
	show_end_of_buffer = true,
	colors = {
		fg = "#ffeeee",
		bg = "#800409",
		cursor = "#ffa0a0",
		line_nr = "#ff1010",
		visual = "#690202",
		comment = "#808080",
		string = "#e4b2ab",
		func = "#ff6347",
		kw = "#ff5555",
		identifier = "#d2d2d2",
		type = "#ff420f",
		type_builtin = "#ff420f", -- current
		--type_builtin = "#8cf8f7", -- glowy blue old (was present by default before type_builtin was introduced added here for people who may like it)
		search_highlight = "#03fcc2",
		operator = "#d63e3e",
		bracket = "#ffeeee",
		preprocessor = "#4b8902",
		bool = "#ffa07a",
		constant = "#f59064",

		-- enable or disable specific plugin highlights
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

		-- gitsigns colors
		added = "#baffc9",
		changed = "#ffffba",
		removed = "#ffb3ba",

		-- Pmenu colors
		pmenu_bg = "#1c1c1c",
		pmenu_sel_bg = "#fa3e19",
		pmenu_fg = "#fc6142",

		-- EndOfBuffer color
		eob = "#3c3c3c",

		-- Telescope specific colors
		border = "#ff1e00",
		title = "#ff1e00",

		-- bufferline specific colors
		bufferline_selection = "#03fcc2",

		-- LSP diagnostics colors
		error = "#ff0000",
		warning = "#ffee00",
		hint = "#00ffee",
		info = "#14ff6a",
	},
})

vim.cmd("colorscheme darkvoid")
require("nvim-web-devicons").setup({ default = true })
vim.api.nvim_set_hl(0, "Cursor", { bg = "#FFD0D0", fg = "NONE" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#000000", fg = "#ffffff", bold = true })
