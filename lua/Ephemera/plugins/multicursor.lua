return {
	{
		"jake-stewart/multicursor.nvim",
		branch = "1.0",

		event = "VeryLazy",
		config = function()
			local mc = require("multicursor-nvim")
			mc.setup()

			local set = vim.keymap.set

			-- Add or skip cursor above/below the main cursor.
			set({ "n", "x" }, "<A-up>", function() mc.lineAddCursor(-1) end)
			set({ "n", "x" }, "<A-down>", function() mc.lineAddCursor(1) end)
			set({ "n", "x" }, "<leader><up>", function() mc.lineSkipCursor(-1) end)
			set({ "n", "x" }, "<leader><down>", function() mc.lineSkipCursor(1) end)

			-- Add or skip adding a new cursor by matching word/selection
			set({ "n", "x" }, "<A-right>", function() mc.matchAddCursor(1) end)
			set({ "n", "x" }, "<A-S-right>", function() mc.matchSkipCursor(1) end)
			set({ "n", "x" }, "<A-left>", function() mc.matchAddCursor(-1) end)
			set({ "n", "x" }, "<A-S-right>", function() mc.matchSkipCursor(-1) end)

			-- Add and remove cursors with control + left click.
			set("n", "<c-leftmouse>", mc.handleMouse)
			set("n", "<c-leftdrag>", mc.handleMouseDrag)
			set("n", "<c-leftrelease>", mc.handleMouseRelease)

			-- Disable and enable cursors.
			set({ "n", "x" }, "<A-,>", mc.toggleCursor)

			-- Mappings defined in a keymap layer only apply when there are
			-- multiple cursors. This lets you have overlapping mappings.
			mc.addKeymapLayer(function(layerSet)
				-- Select a different cursor as the main one.
				layerSet({ "n", "x" }, "<left>", mc.prevCursor)
				layerSet({ "n", "x" }, "<right>", mc.nextCursor)

				-- Delete the main cursor.
				layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor)

				-- Enable and clear cursors using escape.
				layerSet("n", "<esc>", function()
					if not mc.cursorsEnabled() then
						mc.enableCursors()
					else
						mc.clearCursors()
					end
				end)
			end)
		end
	},

	-- TODO: learn to use all the things you can use with this thing
	-- > also add the mode text for this like MULTI CURSOR or something idk
	{
		"brenton-leighton/multiple-cursors.nvim",
		event = "VeryLazy",
		version = "*",
		opts = {
			pre_hook = function()
				require("cmp").setup({ enabled = false })
				-- require('ultimate-autopair').disable()
			end,
			post_hook = function()
				require("cmp").setup({ enabled = true })
				-- require('ultimate-autopair').enable()
				vim.g.minipairs_disable = false
			end,
			custom_key_maps = {
				{ "n", "<Leader>al", function() require("multiple-cursors").align() end },
			}
		}, -- This causes the plugin setup function to be called

		keys = {
			{ "<A-c>", "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "x", "i" }, desc = "Add cursor and move down" },
			{ "<A-u>", "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "x", "i" }, desc = "Add cursor and move up" },

			{ "<A-m>", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "i", "x" }, desc = "Add cursor and jump to next cword" },
			{ "<A-M>", "<Cmd>MultipleCursorsJumpNextMatch<CR>",    mode = { "n", "x" },      desc = "Jump to next cword" },

			{ "<A-x>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" },      desc = "Add or remove cursor" },
			{ "`n",    "<Cmd>MultipleCursorsAddVisualArea<CR>",    mode = { "x" },           desc = "Add cursors to the lines of the visual area" },
			{ "<C-n>", "<Cmd>MultipleCursorsAddMatches<CR>",       mode = { "n", "x" },      desc = "Add cursors to cword" },
			{ "<C-b>", "<Cmd>MultipleCursorsAddMatchesV<CR>",      mode = { "n", "x" },      desc = "Add cursors to cword in previous area" },
			{ "`l",    "<Cmd>MultipleCursorsLock<CR>",             mode = { "n", "x" },      desc = "Lock virtual cursors" },
		},
	}

}
