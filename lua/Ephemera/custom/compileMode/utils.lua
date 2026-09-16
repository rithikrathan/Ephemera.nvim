-- =============================================================================
-- compileMode -- Fork of pohlrabi404/compile.nvim
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
	if (not require("Ephemera.custom.compileMode").opts.enter) and vim.api.nvim_win_is_valid(current_win) then
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

--- Get valid non-terminal window
function compile.utils.get_normal_win()
	local term_win = require("Ephemera.custom.compileMode.term").state.win
	local current_warning = require("Ephemera.custom.compileMode.highlight").get_current_warning()
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
	local win = vim.api.nvim_open_win(buf, false, require("Ephemera.custom.compileMode").opts.normal_win_opts)
	vim.api.nvim_set_option_value("number", true, { win = win })
	return win
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
