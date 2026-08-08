-- Ephemera Vanilla Configuration - Pure Neovim without external plugins
require("Ephemera_vanilla.options")              -- General vim.opt settings
require("Ephemera_vanilla.welcome").setup()      -- Local welcomeScreen
require("Ephemera_vanilla.theme.colors").setup() -- Local colorScheme
require("Ephemera_vanilla.statusLine")           -- Local statusline
require("Ephemera_vanilla.keybinds")             -- Global keybindings
require("Ephemera_vanilla.commands")              -- Autocommands and user defined commands

-- global variables 
vim.g.use_git_plugins = false
vim.g.is_transparent = false

-- some variables
_G.statusMessage = "She's catfishing you bro beware" 
-- _G.statusMessage = "@rathan"
_G.git_branch = ""

-- Git Logic (Defined early so statusline can find it)
local function update_git()
	local h = io.popen("git branch --show-current 2> /dev/null")
	if h then
		local b = h:read("*a")
		h:close()
		_G.git_branch = (b and b ~= "") and ("  " .. b:gsub("\n", "") .. " ") or ""
	end
end

vim.schedule(function()
	print("Rathan's Vanilla Config (Ephemera_vanilla) Loaded.")
end)
