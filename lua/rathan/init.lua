--  YES I dont understand it either but i figured it out by myself anyway
require("rathan.lazy")         --Lazy config files
require("rathan.pluginConfig") --All plugin specific configurations
require("rathan.remap")        --Custom key remaps
-- require("rathan.colorScheme")

-- Behold! the unecessary ASCII art

local rathan = [[
     ##### /##                         /
  ######  / ##                       #/
 /#   /  /  ##                 #     ##
/    /  /   ##                ##     ##
    /  /    /                 ##     ##
   ## ##   /       /###     ######## ##  /##      /###   ###  /###
   ## ##  /       / ###    ########  ## / ###    / ###    ###/ ####
   ## ###/       /   ###      ##     ##/   ###  /   ###    ##   ###
   ## ##  ###   ##    ##      ##     ##     ## ##    ##    ##    ##
   ## ##    ##  ##    ##      ##     ##     ## ##    ##    ##    ##
   #  ##    ##  ##    ##      ##     ##     ## ##    ##    ##    ##
      /     ##  ##    ##      ##     ##     ## ##    ##    ##    ##
  /##/      ### ##    /#      ##     ##     ## ##    /#    ##    ##
 /  ####    ##   ####/ ##     ##     ##     ##  ####/ ##   ###   ###
/    ##     #     ###   ##     ##     ##    ##   ###   ##   ###   ###
#                                           /
 ##                                        /
                                          /


]]

print(rathan)
print("Is this big ass ASCII art necessary? No, Did i add it anyway? Fuck yes!")

--Godot stuffs
local pipepath = vim.fn.stdpath("cache") .. "/server.pipe"
if not vim.loop.fs_stat(pipepath) then
	vim.fn.serverstart(pipepath)
end
--general vim configurations

vim.g.netrw_keepdir = true --if false update the currentworkingdirectory everytime you navigate the netrw
vim.opt.expandtab = false
vim.opt.signcolumn = "yes"
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.g.have_nerd_font = true
vim.opt.undofile = true
vim.opt.expandtab = false
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.updatetime = 400
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

vim.opt.splitright = true
vim.opt.splitbelow = true

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars = {
	foldopen = "▾", -- Symbol for an open fold
	foldclose = "▸", -- Symbol for a closed fold (+)
	foldsep = "┊", -- Symbol for lines within an open fold (|)
	fold = " " -- Filler character for empty space in the fold column
}

-- Define a custom function to generate the advanced fold text
function _G.foldText()
	local fs, fe = vim.v.foldstart, vim.v.foldend
	local line = vim.fn.getline(fs)
	local line_count = fe - fs + 1
	local total_lines = vim.api.nvim_buf_line_count(0)
	local percentage = math.floor((line_count / total_lines) * 100)
	return string.format("╰┈➤  %s ... %d lines (%d%%)", line, line_count, percentage)
end

vim.opt.foldtext = "v:lua.foldText()"

-- normal configurations
vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", trail = ".", nbsp = "␣" }

vim.fn.sign_define("DiagnosticSignError", { text = "❖", texthl = "DiagnosticSignError" })
--vim.fn.sign_define("DiagnosticSignError", { text = "🤦", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "✯", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "⚑", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "⧐", texthl = "DiagnosticSignInfo" })

-- dealing with transparency?
vim.cmd([[
 highlight! link LspSignatureActiveParameter IncSearch
 highlight! FloatBorder guibg=NONE guifg=#888888
 highlight! NormalFloat guibg=NONE
 ]])

-- hope this fixes verible issues
-- Setting the filetype for Verilog
vim.api.nvim_create_autocmd(
	{ "BufNewFile", "BufRead" }, {
		pattern = { "*.v" },
		command = "set filetype=verilog",
	}
)

-- Setting the filetype for SystemVerilog
vim.api.nvim_create_autocmd(
	{ "BufNewFile", "BufRead" }, {
		pattern = { "*.sv" },
		command = "set filetype=systemverilog",
	}
)

-- autocmmands
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.pyde",
	callback = function()
		vim.bo.filetype = "python"
	end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.pde",
	callback = function()
		vim.bo.filetype = "processing"
	end,
})

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank { higroup = "IncSearch", timeout = 120 }
	end,
})

local function fix_colors()
	-- fold column and text colours
	-- vim.api.nvim_set_hl(0, "Folded", { fg = "#AF87FF", bg = "none", bold = true, italic = true })
	-- vim.api.nvim_set_hl(0, "Folded", { fg = "#68b859", bg = "none", bold = true, italic = true })
	-- vim.api.nvim_set_hl(0, "Folded", { fg = "#eb7659", bg = "none", bold = true, italic = true })
	vim.api.nvim_set_hl(0, "Folded", { fg = "#eb7659", bg = "#201010", bold = true, italic = true })
	vim.api.nvim_set_hl(0, "FoldColumn", { fg = "#eb7659", bg = "#201010" })
	vim.api.nvim_set_hl(0, "LineNrFold", { fg = "#eb7659", bg = "#201010" })
	-- Standard Search
	vim.api.nvim_set_hl(0, "Search",
		{ bg = "#5631a6", fg = "#ffffff", ctermfg = "Black", force = true })
	vim.api.nvim_set_hl(0, "CurSearch",
		{ bg = "#ff5555", fg = "#FFFFFF", ctermbg = "Red", ctermfg = "White", force = true })
	vim.api.nvim_set_hl(0, "IncSearch",
		{ bg = "#ff3e0b", fg = "#440000", ctermbg = "Red", ctermfg = "Black", force = true })

	-- Flash.nvim
	vim.api.nvim_set_hl(0, "FlashLabel",
		{ bg = "#FF9E64", fg = "#000000", ctermbg = "Magenta", ctermfg = "White", bold = true, force = true })

	-- Multiple Cursors
	vim.api.nvim_set_hl(0, "MultipleCursorsCursor",
		{ bg = "#00FFFF", fg = "#000000", ctermbg = "Cyan", ctermfg = "Black", force = true })
	vim.api.nvim_set_hl(0, "MultipleCursorsVisual",
		{ bg = "#b294bb", fg = "#000000", ctermbg = "Magenta", ctermfg = "Black", force = true })

	vim.api.nvim_set_hl(0, "CmpBorder", { fg = "#ff5555" })
end

local group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = fix_colors,
	group = group, -- This prevents duplicates when you :so the file
})

fix_colors()

-- Create an autocommand group for Processing
vim.api.nvim_create_autocmd("FileType", {
	pattern = "processing",
	callback = function()
		-- Map <leader>r to save and run the sketch
		-- vim.keymap.set("n", "<leader>r", ":w <bar> make<CR>", { buffer = true, desc = "Run Processing Sketch" })
	end,
})
