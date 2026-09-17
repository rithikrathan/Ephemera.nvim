-- =============================================================================
-- runMode -- Fork of pohlrabi404/compile.nvim
-- Original: https://github.com/pohlrabi404/compile.nvim
-- License: MIT
-- Modified by: Ephemera (Rithik)
-- =============================================================================
--- Default configuration options for the plugin. Users can override these with `compile.setup()`.
---
---@class compile.opts
---
---@field term_win_name string The name of the terminal window.
---@field term_win_opts vim.api.keyset.win_config Options of the terminal window
---@field normal_win_opts vim.api.keyset.win_config Options of the normal window (if there is not one already)
---@field enter boolean If true, automatically enter the terminal window after compiling.
---@field highlight_under_cursor table Options for highlighting the error under the cursor in both terminal and normal windows.
---@field patterns table A table of regular expression patterns used to parse compiler errors.
---@field colors table A table of highlight groups to use for coloring different parts of an error message.
---@field keys table A table of keymaps for global and terminal-specific actions.
return {
	term_win_name = "CompileTerm",
	term_win_opts = {
		split = "above",
		height = 0.3,
		width = 1,
	},

	normal_win_opts = {
		split = "below",
		height = 0.7,
		width = 1,
	},

	enter = false,

	hidden = true,

	highlight_under_cursor = {
		enabled = true,
		timeout_term = 70,
		timeout_normal = 70,
	},

	patterns = {
		rg = { "(%S+):(%d+):(%d+):", "123" },
		grep = { "(%S+):(%d+):", "12" },
		ctags_x = { "^%S+%s+[%w_]+%s+(%d+)%s+(%S+)", "21" },
		ctags_tags = { "^%S+%s+(%S+)%s+(%d+);\"", "12" },
		gcc = { "(%S+):(%d+):(%d+)", "123" },
		rust = { "%-%-> (%S+):(%d+):(%d+)", "123" },
		csharp = { "(%S+%.%a+)%((%d+),(%d+)%)", "123" },
		Makefile = { "%[(%S+):(%d+):.+%]", "12" },
		python = { 'File "(%S+%.%a+)", line (%d+)', "12" },
		shellcheck = { "In (%S+) line (%d+):", "12" },
		gdb = { "at (%S+%.%a+):(%d+)", "12" },
		valgrind = { "at 0x%x+: %S+ %((%S+):(%d+)%)", "12" },
		pytest = { "(%S+%.py):(%d+): in ", "12" },
	},

	colors = {
		file = "WarningMsg",
		row = "CursorLineNr",
		col = "CursorLineNr",
	},

	keys = {
		global = {
			["n"] = {
				["<localleader>c"] = "require('Ephemera.custom.runMode').term.toggle()",
				["<localleader>cw"] = "require('Ephemera.custom.runMode').toggle_watch()",
				["<localleader>cx"] = "require('Ephemera.custom.runMode').destroy()",
				["<F5>"] = "require('Ephemera.custom.runMode').recompile()",
				["<F6>"] = "require('Ephemera.custom.runMode').compile_prompt()",
				["<S-F5>"] = "require('Ephemera.custom.runMode').recompile_file_dir()",
				["<F17>"] = "require('Ephemera.custom.runMode').recompile_file_dir()",
				["<S-F6>"] = "require('Ephemera.custom.runMode').compile_prompt_file_dir()",
				["<F18>"] = "require('Ephemera.custom.runMode').compile_prompt_file_dir()",
				["<A-F6>"] = "require('Ephemera.custom.runMode').compile_watch_prompt()",
				["<M-F6>"] = "require('Ephemera.custom.runMode').compile_watch_prompt()",
			},
		},
		term = {
			global = {
				["n"] = {
					["<localleader>cr"] = "require('Ephemera.custom.runMode').clear()",
					["<localleader>cq"] = "require('Ephemera.custom.runMode').destroy()",
				},
			},
			buffer = {
				["n"] = {
					["r"] = "require('Ephemera.custom.runMode').clear()",
					["q"] = "require('Ephemera.custom.runMode').destroy()",
					["w"] = "require('Ephemera.custom.runMode').toggle_watch()",
					["s"] = "require('Ephemera.custom.runMode').term.cycle_split()",
					["Q"] = "require('Ephemera.custom.runMode').export_to_qf()",
					["n"] = "require('Ephemera.custom.runMode').next_error()",
					["p"] = "require('Ephemera.custom.runMode').prev_error()",
					["f"] = "require('Ephemera.custom.runMode').first_error()",
					["l"] = "require('Ephemera.custom.runMode').last_error()",
					["v"] = "require('Ephemera.custom.runMode').preview_nearest_error()",
					["<Cr>"] = "require('Ephemera.custom.runMode').nearest_error()",
				},
				["t"] = {
					["<CR>"] = "require('Ephemera.custom.runMode').clear_hl()",
					["<C-j>"] = "require('Ephemera.custom.runMode.term').send_cmd('')",
				},
			},
		},
	},
}
