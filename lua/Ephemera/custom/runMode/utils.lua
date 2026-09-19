-- =============================================================================
-- runMode -- Fork of pohlrabi404/compile.nvim
-- Original: https://github.com/pohlrabi404/compile.nvim
-- License: MIT
-- Modified by: Ephemera (Rithik)
-- =============================================================================
local compile = {}
compile.utils = {}

--- Execute function with optional focus preservation
function compile.utils.enter_wrapper(func)
	local current_win = vim.api.nvim_get_current_win()
	func()
	if (not require("Ephemera.custom.runMode").opts.enter) and vim.api.nvim_win_is_valid(current_win) then
		vim.api.nvim_set_current_win(current_win)
	end
end

--- Split string into character array
function compile.utils.split_to_char(str)
	local char_table = {}
	for char in string.gmatch(str, ".") do
		table.insert(char_table, char)
	end
	return char_table
end

--- Split string into numeric array
function compile.utils.split_to_num(str)
	local num_table = {}
	for char in string.gmatch(str, ".") do
		table.insert(num_table, tonumber(char))
	end
	return num_table
end

local FOOTER_MARK = "── Finished "

--- True when a terminal line is the plugin's own footer line. The footer is
--- plugin UI, so its content must never be claimed by compiler error/warning
--- patterns (e.g. the HH:MM:SS finish time matches grep-style "(%S+):(%d+):"
--- patterns and would highlight as a fake error).
function compile.utils.is_runmode_footer(line)
	return type(line) == "string" and line:sub(1, #FOOTER_MARK) == FOOTER_MARK
end

--- Get valid non-terminal window
function compile.utils.get_normal_win()
	local term_win = require("Ephemera.custom.runMode.term").state.win
	local current_warning = require("Ephemera.custom.runMode.highlight").get_current_warning()
	local warning_filename = (current_warning and current_warning.file and current_warning.file.val) or ""

	local function endsWith(str, suffix)
		if suffix == "" then
			return false
		end
		return str:sub(-#suffix) == suffix
	end

	-- 1. Check if an existing window already displays the warning file
	if warning_filename ~= "" then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if win ~= term_win and vim.api.nvim_win_is_valid(win) then
				local buf = vim.api.nvim_win_get_buf(win)
				local filename = vim.api.nvim_buf_get_name(buf)
				if endsWith(filename, warning_filename) then
					return win
				end
			end
		end
	end

	-- 2. Get the first instance of a non-terminal window
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if win ~= term_win and vim.api.nvim_win_is_valid(win) then
			return win
		end
	end

	-- 3. Create new window if none found
	local buf = vim.api.nvim_create_buf(true, false)
	local win = vim.api.nvim_open_win(buf, false, require("Ephemera.custom.runMode").opts.normal_win_opts)
	vim.api.nvim_set_option_value("number", true, { win = win })
	return win
end

--- Map a 1-based byte offset within a logical (wrap-joined) line to a
--- physical buffer (row, col0). Non-wrapped lines (nseg == 1) map to
--- start_row with the identity col, preserving pre-wrap behavior exactly.
---@param entry table { text, start_row, nseg, wrap }
---@param o1 number 1-based byte offset into entry.text
function compile.utils.map_logical_pos(entry, o1)
	local off = (o1 or 1) - 1
	local seg = 1
	if entry.nseg and entry.wrap and entry.wrap > 0 then
		seg = math.floor(off / entry.wrap) + 1
		if seg > entry.nseg then
			seg = entry.nseg
		end
		if seg < 1 then
			seg = 1
		end
	end
	return entry.start_row + seg - 1, math.max(0, off - (seg - 1) * (entry.wrap or 0))
end

--- Binary search index
function compile.utils.binary_search(list, num)
	if #list == 0 then
		return 1
	end
	local bot = 1
	local top = #list
	local middle = math.floor((top + bot) / 2)
	while top > bot + 1 do
		middle = math.floor((top + bot) / 2)
		if list[middle] < num then
			bot = middle
		elseif list[middle] > num then
			top = middle
		else
			return middle
		end
	end

	--- top = bot + 1
	if list[top] <= num then
		return top
	end
	return bot
end

return compile.utils
