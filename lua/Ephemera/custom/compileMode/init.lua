-- =============================================================================
-- compileMode -- Fork of pohlrabi404/compile.nvim
-- Original: https://github.com/pohlrabi404/compile.nvim
-- License: MIT
-- Modified by: Ephemera (Rithik)

-- TODO:
--  - Linkers / build-system errors often output NO file path (ex: "undefined
--    reference"). Add a fallback: hop to first warning / current file when a
--    compiled line has no parseable path.
--  - F6 prompt is ALWAYS empty on purpose; cancelling/emptying it must NEVER
--    touch last_cmd (so F5 keeps recompiling the previous command).
--  - This mode doubles as a file/line "grep runner": rg/ack/grep output
--    (file:line:col) already parses via the existing patterns.
-- =============================================================================
local compile = {}

-- Last command used, persisted across sessions via shada (vim.g)
compile.state = {
	last_cmd = vim.g.compileMode_last_cmd,
}

-- Load submodules
compile.term = require("Ephemera.custom.compileMode.term")
compile.utils = require("Ephemera.custom.compileMode.utils")
compile.highlight = require("Ephemera.custom.compileMode.highlight")
compile.keymaps = require("Ephemera.custom.compileMode.keymaps")
compile.opts = require("Ephemera.custom.compileMode.opts")

--- Clears the terminal and reinitializes it.
--- This function effectively resets the compiler environment, removing any previous output and preparing it for a new compilation run.
function compile.clear()
	compile.utils.enter_wrapper(function()
		compile.term.destroy()
		compile.term.init()
	end)
end

--- Clears all highlight markers and the internal warning list.
function compile.clear_hl()
	compile.highlight.clear_hl_warning()
	local cursor_pos = vim.api.nvim_win_get_cursor(compile.term.state.win)
	compile.term.state.last_line = cursor_pos[1]
	vim.api.nvim_chan_send(compile.term.state.channel, "\n")
end

local function get_current_file_dir()
	local buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(buf)
	if buf_name and buf_name ~= "" then
		local dir = vim.fn.fnamemodify(buf_name, ":p:h")
		if vim.fn.isdirectory(dir) == 1 then
			return dir
		end
	end
	return vim.fn.getcwd()
end

_G.Ephemera_compile_complete = function(ArgLead, CmdLine, CursorPos)
	local prefix, word = ArgLead:match("^(.*%s)(%S*)$")
	if not prefix then
		local cmds = vim.fn.getcompletion(ArgLead, "shellcmd")
		if #cmds > 0 then
			return cmds
		end
		return vim.fn.getcompletion(ArgLead, "file")
	else
		local matches = vim.fn.getcompletion(word, "file")
		local results = {}
		for _, m in ipairs(matches) do
			table.insert(results, prefix .. m)
		end
		return results
	end
end

_G.Ephemera_compile_complete_file_dir = function(ArgLead, CmdLine, CursorPos)
	local prefix, word = ArgLead:match("^(.*%s)(%S*)$")
	if not prefix then
		local cmds = vim.fn.getcompletion(ArgLead, "shellcmd")
		if #cmds > 0 then
			return cmds
		end
		local file_dir = get_current_file_dir()
		local original_cwd = vim.fn.getcwd()
		local matches = {}
		if file_dir and file_dir ~= original_cwd and vim.fn.isdirectory(file_dir) == 1 then
			vim.fn.chdir(file_dir)
			matches = vim.fn.getcompletion(ArgLead, "file")
			vim.fn.chdir(original_cwd)
		else
			matches = vim.fn.getcompletion(ArgLead, "file")
		end
		return matches
	else
		local file_dir = get_current_file_dir()
		local original_cwd = vim.fn.getcwd()
		local matches = {}
		if file_dir and file_dir ~= original_cwd and vim.fn.isdirectory(file_dir) == 1 then
			vim.fn.chdir(file_dir)
			matches = vim.fn.getcompletion(word, "file")
			vim.fn.chdir(original_cwd)
		else
			matches = vim.fn.getcompletion(word, "file")
		end
		local results = {}
		for _, m in ipairs(matches) do
			table.insert(results, prefix .. m)
		end
		return results
	end
end

local function format_truncated_path(dir)
	local path = vim.fn.fnamemodify(dir, ":~")
	local parts = vim.split(path, "/", { trimempty = true })
	if #parts == 0 then
		return "."
	end
	if #parts == 1 then
		return parts[1]
	end
	if #parts == 2 then
		return parts[1] .. "/" .. parts[2]
	end

	local last = parts[#parts]
	local parent = parts[#parts - 1]
	return ".../" .. parent .. "/" .. last
end

local function detect_project_command(dir)
	dir = dir or vim.fn.getcwd()
	local checks = {
		{ file = "Cargo.toml", cmd = "cargo check" },
		{ file = "Makefile", cmd = "make" },
		{ file = "makefile", cmd = "make" },
		{ file = "CMakeLists.txt", cmd = "cmake --build build" },
		{ file = "package.json", cmd = "npm test" },
		{ file = "go.mod", cmd = "go build ." },
		{ file = "build.zig", cmd = "zig build" },
		{ file = "pyproject.toml", cmd = "python3 -m pytest" },
		{ file = "compile_commands.json", cmd = "ninja" },
	}
	for _, check in ipairs(checks) do
		if vim.fn.filereadable(dir .. "/" .. check.file) == 1 then
			return check.cmd
		end
	end
	return nil
end

--- Prompt for a compile command (always starts empty), then run it in project root (cwd).
--- Autocompletes commands for the first word and files/dirs for arguments upon pressing <Tab>.
--- Empty input / cancel does nothing and never touches last_cmd.
function compile.compile_prompt()
	local dir_display = format_truncated_path(vim.fn.getcwd())
	local default_hint = detect_project_command(vim.fn.getcwd()) or ""
	local prompt_text = string.format("[%s] Run: ", dir_display)
	local cmd = vim.fn.input({
		prompt = prompt_text,
		completion = "customlist,v:lua.Ephemera_compile_complete",
	})
	if cmd and cmd:len() > 0 then
		compile.compile(cmd)
	elseif cmd and cmd == "" and default_hint ~= "" then
		compile.compile(default_hint)
	end
end

--- Prompt for a compile command and run it in the directory of the currently open file (Shift-F6).
function compile.compile_prompt_file_dir()
	local file_dir = get_current_file_dir()
	local dir_display = format_truncated_path(file_dir)
	local default_hint = detect_project_command(file_dir) or ""
	local cmd = vim.fn.input({
		prompt = string.format("[%s] Run: ", dir_display),
		completion = "customlist,v:lua.Ephemera_compile_complete_file_dir",
	})
	if cmd and cmd:len() > 0 then
		compile.compile(cmd, file_dir)
	elseif cmd and cmd == "" and default_hint ~= "" then
		compile.compile(default_hint, file_dir)
	end
end

--- Re-run the last compile command in project root (cwd); if none exists yet, prompt instead.
function compile.recompile()
	if compile.state.last_cmd then
		compile.compile(compile.state.last_cmd)
	else
		local detected = detect_project_command(vim.fn.getcwd())
		if detected then
			compile.compile(detected)
		else
			compile.compile_prompt()
		end
	end
end

--- Re-run the last compile command in current file directory (Shift-F5); if none exists yet, prompt instead.
function compile.recompile_file_dir()
	local file_dir = get_current_file_dir()
	if compile.state.last_cmd then
		compile.compile(compile.state.last_cmd, file_dir)
	else
		local detected = detect_project_command(file_dir)
		if detected then
			compile.compile(detected, file_dir)
		else
			compile.compile_prompt_file_dir()
		end
	end
end

local function prompt_save_modified_buffers()
	local modified_bufs = vim.tbl_filter(function(b)
		return vim.api.nvim_buf_is_valid(b)
			and vim.api.nvim_get_option_value("modified", { buf = b })
			and vim.api.nvim_get_option_value("buftype", { buf = b }) == ""
			and vim.api.nvim_buf_get_name(b) ~= ""
	end, vim.api.nvim_list_bufs())

	if #modified_bufs > 0 then
		local choice = vim.fn.confirm(
			string.format("Save %d modified buffer(s) before compiling?", #modified_bufs),
			"&Yes\n&No",
			1
		)
		if choice == 1 then
			vim.cmd("silent! wall")
		end
	end
end

--- Prompt for a compile command and directly launch it in watch mode (Alt-F6).
function compile.compile_watch_prompt()
	local dir_display = format_truncated_path(vim.fn.getcwd())
	local default_hint = detect_project_command(vim.fn.getcwd()) or (compile.state.last_cmd or "")
	local prompt_text = string.format("[%s] (Watch) Run: ", dir_display)
	local cmd = vim.fn.input({
		prompt = prompt_text,
		completion = "customlist,v:lua.Ephemera_compile_complete",
	})
	if not cmd or cmd:len() == 0 then
		if default_hint ~= "" then
			cmd = default_hint
		else
			return
		end
	end

	compile.enable_watch()
	compile.compile(cmd)
end

--- Enables watch mode (auto-compile on buffer save).
function compile.enable_watch()
	compile.state.watch_enabled = true
	local group = vim.api.nvim_create_augroup("CompileModeWatch", { clear = true })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = group,
		callback = function()
			if compile.state.last_cmd then
				compile.compile(compile.state.last_cmd)
			end
		end,
	})
end

--- Disables watch mode.
function compile.disable_watch()
	compile.state.watch_enabled = false
	pcall(vim.api.nvim_del_augroup_by_name, "CompileModeWatch")
end

--- Toggle watch mode: automatically re-runs last compile command whenever a file is saved.
function compile.toggle_watch()
	if compile.state.watch_enabled then
		compile.disable_watch()
		vim.notify("CompileMode: Watch mode DISABLED", vim.log.levels.INFO)
	else
		compile.enable_watch()
		vim.notify("CompileMode: Watch mode ENABLED (auto-compile on save)", vim.log.levels.INFO)
		if compile.state.last_cmd then
			compile.compile(compile.state.last_cmd)
		end
	end
end

--- Exports all parsed compilation errors into Neovim's native Quickfix list.
function compile.export_to_qf()
	if not compile.highlight.has_warnings() then
		vim.notify("CompileMode: No errors/warnings to export to Quickfix list", vim.log.levels.WARN)
		return
	end

	local qf_list = {}
	for _, key in ipairs(compile.highlight.state.warning_index) do
		local err = compile.highlight.state.warning_list[key]
		if err then
			table.insert(qf_list, {
				filename = err.file.val,
				lnum = err.row.val or 1,
				col = err.col.val or 0,
				text = "Compiler error/warning",
				type = "E",
			})
		end
	end

	vim.fn.setqflist(qf_list, "r")
	vim.fn.setqflist({}, "a", { title = "Compile: " .. (compile.state.last_cmd or "Build") })
	vim.cmd("copen")
	vim.notify(string.format("CompileMode: Exported %d error(s) to Quickfix list", #qf_list), vim.log.levels.INFO)
end

--- Compiles the project and captures errors in the terminal.
--- Prompts to save modified buffers (if any), tracks build duration, and prints watch mode banner if active.
---@param cmd string The command to execute.
---@param cwd string|nil The working directory to execute the command in.
function compile.compile(cmd, cwd)
	-- Prompt to save modified buffers (if any exist)
	prompt_save_modified_buffers()

	compile.state.last_cmd = cmd
	compile.state.start_time = vim.loop.hrtime()
	vim.g.compileMode_last_cmd = cmd
	compile.utils.enter_wrapper(function()
		compile.term.destroy()
		if compile.highlight.has_warnings() then
			compile.highlight.clear_hl_warning()
		end
		compile.term.show()

		compile.term.attach_event()
		local terminator = compile.term.get_terminator()
		if cwd and cwd ~= "" then
			vim.api.nvim_chan_send(compile.term.state.channel, "cd " .. vim.fn.fnameescape(cwd) .. terminator)
		end
		-- wipe shell startup output (fastfetch, prompt) before running
		vim.api.nvim_chan_send(compile.term.state.channel, "clear" .. terminator)
		if compile.state.watch_enabled then
			vim.api.nvim_chan_send(
				compile.term.state.channel,
				"echo -e '\\033[1;36m[CompileMode: Terminal is in WATCH MODE (auto-recompiling on save)]\\033[0m'"
					.. terminator
			)
		end
		compile.term.send_cmd(cmd)
	end)
end

--- Destroys the terminal buffer and window.
function compile.destroy()
	compile.utils.enter_wrapper(function()
		compile.term.destroy()
		compile.highlight.clear_hl_warning()
	end)
end

--- Navigates to the current error location in the code.
--- Updates the editor buffer (centered with zz) and keeps cursor in terminal window if open.
function compile.goto_error()
	local c_error = compile.highlight.get_current_warning()
	if not c_error then
		return
	end

	local win = compile.utils.get_normal_win()
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end

	-- Update the normal window to view the file at target row/col and center with zz
	vim.api.nvim_win_call(win, function()
		if c_error.file and c_error.file.val and c_error.file.val ~= "" then
			local target_file = c_error.file.val
			local current_buf = vim.api.nvim_win_get_buf(win)
			local current_file = vim.api.nvim_buf_get_name(current_buf)

			if not (current_file == target_file or (current_file:sub(-#target_file) == target_file and #target_file > 0)) then
				local target_buf = vim.fn.bufadd(target_file)
				vim.fn.bufload(target_buf)
				vim.api.nvim_win_set_buf(win, target_buf)
			end
		end

		local buf = vim.api.nvim_win_get_buf(win)
		local line_count = vim.api.nvim_buf_line_count(buf)
		local target_row = math.min(math.max(1, (c_error.row and c_error.row.val) or 1), math.max(1, line_count))
		local lines = vim.api.nvim_buf_get_lines(buf, target_row - 1, target_row, false)
		local line_len = (lines[1] and #lines[1]) or 0
		local raw_col = (c_error.col and c_error.col.val and c_error.col.val > 0) and (c_error.col.val - 1) or 0
		local target_col = math.min(math.max(0, raw_col), math.max(0, line_len))

		pcall(vim.api.nvim_win_set_cursor, win, { target_row, target_col })
		vim.cmd("normal! zz")
	end)

	-- Update terminal cursor to the error line and keep focus in terminal window
	local term_win = compile.term.state.win
	local term_buf = compile.term.state.buf
	if vim.api.nvim_win_is_valid(term_win) and vim.api.nvim_buf_is_valid(term_buf) and c_error.file and c_error.file.pos then
		local t_line_count = vim.api.nvim_buf_line_count(term_buf)
		local t_row = math.min(math.max(1, c_error.file.pos[1][1] + 1), math.max(1, t_line_count))
		local t_col = math.max(0, c_error.file.pos[1][2] or 0)
		pcall(vim.api.nvim_win_set_cursor, term_win, { t_row, t_col })
		vim.api.nvim_set_current_win(term_win)
	end

	if compile.opts.highlight_under_cursor.enabled then
		pcall(function()
			vim.hl.range(
				compile.term.state.buf,
				compile.highlight.ns,
				"Cursor",
				c_error.file.pos[1],
				c_error.file.pos[2],
				{ priority = 2000, timeout = compile.opts.highlight_under_cursor.timeout_term }
			)

			vim.hl.range(
				vim.api.nvim_win_get_buf(win),
				compile.highlight.ns,
				"Cursor",
				{ c_error.row.val - 1, 0 },
				{ c_error.row.val - 1, -1 },
				{ priority = 2000, timeout = compile.opts.highlight_under_cursor.timeout_normal }
			)
		end)
	end
end

--- Previews the error on or nearest to the cursor position in the editing buffer (centered with zz),
--- keeping cursor and focus inside the compilation window (just like n, p, f, l).
function compile.preview_nearest_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local warning_row_list = {}
	for _, file in ipairs(compile.highlight.state.warning_index) do
		local warning_list = compile.highlight.state.warning_list
		local row = warning_list[file].file.pos[1][1]
		table.insert(warning_row_list, row)
	end

	local warning_index = compile.utils.binary_search(warning_row_list, cursor_pos[1] - 1)
	compile.highlight.state.current_warning = warning_index
	compile.goto_error()
end

--- Navigates to the error nearest to the cursor's current position,
--- jumps into the file buffer, and hides the compilation split.
function compile.nearest_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	--- find the nearest error
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local warning_row_list = {}
	for _, file in ipairs(compile.highlight.state.warning_index) do
		local warning_list = compile.highlight.state.warning_list
		local row = warning_list[file].file.pos[1][1]
		table.insert(warning_row_list, row)
	end

	local warning_index = compile.utils.binary_search(warning_row_list, cursor_pos[1] - 1)
	compile.highlight.state.current_warning = warning_index
	compile.goto_error()

	-- Jumping on <Cr> hides the compilation split and focuses the editor window
	local win = compile.utils.get_normal_win()
	compile.term.hide()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
	end
end

--- Navigates to the next error in the list.
function compile.next_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	compile.highlight.next_warning()
	compile.goto_error()
end

--- Navigates to the previous error in the list.
function compile.prev_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	compile.highlight.prev_warning()
	compile.goto_error()
end

--- Navigates to the last error in the list.
function compile.last_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	compile.highlight.last_warning()
	compile.goto_error()
end

--- Navigates to the first error in the list.
function compile.first_error()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.term.show()
	compile.highlight.first_warning()
	compile.goto_error()
end

--- Sets up the plugin with user configuration.
---
--- This is the main entry point for configuring the plugin. It merges user-provided options with the defaults, performs necessary calculations for window sizes, and initializes the submodules.
---
---@param opts table|nil A table of user options to override the defaults.
function compile.setup(opts)
	opts = opts or {}
	compile.opts = vim.tbl_deep_extend("force", compile.opts, opts)

	---Make sure to respect float configuration
	if compile.opts.term_win_opts.relative ~= nil then
		compile.opts.term_win_opts.split = nil
	end

	-- Convert relative heights to absolute
	if compile.opts.term_win_opts.height <= 1 then
		compile.opts.term_win_opts.height = math.floor(vim.o.lines * compile.opts.term_win_opts.height)
	end
	if compile.opts.normal_win_opts.height <= 1 then
		compile.opts.normal_win_opts.height = math.floor(vim.o.lines * compile.opts.normal_win_opts.height)
	end
	if compile.opts.term_win_opts.width <= 1 then
		compile.opts.term_win_opts.width = math.floor(vim.o.columns * compile.opts.term_win_opts.width)
	end
	if compile.opts.normal_win_opts.width <= 1 then
		compile.opts.normal_win_opts.width = math.floor(vim.o.columns * compile.opts.normal_win_opts.width)
	end

	-- Initialize submodules
	compile.term.setup(compile.opts)
	compile.highlight.setup(compile.opts)
	compile.keymaps.setup(compile.opts)
end

return compile
