-- =============================================================================
-- runMode -- Fork of pohlrabi404/compile.nvim
-- Original: https://github.com/pohlrabi404/compile.nvim
-- License: MIT
-- Modified by: Ephemera (Rithik)
-- =============================================================================
local compile = {}
compile.term = {}

compile.opts = require("Ephemera.custom.runMode.opts")

compile.term.state = {
	buf = -1,
	win = -1,
	channel = -1,
	last_line = 1,
	warning_list = {},
	warning_index = {},
	current_warning = 0,
	split_idx = 2, -- defaults to 2 (top) on startup
}

local opts = {}

local split_cycle = {
	{ name = "right", cmd = "wincmd L", resize = function(w) vim.api.nvim_win_set_width(w, (opts.term_win_opts and opts.term_win_opts.width) or math.floor(vim.o.columns * 0.45)) end, split_opt = "right" },
	{ name = "top", cmd = "wincmd K", resize = function(w) vim.api.nvim_win_set_height(w, (opts.term_win_opts and opts.term_win_opts.height) or math.floor(vim.o.lines * 0.3)) end, split_opt = "above" },
	{ name = "left", cmd = "wincmd H", resize = function(w) vim.api.nvim_win_set_width(w, (opts.term_win_opts and opts.term_win_opts.width) or math.floor(vim.o.columns * 0.45)) end, split_opt = "left" },
	{ name = "bottom", cmd = "wincmd J", resize = function(w) vim.api.nvim_win_set_height(w, (opts.term_win_opts and opts.term_win_opts.height) or math.floor(vim.o.lines * 0.3)) end, split_opt = "below" },
}

--- Initialize terminal module
function compile.term.setup(o)
	opts = o or {}
	if opts.term_win_opts and opts.term_win_opts.split then
		local s = tostring(opts.term_win_opts.split):lower()
		for i, v in ipairs(split_cycle) do
			if v.split_opt == s or v.name == s or (s == "above" and v.split_opt == "above") or (s == "top" and v.split_opt == "above") or (s == "below" and v.split_opt == "below") or (s == "bottom" and v.split_opt == "below") then
				compile.term.state.split_idx = i
				break
			end
		end
	end
end

-- BUG/TODO: Left and right vertical orientations cause the underlying terminal PTY
-- to hard-wrap lines (inserting physical newline chars \r\n into the stream) when window
-- width is narrow. This splits error messages across multiple buffer lines and can break
-- single-line regex pattern matching. Bottom/top horizontal splits are recommended.

--- Returns win_opts conforming to the current session's cycled split orientation
function compile.term.get_win_opts()
	local idx = compile.term.state.split_idx or 2
	local target = split_cycle[idx] or split_cycle[2]
	local h = (opts.term_win_opts and opts.term_win_opts.height) or math.floor(vim.o.lines * 0.3)
	local w = (opts.term_win_opts and opts.term_win_opts.width) or math.floor(vim.o.columns * 0.45)
	if target.split_opt == "right" or target.split_opt == "left" then
		return {
			split = target.split_opt,
			width = w,
		}
	else
		return {
			split = target.split_opt,
			height = h,
		}
	end
end

--- Initialize terminal buffer and window
function compile.term.init()
	compile.term.state.buf = vim.api.nvim_create_buf(false, true)
	local win_opts = compile.term.get_win_opts()
	compile.term.state.win = vim.api.nvim_open_win(compile.term.state.buf, true, win_opts)
	vim.cmd("term")
	if compile.opts.hidden then
		vim.api.nvim_set_option_value("buflisted", false, { scope = "local", buf = compile.term.state.buf })
	end
	compile.term.state.channel = vim.api.nvim_get_option_value("channel", { buf = compile.term.state.buf })
	vim.api.nvim_buf_set_name(compile.term.state.buf, opts.term_win_name)

	-- keep error lines unwrapped so the regex parser sees them intact
	vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = compile.term.state.win })
	-- set filetype so the statusline shows the custom "Run" icon
	vim.api.nvim_set_option_value("filetype", "run", { buf = compile.term.state.buf })
end

--- Show terminal window
function compile.term.show()
	if vim.api.nvim_win_is_valid(compile.term.state.win) then
		return
	end

	if vim.api.nvim_buf_is_valid(compile.term.state.buf) then
		local win_opts = compile.term.get_win_opts()
		compile.term.state.win = vim.api.nvim_open_win(compile.term.state.buf, true, win_opts)
		vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = compile.term.state.win })
	else
		compile.term.init()
	end
end

--- Hide terminal window
function compile.term.hide()
	if vim.api.nvim_win_is_valid(compile.term.state.win) then
		vim.api.nvim_win_hide(compile.term.state.win)
		compile.term.state.win = -1
	end
end

--- Jump to terminal window
function compile.term.jump_to()
	compile.term.show()
	vim.api.nvim_set_current_win(compile.term.state.win)
end

--- Destroy terminal resources
function compile.term.destroy()
	compile.term.hide()
	if vim.api.nvim_buf_is_valid(compile.term.state.buf) then
		vim.api.nvim_buf_delete(compile.term.state.buf, { force = true })
		compile.term.state.win = -1
		compile.term.state.buf = -1
		compile.term.state.channel = -1
		compile.term.state.last_line = 0
	end
end

--- Toggle terminal visibility (show and focus, or hide and focus normal editor window)
function compile.term.toggle()
	if vim.api.nvim_win_is_valid(compile.term.state.win) then
		local normal_win = require("Ephemera.custom.runMode.utils").get_normal_win()
		compile.term.hide()
		if normal_win and vim.api.nvim_win_is_valid(normal_win) then
			vim.api.nvim_set_current_win(normal_win)
		end
	else
		compile.term.show()
		if vim.api.nvim_win_is_valid(compile.term.state.win) then
			vim.api.nvim_set_current_win(compile.term.state.win)
		end
	end
end

--- Cycles compilation split window alignment (bottom -> right -> top -> left)
--- Keeps text wrapping explicitly OFF for accurate regex parsing.
function compile.term.cycle_split()
	local win = compile.term.state.win
	if not vim.api.nvim_win_is_valid(win) then
		return
	end

	compile.term.state.split_idx = ((compile.term.state.split_idx or 4) % #split_cycle) + 1
	local target = split_cycle[compile.term.state.split_idx]

	vim.api.nvim_set_current_win(win)
	vim.cmd(target.cmd)
	if target.resize then
		target.resize(win)
	end

	-- Explicitly keep text wrapping OFF
	vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = win })

	if compile.opts and compile.opts.term_win_opts then
		compile.opts.term_win_opts.split = target.split_opt
	end

	vim.notify("Run: Split aligned to " .. target.name, vim.log.levels.INFO)
end

local function is_windows_os()
	local sys = vim.loop.os_uname()
	if sys.sysname == "Window_NT" then
		return true
	else -- Linux/Macs/BSD should all have \n as terminator
		return false
	end
end

--- Get terminator based on OS
function compile.term.get_terminator()
	if is_windows_os() then
		return " \r"
	else
		return "\n"
	end
end

--- Send command to terminal
---
---@param cmd string? Command to execute
function compile.term.send_cmd(cmd)
	compile.term.show()
	local line_count = vim.api.nvim_buf_line_count(compile.term.state.buf)
	vim.api.nvim_win_set_cursor(compile.term.state.win, { line_count, 0 })
	if cmd ~= "" then
		local terminator = compile.term.get_terminator()
		vim.api.nvim_chan_send(compile.term.state.channel, cmd .. terminator)
	end
end

--- Attach warning parsing to terminal buffer
function compile.term.attach_event()
	vim.api.nvim_buf_attach(compile.term.state.buf, false, {
		on_lines = function(_, _, _, first_line, _, last_line)
			if last_line <= compile.term.state.last_line then
				return
			end
			if first_line < compile.term.state.last_line then
				first_line = compile.term.state.last_line
			end
			local lines = vim.api.nvim_buf_get_lines(compile.term.state.buf, first_line, last_line, false)
			require("Ephemera.custom.runMode").process_lines(lines, first_line)
		end,
	})
end

return compile.term
