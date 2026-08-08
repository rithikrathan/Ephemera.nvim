-- ==========================================================================
-- 1. COLORSCHEME & UI
-- ==========================================================================
local csName = "darkvoid"
local colorScheme = require(csName)
local istransparent = true


vim.api.nvim_create_user_command("ToggleTransparency",
	function()
		istransparent = not istransparent
		colorScheme.setup({
			transparent = istransparent,
		})
		vim.cmd("colorscheme " .. csName)
		require("lualine").setup({
			options = {
				theme = "Ra-lualine",
			},
		})

		-- Re-apply highlights after toggling
		vim.cmd("highlight minimapCursor ctermbg=59 ctermfg=228 guibg=#5F5F5F guifg=#ff5555")
		vim.cmd("highlight minimapCursor ctermbg=238 ctermfg=228 guibg= #121212 guifg = #d70000")
		vim.cmd("highlight minimapRange ctermbg=242 ctermfg=228 guibg= #262626 guifg = #ff5555")
		vim.cmd("highlight minimapDiffRemoved ctermfg=197 guifg=#c70a52")
		vim.cmd("highlight minimapDiffAdded ctermfg=148 guifg=#82b500")
		vim.cmd("highlight minimapDiffLine ctermfg=141 guifg=#9162f0")
		vim.cmd("highlight minimapCursorDiffRemoved ctermbg=59 ctermfg=197 guibg=#5F5F5F guifg=#FC1A70")
		vim.cmd("highlight minimapCursorDiffAdded ctermbg=59 ctermfg=148 guibg=#5F5F5F guifg=#A4E400")
		vim.cmd("highlight minimapCursorDiffLine ctermbg=59 ctermfg=141 guibg=#5F5F5F guifg=#AF87FF")
		vim.cmd("highlight minimapRangeDiffRemoved ctermbg=242 ctermfg=197 guibg=#4F4F4F guifg=#FC1A70")
		vim.cmd("highlight minimapRangeDiffAdded ctermbg=242 ctermfg=148 guibg=#4F4F4F guifg=#A4E400")
		vim.cmd("highlight minimapRangeDiffLine ctermbg=242 ctermfg=141 guibg=#4F4F4F guifg=#AF87FF")
	end, {}
)
-- #ff5555
-- #FC1A70
-- #AF87FF

colorScheme.setup({
	transparent = istransparent,
	glow = istransparent,
	show_end_of_buffer = true,
	colors = {
		fg = "#ffeeee",
		bg = "#040409",
		cursor = "#ffa0a0",
		line_nr = "#ff1010",
		visual = "#690f0f",
		comment = "#696969",
		string = "#e4b2ab",
		func = "#ff6347",
		kw = "#ff5555",
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
		pmenu_bg = "#1c1c2f",
		pmenu_sel_bg = "#fa3e19",
		pmenu_fg = "#fc6142",

		eob = "#3c3c3c",
		border = "#ff1e00",
		title = "#ff1e00",

		bufferline_selection = "#fd1b1b",
		error = "#ff0000",
		warning = "#ffee00",
		hint = "#00ffee",
		info = "#14ff6a",

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
})
vim.cmd("colorscheme darkvoid")
-- vim.cmd("doautocmd ColorScheme")

-- TODO: add a way to show flash status in lualine

require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "Ra-lualine",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = true,
		refresh = { statusline = 100, tabline = 100, winbar = 100 },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch", "filename", "aerial" },
		lualine_c = { "searchcount" },
		lualine_x = { "fileformat", "encoding" },
		lualine_y = { "progress", "location", "filetype" },
		lualine_z = { "mode" },
	},
})

-- Treesitter
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "python", "cpp", "java", "gdscript" },
	sync_install = false,
	auto_install = true,
	highlight = { enable = true, additional_vim_regex_highlighting = false },
	textobjects = {
		select = {
			enable = true,
			lookahead = true,
			keymaps = { ["af"] = "@function.outer", ["if"] = "@function.inner", ["ac"] = "@class.outer", ["ic"] = "@class.inner" }
		}
	},
	move = {
		enable = true,
		goto_next_start = { ["]m"] = "@function.outer" },
		goto_previous_start = { ["[m"] = "@function.outer" }
	}
})

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup({})
local conf = require("telescope.config").values
local function toggle_telescope(harpoon_files)
	local file_paths = {}
	for _, item in ipairs(harpoon_files.items) do table.insert(file_paths, item.value) end
	require("telescope.pickers").new({}, {
		prompt_title = "Harpoon",
		finder = require("telescope.finders").new_table({ results = file_paths }),
		previewer = conf.file_previewer({}),
		sorter = conf.generic_sorter({}),
		initial_mode = "normal",
	}):find()
end
vim.keymap.set("n", "<leader>e", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })

-- UndoTree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)


-- ==========================================================================
-- 2. MODERN LSP CONFIGURATION (Correct Exclude Method)
-- ==========================================================================
local mason = require("mason")
local masonConf = require("mason-lspconfig")
local lspconfig = require("lspconfig")

-- 1. Setup Mason
mason.setup({ ui = { border = "rounded" }, registries = { "github:mason-org/mason-registry" } })

-- 2. Global Capabilities
local caps = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities())
vim.lsp.config("*", { capabilities = caps })

-- 3. Mason LSP Config with Explicit Handlers (The "Exclude" Fix)
masonConf.setup({
	ensure_installed = { "clangd", "jdtls", "verible" },

	-- Defining handlers INSIDE setup() is the clean, correct syntax.
	handlers = {

		-- Default handler: Setup every server Mason finds automatically...
		function(server_name)
			lspconfig[server_name].setup({ capabilities = caps })
		end,

		-- EXCLUDE JDTLS: Mapping it to an empty function prevents automatic setup.
		-- This allows your manual config at the bottom to work without interference.
		["jdtls"] = function() end,

		-- Specific overrides for other servers
		["clangd"] = function()
			lspconfig.clangd.setup({
				capabilities = caps,
				cmd = { "clangd", "--compile-commands-dir=" .. vim.loop.cwd() },
				filetypes = { "c", "cpp", "objc", "objcpp", "ino" },
				init_options = { usePlaceholders = true, completeUnimported = true },
			})
		end,

		["arduino_language_server"] = function()
			lspconfig.arduino_language_server.setup({
				capabilities = caps,
				cmd = {
					"arduino-language-server",
					"-clangd", "/home/godz/.local/share/nvim/mason/bin/clangd",
					"-clangd", "/usr/bin/clangd",
					"-cli", "/home/godz/.local/bin/arduino-cli",
					"-cli-config", "/home/godz/.arduino15/arduino-cli.yaml",
					"-fqbn", "esp8266:esp8266:nodemcuv2"
				},
			})
		end,

		["verible"] = function()
			lspconfig.verible.setup({
				capabilities = caps,
				cmd = { "verible-verilog-ls", "--indentation_spaces=0", "--rules_config_search" },
				filetypes = { "verilog", "systemverilog" },
			})
		end,
	}
})

-- Verilog Auto-format
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.v", "*.sv" },
	callback = function() vim.lsp.buf.format({ async = false }) end,
})


-- ==========================================================================
-- 3. COMPLETION
-- ==========================================================================
local cmp = require("cmp")
local lspkind = require("lspkind")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

vim.g.cmp_enabled = false
vim.g.cmp_ghost = false

local function apply_cmp()
	cmp.setup({
		enabled = vim.g.cmp_enabled,

		snippet = {
			expand = function(args)
				vim.snippet.expand(args.body)
			end,
		},

		completion = {
			autocomplete = vim.g.cmp_enabled and { cmp.TriggerEvent.TextChanged } or false,
		},

		experimental = {
			ghost_text = vim.g.cmp_ghost,
		},

		window = {
			completion = cmp.config.window.bordered({
				border = "rounded",
				winhighlight = "Normal:Normal,FloatBorder:CmpBorder,CursorLine:Visual",
				max_height = 8, -- shows only 6 entries
				max_width = 20, -- shows only 6 entries
			}),
			documentation = cmp.config.window.bordered({
				border = "rounded",
				winhighlight = "Normal:Normal,FloatBorder:CmpBorder,CursorLine:Visual",
				max_height = 14,
				max_width = 69,
			}),
		},

		formatting = {
			format = lspkind.cmp_format({
				-- mode = "text_symbol",
				-- mode = "symbol",
				mode = "text",
				maxwidth = { menu = 50, abbr = 50 },
				ellipsis_char = "...",
				show_labelDetails = false,
			}),
		},

		mapping = cmp.mapping.preset.insert({
			["<A-k>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
			["<A-j>"] = cmp.mapping.select_next_item({ behavior = "select" }),
			["<A-i>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
			["<A-c>"] = cmp.mapping.complete(),

			["<C-u>"] = cmp.mapping.scroll_docs(-4),
			["<C-d>"] = cmp.mapping.scroll_docs(4),

			["<A-b>"] = cmp.mapping(function(fallback)
				local entry = cmp.get_selected_entry()
				if entry then
					cmp.open_docs()
				else
					fallback()
				end
			end, { "i", "s" }),
		}),

		sources = {
			{ name = "nvim_lsp" },
			{ name = "verible" },
			{ name = "path" },
			{ name = "luasnip" },
			{ name = "html-css" },
			{
				name = "buffer",
				option = {
					get_bufnrs = function()
						return vim.api.nvim_list_bufs()
					end,
				},
			},
			{ name = "rg",   keyword_length = 3 },
			{ name = "calc" },
			{ name = "spell" },
		},
	})
end

apply_cmp()

vim.api.nvim_create_user_command("ToggleCompletion", function()
	vim.g.cmp_enabled = not vim.g.cmp_enabled
	vim.g.cmp_ghost = vim.g.cmp_enabled
	apply_cmp()
end, {})

cmp.setup.filetype("go", {
	preselect = cmp.PreselectMode.None,
	completion = { completeopt = "menu,menuone,noinsert,noselect" },
})

cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
-- ==========================================================================
-- 4. MINIMAP HIGHLIGHTS
-- ==========================================================================
vim.cmd("highlight minimapCursor ctermbg=59 ctermfg=228 guibg=#5F5F5F guifg=#ff5555")
vim.cmd("highlight minimapCursor ctermbg=238 ctermfg=228 guibg= #121212 guifg = #d70000")
vim.cmd("highlight minimapRange ctermbg=242 ctermfg=228 guibg= #262626 guifg = #ff5555")
vim.cmd("highlight minimapDiffRemoved ctermfg=197 guifg=#c70a52")
vim.cmd("highlight minimapDiffAdded ctermfg=148 guifg=#82b500")
vim.cmd("highlight minimapDiffLine ctermfg=141 guifg=#9162f0")
vim.cmd("highlight minimapCursorDiffRemoved ctermbg=59 ctermfg=197 guibg=#5F5F5F guifg=#FC1A70")
vim.cmd("highlight minimapCursorDiffAdded ctermbg=59 ctermfg=148 guibg=#5F5F5F guifg=#A4E400")
vim.cmd("highlight minimapCursorDiffLine ctermbg=59 ctermfg=141 guibg=#5F5F5F guifg=#AF87FF")
vim.cmd("highlight minimapRangeDiffRemoved ctermbg=242 ctermfg=197 guibg=#4F4F4F guifg=#FC1A70")
vim.cmd("highlight minimapRangeDiffAdded ctermbg=242 ctermfg=148 guibg=#4F4F4F guifg=#A4E400")
vim.cmd("highlight minimapRangeDiffLine ctermbg=242 ctermfg=141 guibg=#4F4F4F guifg=#AF87FF")

-- ==========================================================================
-- 5. OTHER PLUGINS & KEYMAPS
-- ==========================================================================
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/additional files/snippets/" })
vim.keymap.set({ "i" }, "<leader>fk", function() ls.expand() end)
vim.keymap.set({ "i", "s" }, "<C-L>", function() ls.jump(1) end)
vim.keymap.set({ "i", "s" }, "<C-J>", function() ls.jump(-1) end)


local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		verilog = { "istyle" },
		systemverilog = { "istyle" },
	},
	format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
})
vim.keymap.set("n", "<leader>fo", function() conform.format({ lsp_fallback = true, async = false, timeout_ms = 500 }) end)

require('nvim-ts-autotag').setup({ opts = { enable_close = true, enable_rename = true } })
require('live-server').setup({})
require("html-css").setup({
	opts = {
		enable_on = { "html", "htmldjango", "tsx", "jsx", "svelte", "vue" },
		handlers = { definition = { bind = "gd" }, hover = { bind = "K", border = "single" } },
		style_sheets = { "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" }
	}
})

require("netrw").setup({})

require("nvim-toggler").setup({ inverses = { ["HIGH"] = "LOW", ["-"] = "+", ["0"] = "1" } })
require("aerial").setup({
	on_attach = function(bufnr)
		vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
		vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end
})

vim.keymap.set("n", "<leader>at", "<cmd>AerialToggle!<CR>")

require("lsp_signature").setup({ floating_window = false, hint_enable = true, handler_opts = { border = "rounded" } })
vim.g.fzf_layout = { window = { width = 0.9, height = 0.9, border = "double" } }


-- ==========================================================================
-- JDTLS MASTER CONFIGURATION
-- ==========================================================================
-- vim.filetype.add({ extension = { pde = "java" } })
local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	group = java_cmds,
	callback = function()
		local jdtls = require("jdtls")

		-- A. ROBUST MASON PATHS
		local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
		local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
		local config_dir = jdtls_path .. "/config_linux"

		-- B. ROOT DETECTION
		local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
		local root_dir = jdtls.setup.find_root(root_markers)
		if root_dir == "" then
			root_dir = os.getenv("HOME") .. "/.cache/jdtls-sandbox"
		end

		local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
		local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local extendedClientCapabilities = jdtls.extendedClientCapabilities
		extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

		-- C. LIBRARY LOGIC
		local ref_libraries = {}
		local current_file = vim.fn.expand("%:p")
		local file_extension = vim.fn.expand("%:e") -- Get "pde" or "java"

		-- FIX: Check file extension explicitly!
		-- If it's a .pde file, WE MUST LOAD CORE.JAR, no matter what the folder is named.


		local cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xms1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens", "java.base/java.util=ALL-UNNAMED",
			"--add-opens", "java.base/java.lang=ALL-UNNAMED",
			"-jar", launcher_jar,
			"-configuration", config_dir,
			"-data", workspace_dir,
		}

		local config = {
			cmd = cmd,
			root_dir = root_dir,
			capabilities = capabilities,
			settings = {
				java = {
					signatureHelp = { enabled = true },
					project = { referencedLibraries = ref_libraries },
					configuration = {
						runtimes = {
							{ name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk-amd64/", default = true },
							{ name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk-amd64/" },
						},
					},
				},
			},
			init_options = { extendedClientCapabilities = extendedClientCapabilities },
		}
		jdtls.start_or_attach(config)
	end,
})

-- venn.nvim settings
function _G.Toggle_venn()
	local venn_enabled = vim.inspect(vim.b.venn_enabled)
	if venn_enabled == "nil" then
		vim.b.venn_enabled = true
		vim.cmd [[setlocal ve=all]]
		vim.api.nvim_buf_set_keymap(0, "n", "<A-j>", "<C-v>j:VBox<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(0, "n", "<A-k>", "<C-v>k:VBox<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(0, "n", "<A-l>", "<C-v>l:VBox<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(0, "n", "<A-h>", "<C-v>h:VBox<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
	else
		vim.cmd [[setlocal ve=]]
		vim.api.nvim_buf_del_keymap(0, "n", "<A-j>")
		vim.api.nvim_buf_del_keymap(0, "n", "<A-k>")
		vim.api.nvim_buf_del_keymap(0, "n", "<A-l>")
		vim.api.nvim_buf_del_keymap(0, "n", "<A-h>")
		vim.api.nvim_buf_del_keymap(0, "v", "f")
		vim.b.venn_enabled = nil
	end
end

vim.api.nvim_set_keymap('n', '<leader>vn', ":lua Toggle_venn()<CR>", { noremap = true })

--this colour thing

local ccc = require("ccc")
local mapping = ccc.mapping

ccc.setup({
	-- Your preferred settings
	-- Example: enable highlighter
	highlighter = {
		auto_enable = true,
		lsp = true,
	},
})

-- quicker.nvim

require("quicker").setup({
	-- Local options to set for quickfix
	opts = {
		buflisted = false,
		number = false,
		relativenumber = false,
		signcolumn = "auto",
		winfixheight = true,
		wrap = false,
	},
	-- Set to false to disable the default options in `opts`
	use_default_opts = true,
	-- Keymaps to set for the quickfix buffer
	keys = {
		{ ">", "<cmd>lua require('quicker').expand()<CR>", desc = "Expand quickfix content" },
	},
	-- Callback function to run any custom logic or keymaps for the quickfix buffer
	on_qf = function(bufnr) end,
	edit = {
		-- Enable editing the quickfix like a normal buffer
		enabled = true,
		-- Set to true to write buffers after applying edits.
		-- Set to "unmodified" to only write unmodified buffers.
		autosave = "unmodified",
	},
	-- Keep the cursor to the right of the filename and lnum columns
	constrain_cursor = true,
	highlight = {
		-- Use treesitter highlighting
		treesitter = true,
		-- Use LSP semantic token highlighting
		lsp = true,
		-- Load the referenced buffers to apply more accurate highlights (may be slow)
		load_buffers = false,
	},
	follow = {
		-- When quickfix window is open, scroll to closest item to the cursor
		enabled = false,
	},
	-- Map of quickfix item type to icon
	type_icons = {
		E = "󰅚 ",
		W = "󰀪 ",
		I = " ",
		N = " ",
		H = " ",
	},
	-- Border characters
	borders = {
		vert = "┃",
		-- Strong headers separate results from different files
		strong_header = "━",
		strong_cross = "╋",
		strong_end = "┫",
		-- Soft headers separate results within the same file
		soft_header = "╌",
		soft_cross = "╂",
		soft_end = "┨",
	},
	-- How to trim the leading whitespace from results. Can be 'all', 'common', or false
	trim_leading_whitespace = "common",
	-- Maximum width of the filename column
	max_filename_width = function()
		return math.floor(math.min(95, vim.o.columns / 2))
	end,
	-- How far the header should extend to the right
	header_length = function(type, start_col)
		return vim.o.columns - start_col
	end,
})

-- processing.nvim

-- icons
require 'nvim-web-devicons'.setup {
	-- your personal icons can go here (to override)
	-- you can specify color or cterm_color instead of specifying both of them
	-- DevIcon will be appended to `name`
	override = {
		zsh = {
			icon = "",
			color = "#428850",
			cterm_color = "65",
			name = "Zsh"
		}
	},
	-- globally enable different highlight colors per icon (default to true)
	-- if set to false all icons will have the default icon's color
	color_icons = true,
	-- globally enable default icons (default to false)
	-- will get overriden by `get_icons` option
	default = true,
	-- globally enable "strict" selection of icons - icon will be looked up in
	-- different tables, first by filename, and if not found by extension; this
	-- prevents cases when file doesn't have any extension but still gets some icon
	-- because its name happened to match some extension (default to false)
	strict = true,
	-- set the light or dark variant manually, instead of relying on `background`
	-- (default to nil)
	variant = "light|dark",
	-- override blend value for all highlight groups :h highlight-blend.
	-- setting this value to `0` will make all icons opaque. in practice this means
	-- that icons width will not be affected by pumblend option (see issue #608)
	-- (default to nil)
	blend = 0,
	-- same as `override` but specifically for overrides by filename
	-- takes effect when `strict` is true
	override_by_filename = {
		[".gitignore"] = {
			icon = "",
			color = "#f1502f",
			name = "Gitignore"
		}
	},
	-- same as `override` but specifically for overrides by extension
	-- takes effect when `strict` is true
	override_by_extension = {
		["log"] = {
			icon = "",
			color = "#81e043",
			name = "Log"
		}
	},
	-- same as `override` but specifically for operating system
	-- takes effect when `strict` is true
	override_by_operating_system = {
		["apple"] = {
			icon = "",
			color = "#A2AAAD",
			cterm_color = "248",
			name = "Apple",
		},
	},
}
