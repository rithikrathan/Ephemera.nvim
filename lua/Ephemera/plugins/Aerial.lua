return {
	{
		'stevearc/aerial.nvim',
		event = "VeryLazy",

		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},

		keys = {
			{ "<leader>at", "<cmd>AerialToggle<CR>",       desc = "Toggle Aerial and Focus" },
			{ "<leader>ao", "<cmd>AerialToggle float<CR>", desc = "Toggle Aerial and Focus" },
		},

		config = function()
			require("aerial").setup({
				-- Buffer-local keymaps (only set when aerial attaches)
				on_attach = function(bufnr)
					vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
					vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
				end,

				lazy_load = true,
				backends = { "treesitter", "lsp", "markdown", "asciidoc", "man" },
				default_direction = "right",
				manage_folds = true,
				link_tree_to_folds = true,
				nerd_font = "auto",
				open_automatic = false,
				post_jump_cmd = "normal! zt",
				show_guides = true,

				-- Options for opening aerial in a floating win
				float = {
					border = "rounded",
					relative = "cursor",
					max_height = 0.9,
					height = 10,
					width = 40,
					min_height = { 8, 0.1 },
					min_width = { 25, 0.1 },
				},

				-- Options for the floating nav windows
				nav = {
					border = "rounded",
					max_height = 0.9,
					min_height = { 10, 0.1 },
					max_width = 0.7,
					min_width = { 0.2, 20 },
					win_opts = {
						cursorline = true,
						winblend = 10,
					},
					-- Jump to symbol in source window when the cursor moves
					autojump = false,
					-- Show a preview of the code in the right column, when there are no child symbols
					preview = true,
					-- Keymaps in the nav window
					keymaps = {
						["<CR>"] = "actions.jump",
						["<2-LeftMouse>"] = "actions.jump",
						["<C-v>"] = "actions.jump_vsplit",
						["<C-s>"] = "actions.jump_split",
						["h"] = "actions.left",
						["l"] = "actions.right",
						["<C-c>"] = "actions.close",
					},
				},

				guides = {
					mid_item = "├─",
					last_item = "└─",
					nested_top = "│ ",
					whitespace = "  ",
				},

				lsp = {
					diagnostics_trigger_update = false,
					update_when_errors = true,
					update_delay = 300,
				},

				treesitter = { update_delay = 300 },
				markdown = { update_delay = 300 },
				asciidoc = { update_delay = 300 },
				man = { update_delay = 300 },
			})
		end
	}
}
