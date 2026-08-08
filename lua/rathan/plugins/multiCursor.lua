return {
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			modes = {
				search = {
					enabled = true,
				},
			}
		},
		keys = {
			{ "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
			{ "<leader>FS", mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
			{ "<leader>fr", mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
			{ "<leader>fR", mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			{ "<C-s>",      mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
		},
	},

	{
		"brenton-leighton/multiple-cursors.nvim",
		version = "*", -- Use the latest tagged version
		opts = {
			custom_key_maps = {
				{ "n", "<Leader>aa", function() require("multiple-cursors").align() end },
			}
		}, -- This causes the plugin setup function to be called

		keys = {
			{ "<A-c>", "<Cmd>MultipleCursorsAddDown<CR>",          mode = { "n", "x", "i" }, desc = "Add cursor and move down" },
			{ "<A-u>", "<Cmd>MultipleCursorsAddUp<CR>",            mode = { "n", "x", "i" }, desc = "Add cursor and move up" },

			{ "<A-x>", "<Cmd>MultipleCursorsMouseAddDelete<CR>",   mode = { "n", "i" },      desc = "Add or remove cursor" },

			{ "`n",    "<Cmd>MultipleCursorsAddVisualArea<CR>",    mode = { "x" },           desc = "Add cursors to the lines of the visual area" },

			{ "<C-n>", "<Cmd>MultipleCursorsAddMatches<CR>",       mode = { "n", "x" },      desc = "Add cursors to cword" },
			{ "<C-b>", "<Cmd>MultipleCursorsAddMatchesV<CR>",      mode = { "n", "x" },      desc = "Add cursors to cword in previous area" },

			{ "<A-m>", "<Cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "x" },      desc = "Add cursor and jump to next cword" },
			{ "`j",    "<Cmd>MultipleCursorsJumpNextMatch<CR>",    mode = { "n", "x" },      desc = "Jump to next cword" },

			{ "`l",    "<Cmd>MultipleCursorsLock<CR>",             mode = { "n", "x" },      desc = "Lock virtual cursors" },
		},
	},
}
