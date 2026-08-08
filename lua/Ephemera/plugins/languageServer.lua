return {
	{ 'neovim/nvim-lspconfig' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	-- { "ray-x/lsp_signature.nvim",         config = true },
	{ 'hrsh7th/nvim-cmp' },
	{ 'hrsh7th/cmp-path' },
	{ 'hrsh7th/cmp-cmdline' },
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/cmp-calc' },
	{ 'f3fora/cmp-spell' },
	--testing
	{ 'lukas-reineke/cmp-rg' },
	{ 'onsails/lspkind.nvim' },
	{ 'williamboman/mason.nvim' },
	{ 'williamboman/mason-lspconfig.nvim' },
	{ 'mfussenegger/nvim-jdtls' },

	-- fidget
	{
		"j-hui/fidget.nvim",
		event = "LspAttach",
		opts = {
			notification = {
				window = {
					winblend = 0, -- Background transparency (0 is opaque)
					max_width = 30, -- Limits how wide the box can get
					align = "top",
					relative = "editor",
					max_height = 10, -- Limits how many lines it shows
					border = "single", -- Thin border makes it look smaller
					zindex = 45, -- Keeps it below other UI elements if needed
				},
			},
			progress = {
				display = {
					render_limit = 3, -- Only show 3 tasks at once to keep it short
				},
			},
		},
		config = function()
			vim.keymap.set("n", "<leader>fn", function()
				require("fidget").notification.toggle()
			end, { desc = "Toggle Fidget Notifications" })
		end

	}, --  lsp notifications

	{
		"rachartier/tiny-inline-diagnostic.nvim",
		event = "VeryLazy",
		priority = 1000,
		config = function()
			require("tiny-inline-diagnostic").setup({
				preset = "classic",
				transparent_bg = false,
				transparent_cursorline = false,
				hi = {
					error = "DiagnosticError",
					warn = "DiagnosticWarn",
					info = "DiagnosticInfo",
					hint = "DiagnosticHint",
					arrow = "NonText",
					background = "CursorLine",
					mixing_color = "None",
				},
				options = {
					show_source = { enabled = false, if_many = false },
					use_icons_from_diagnostic = false,
					set_arrow_to_diag_color = false,
					add_messages = true,
					throttle = 20,
					softwrap = 30,
					multilines = { enabled = false, always_show = false },
					show_all_diags_on_cursorline = false,
					enable_on_insert = false,
					enable_on_select = false,
					overflow = { mode = "wrap", padding = 0 },
					break_line = { enabled = false, after = 30 },
					format = nil,
					virt_texts = { priority = 2048 },
					severity = {
						vim.diagnostic.severity.ERROR,
						vim.diagnostic.severity.WARN,
						vim.diagnostic.severity.INFO,
						vim.diagnostic.severity.HINT,
					},
					overwrite_events = nil,
				},
				disabled_ft = {},
			})
			vim.diagnostic.config({ virtual_text = false })
		end,

	}, -- inline diagnostic

	-- using conform for formatting
	{
		'stevearc/conform.nvim',
		opts = {},
		config = function()
			local conform = require("conform")

			--Define exclusion list here
			local excluded_extensions = { "l", "y", "txt" }

			conform.setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					rust = { "rustfmt", lsp_format = "fallback" },
					javascript = { "prettierd", "prettier", stop_after_first = true },
					verilog = { "istyle" },
					systemverilog = { "istyle" },
				},
				format_on_save = function(bufnr)
					-- Get the current file extension
					local bufname = vim.api.nvim_buf_get_name(bufnr)
					local extension = vim.fn.fnamemodify(bufname, ":e")

					--Check if the extension is in excluded list
					if vim.tbl_contains(excluded_extensions, extension) then
						print("Excluding formatter....")
						return
					end

					return { timeout_ms = 500, lsp_format = "fallback" }
				end,
			})

			-- Manual format keymap
			vim.keymap.set("n", "<leader>fo", function()
				conform.format({ lsp_fallback = true, async = false, timeout_ms = 500 })
			end)
		end
	},

	-- context treesitter thing
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require 'treesitter-context'.setup {
				enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
				multiwindow = true, -- Enable multiwindow support.
				max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
				min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
				line_numbers = true,
				multiline_threshold = 14, -- Maximum number of lines to show for a single context
				trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
				mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
				-- separator = "·", -- This creates a subtle dotted line across the screen
				-- separator = "┄", -- Alternative: Unicode dashed line for a "dashed" look
				-- separator = "-", -- Alternative: Standard dash			zindex = 20, -- The Z-index of the context window
				on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
			}
		end
	},

	-- breadcrumbs
	-- {
	-- 	"utilyre/barbecue.nvim",
	-- 	name = "barbecue",
	-- 	version = "*",
	-- 	dependencies = {
	-- 		"SmiteshP/nvim-navic",
	-- 		"nvim-tree/nvim-web-devicons", -- optional dependency
	-- 	},

	-- 	config = function()
	-- 		-- triggers CursorHold event faster
	-- 		vim.opt.updatetime = 200

	-- 		require("barbecue").setup({
	-- 			create_autocmd = false, -- prevent barbecue from updating itself automatically
	-- 		})

	-- 		vim.api.nvim_create_autocmd({
	-- 			"WinScrolled", -- or WinResized on NVIM-v0.9 and higher
	-- 			"BufWinEnter",
	-- 			"CursorHold",
	-- 			"InsertLeave",

	-- 			-- include this if you have set `show_modified` to `true`
	-- 			"BufModifiedSet",
	-- 		}, {
	-- 			group = vim.api.nvim_create_augroup("barbecue.updater", {}),
	-- 			callback = function()
	-- 				require("barbecue.ui").update()
	-- 			end,
	-- 		})
	-- 	end
	-- },

	-- trouble whateverthis is
	-- {
	-- 	"folke/trouble.nvim",
	-- 	opts = {}, -- for default options, refer to the configuration section for custom setup.
	-- 	cmd = "Trouble",
	-- 	keys = {
	-- 		{
	-- 			"<leader>xx",
	-- 			"<cmd>Trouble diagnostics toggle<cr>",
	-- 			desc = "Diagnostics (Trouble)",
	-- 		},
	-- 		{
	-- 			"<leader>xX",
	-- 			"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	-- 			desc = "Buffer Diagnostics (Trouble)",
	-- 		},
	-- 		{
	-- 			"<leader>cs",
	-- 			"<cmd>Trouble symbols toggle focus=false<cr>",
	-- 			desc = "Symbols (Trouble)",
	-- 		},
	-- 		{
	-- 			"<leader>cl",
	-- 			"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	-- 			desc = "LSP Definitions / references / ... (Trouble)",
	-- 		},
	-- 		{
	-- 			"<leader>xL",
	-- 			"<cmd>Trouble loclist toggle<cr>",
	-- 			desc = "Location List (Trouble)",
	-- 		},
	-- 		{
	-- 			"<leader>xQ",
	-- 			"<cmd>Trouble qflist toggle<cr>",
	-- 			desc = "Quickfix List (Trouble)",
	-- 		},
	-- 	},
	-- },

	-- refactoring plugin
	{
		'ThePrimeagen/refactoring.nvim',
		event = "VeryLazy",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-treesitter/nvim-treesitter',
            "lewis6991/async.nvim"
		},

		cmd = 'Refactor',
		keys = {
			-- 1. THE REFACTOR MENU (The "Prime" way)
			{
				'<leader>rr',
				function() require('refactoring').select_refactor() end,
				mode = { 'n', 'x' },
				desc = 'Refactor: Open Menu',
			},

			-- -- 2. EXTRACTION (Mostly Visual Mode)
			-- {
			-- 	'<leader>re',
			-- 	[[ <Esc><Cmd>Refactor extract <CR>]],
			-- 	mode = 'x',
			-- 	desc = 'Refactor: Extract Selection',
			-- },
			-- {
			-- 	'<leader>rf',
			-- 	[[ <Esc><Cmd>Refactor extract_to_file <CR>]],
			-- 	mode = 'x',
			-- 	desc = 'Refactor: Extract to File',
			-- },
			-- {
			-- 	'<leader>rv',
			-- 	[[ <Esc><Cmd>Refactor extract_var <CR>]],
			-- 	mode = 'x',
			-- 	desc = 'Refactor: Extract Variable',
			-- },

			-- -- 3. INLINE (Normal and Visual)
			-- {
			-- 	'<leader>ri',
			-- 	function() require('refactoring').refactor('Inline Variable') end,
			-- 	mode = { 'n', 'x' },
			-- 	desc = 'Refactor: Inline Variable',
			-- },

			-- -- 4. BLOCK OPERATIONS (Normal Mode)
			-- {
			-- 	'<leader>rb',
			-- 	function() require('refactoring').refactor('Extract Block') end,
			-- 	mode = 'n',
			-- 	desc = 'Refactor: Extract Block',
			-- },
			-- {
			-- 	'<leader>rbf',
			-- 	function() require('refactoring').refactor('Extract Block To File') end,
			-- 	mode = 'n',
			-- 	desc = 'Refactor: Extract Block to File',
			-- },
		},

		opts = {
			-- Prompt for function parameters and return types for specific languages
			prompt_func_param_type = {
				cpp = true,
				hpp = true,
				c = true,
				h = true,
				java = true,
			},
			prompt_func_return_type = {
				cpp = true,
				hpp = true,
				c = true,
				h = true,
				java = true,
			},
		},
		config = function(_, opts)
			require('refactoring').setup(opts)

			-- Optional: Load Telescope extension if you use Telescope
			-- require('telescope').load_extension('refactoring')
		end,
	}
}
