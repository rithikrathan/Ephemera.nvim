return {
	--  for diagrams
	{ "jbyuki/venn.nvim", ft = { "markdown", "text" } },

	-- for colours
	{ "uga-rosa/ccc.nvim" },

	-- render markdown
	{
		'MeanderingProgrammer/render-markdown.nvim',
		dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
		opts = {},
		ft = { "markdown", "text" }
	},


	{
		"allaman/emoji.nvim",
		version = "1.0.0", -- optionally pin to a tag

		ft = { "markdown", "text", "*" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
			"nvim-telescope/telescope.nvim",
		},
		opts = {
			enable_cmp_integration = false,
		},
		config = function(_, opts)
			require("emoji").setup(opts)

			-- optional for telescope integration
			local ts = require('telescope').load_extension 'emoji'
			vim.keymap.set('n', '<leader>se', ts.emoji, { desc = '[S]earch [E]moji' })
		end,
	},


	-- markdown tools
	{
		"tadmccorkle/markdown.nvim",
		ft = { "markdown", "text" }
	},

	-- todo comment highlights
	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
		}
	},

	-- to do list
	{
		"atiladefreitas/dooing",
		config = function()
			require("dooing").setup({
				-- Core settings
				save_path = vim.fn.stdpath("data") .. "/dooing_todos.json",

				-- Timestamp settings
				timestamp = {
					enabled = true, -- Show relative timestamps (e.g., @5m ago, @2h ago)
				},

				-- Window settings
				window = {
					width = 69, -- Width of the floating window
					height = 15, -- Height of the floating window
					border = 'double', -- Border style: 'single', 'double', 'rounded', 'solid'
					position = 'top', -- Window position: 'right', 'left', 'top', 'bottom', 'center',
					-- 'top-right', 'top-left', 'bottom-right', 'bottom-left'
					padding = {
						top = 3,
						bottom = 6,
						left = 2,
						right = 2,
					},
				},

				-- To-do formatting
				formatting = {
					pending = {
						icon = "⏱️",
						format = { "icon", "notes_icon", "text", "due_date", "ect" },
					},
					in_progress = {
						icon = "🛠️",
						format = { "icon", "text", "due_date", "ect" },
					},
					done = {
						icon = "☑️",
						format = { "icon", "notes_icon", "text", "due_date", "ect" },
					},
				},
				quick_keys = false, -- Quick keys window
				notes = {
					icon = "📓",
				},

				scratchpad = {
					syntax_highlight = "markdown",
				},

				-- Per-project todos
				per_project = {
					enabled = true,    -- Enable per-project todos
					default_filename = "dooing.json", -- Default filename for project todos
					auto_gitignore = "prompt", -- Auto-add to .gitignore (true/false/"prompt")
					on_missing = "prompt", -- What to do when file missing ("prompt"/"auto_create")
					auto_open_project_todos = true, -- Auto-open project todos on startup if they exist
				},

				-- Nested tasks
				nested_tasks = {
					enabled = true,       -- Enable nested subtasks
					indent = 2,           -- Spaces per nesting level
					retain_structure_on_complete = true, -- Keep nested structure when completing tasks
					move_completed_to_end = true, -- Move completed nested tasks to end of parent group
				},

				-- Due date notifications
				due_notifications = {
					enabled = true, -- Enable due date notifications
					on_startup = false, -- Show notification on Neovim startup
					on_open = true, -- Show notification when opening todos
				},

				-- Keymaps
				keymaps = {
					toggle_window = "<leader>jg", -- Toggle global todos
					open_project_todo = "<leader>jj", -- Toggle project-specific todos
					show_due_notification = "<leader>jN", -- Show due items window
					new_todo = "i",
					create_nested_task = "<leader>jn", -- Create nested subtask under current todo
					toggle_todo = "f",
					delete_todo = "d",
					delete_completed = "D",
					close_window = "q",
					undo_delete = "u",
					add_due_date = "H",
					remove_due_date = "r",
					toggle_help = "?",
					toggle_tags = "t",
					toggle_priority = "i",
					clear_filter = "c",
					edit_todo = "e",
					edit_tag = "e",
					edit_priorities = "p",
					delete_tag = "d",
					search_todos = "/",
					add_time_estimation = "T",
					remove_time_estimation = "R",
					import_todos = "I",
					export_todos = "E",
					remove_duplicates = "<leader>D",
					open_todo_scratchpad = "<CR>",
					refresh_todos = "<leader>r",
				},

				calendar = {
					language = "en",
					icon = "🗓️",
					keymaps = {
						previous_day = "h",
						next_day = "l",
						previous_week = "k",
						next_week = "j",
						previous_month = "H",
						next_month = "L",
						select_day = "<CR>",
						close_calendar = "q",
					},
				},

				-- Priority settings
				priorities = {
					{
						name = "important",
						weight = 4,
					},
					{
						name = "urgent",
						weight = 2,
					},
				},
				priority_groups = {
					high = {
						members = { "important", "urgent" },
						color = nil,
						hl_group = "DiagnosticError",
					},
					medium = {
						members = { "important" },
						color = nil,
						hl_group = "DiagnosticWarn",
					},
					low = {
						members = { "urgent" },
						color = nil,
						hl_group = "DiagnosticInfo",
					},
				},
				hour_score_value = 1 / 8,
				done_sort_by_completed_time = false,
			})
		end,
	}
}
