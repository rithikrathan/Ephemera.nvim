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
	wrap_col = vim.o.columns, -- PTY width, used to detect hard-wrapped rows
	pending = nil, -- partial logical line carried across on_lines callbacks
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
-- single-line regex pattern matching. Mitigated below: logicalize() re-joins full-width
-- physical rows before patttern matching, and map_logical_pos() restores physical coords.

--- Refresh the PTY wrap width from the visible terminal window.
function compile.term.update_wrap_col()
	if vim.api.nvim_win_is_valid(compile.term.state.win) then
		compile.term.state.wrap_col = vim.api.nvim_win_get_width(compile.term.state.win)
	else
		compile.term.state.wrap_col = vim.o.columns
	end
end

--- Re-join any PTY hard-wrapped physical rows into logical lines.
--- A physical row whose length == wrap_col is a full-width segment: the next
--- physical row continues the same logical line. A pending logical line from a
--- previous callback is carried over across chunk boundaries.
---@param first_line number first physical row of the chunk (same numbering nvim_get_lines uses)
---@param lines string[] the chunk of new physical rows
---@return table[] logical entries: { text, start_row, nseg, wrap }
function compile.term.logicalize(first_line, lines)
	compile.term.update_wrap_col()
	local wrap = compile.term.state.wrap_col or vim.o.columns
	if wrap < 1 then
		wrap = vim.o.columns
	end

	local out = {}
	local pending = compile.term.state.pending
	for i, line in ipairs(lines) do
		local n = #line
		if pending then
			pending.text = pending.text .. line
			pending.nseg = pending.nseg + 1
		else
			pending = { text = line, start_row = first_line + i - 1, nseg = 1, wrap = wrap }
		end

		if n ~= wrap then
			out[#out + 1] = pending
			pending = nil
		end
	end
	compile.term.state.pending = pending
	return out
end

--- Reconstruct the logical (wrap-joined) line containing physical row `row1`,
--- plus the logical offset of a cursor at (row1, col0). Used so open_link /
--- enter_action still see URLs that were hard-wrapped across two rows.
---@param row1 number 1-based physical row
---@param col0 number 0-based column inside that row
---@return table|nil { text, start_row, seg_rows, seg_sizes, cursor_off }
function compile.term.get_logical_at(row1, col0)
	local buf = compile.term.state.buf
	if not vim.api.nvim_buf_is_valid(buf) or row1 < 1 or row1 > vim.api.nvim_buf_line_count(buf) then
		return nil
	end
	compile.term.update_wrap_col()
	local wrap = compile.term.state.wrap_col or vim.o.columns

	local start_row = row1
	while start_row > 1 do
		local prev = vim.api.nvim_buf_get_lines(buf, start_row - 2, start_row - 1, false)[1] or ""
		if #prev == wrap then
			start_row = start_row - 1
		else
			break
		end
	end

	local text_parts, seg_rows, seg_sizes = {}, {}, {}
	local r, nlines = start_row, vim.api.nvim_buf_line_count(buf)
	while r <= nlines do
		local line = vim.api.nvim_buf_get_lines(buf, r - 1, r, false)[1] or ""
		text_parts[#text_parts + 1] = line
		seg_rows[#seg_rows + 1] = r
		seg_sizes[#seg_sizes + 1] = #line
		if #line ~= wrap then
			break
		end
		r = r + 1
	end

	local cursor_off = col0 or 0
	for i = 1, #seg_rows do
		if seg_rows[i] == row1 then
			return {
				text = table.concat(text_parts),
				start_row = start_row,
				seg_rows = seg_rows,
				seg_sizes = seg_sizes,
				cursor_off = cursor_off,
			}
		end
		cursor_off = cursor_off + seg_sizes[i]
	end
	return nil
end

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
	compile.term.update_wrap_col()
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
		compile.term.update_wrap_col()
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
		compile.term.state.pending = nil
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
	pcall(vim.cmd, target.cmd)
	if target.resize then
		pcall(target.resize, win)
	end

	-- Explicitly keep text wrapping OFF
	vim.api.nvim_set_option_value("wrap", false, { scope = "local", win = win })
	compile.term.update_wrap_col()

	if compile.opts and compile.opts.term_win_opts then
		compile.opts.term_win_opts.split = target.split_opt
	end
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
			local physical = vim.api.nvim_buf_get_lines(compile.term.state.buf, first_line, last_line, false)
			local logical = compile.term.logicalize(first_line, physical)
			if #logical > 0 then
				require("Ephemera.custom.runMode").process_lines(logical)
			end
		end,
	})
end

return compile.term
