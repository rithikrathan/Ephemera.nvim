local M = {}

-- Make the statusline and end-of-buffer lines look like the background (invisible)
vim.opt_local.winhighlight = "StatusLine:Normal,StatusLineNC:Normal,EndOfBuffer:Normal"

-- =============================================================================
--  CONFIGURATION
-- =============================================================================
M.config = {
	header_text = {
		[[ '||''''|          ||                                      ]],
		[[  ||   .           ||                                      ]],
		[[  ||'''|  '||''|,  ||''|, .|''|, '||),,(|,  .|''|, '||''|  '''|.  ]],
		[[  ||       ||  ||  ||  || ||..||  || || ||  ||..||  ||    .|''||  ]],
		[[ .||....|  ||..|' .||  || `|...  .||    ||. `|...  .||.   `|..||. ]],
		[[           ||                                              ]],
		[[          .||                                              ]],
	},

	quote =
	"And when your sorrow is comforted you will be content that you have known me. You will always be my friend. You will want to laugh with me.",

	buttons = {
		{ "n", "🗎  New File", ":ene <BAR> startinsert  " },
		{ "l", "⟲   LastFile", "`0" },
		{ "e", "🗁  Explorer", ":Oil --float" },
		{ "f", "🔍  Find File", ":Telescope find_files  " },
		{ "r", "⟲   Last Session", ":silent! bwipeout | AutoSession restore  " },
		{ "c", "⚙️  Config", ":e $MYVIMRC  " },
		{ "q", "➜]  Quit", ":qa  " },
	},

	flower_art = {
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠖⠋⠉⠉⠳⡴⠒⠒⠒⠲⠤⢤⣀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠊⠀⠀⡴⠚⡩⠟⠓⠒⡖⠲⡄⠀⠀⠈⡆ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⢠⠒⠾⢥⣀⣇⣚⣹⡤⡟⠀⡇⢠⠀⢠⠇ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣄⣀⠀⡇⠀⠀⠀⠀⠀⢀⡜⠁⣸⢠⠎⣰⣃ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡍⠀⠉⠉⠛⠦⣄⠀⢀⡴⣫⠴⠋⢹⡏⡼⠁⠈⠙⢦⡀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡽⣄⠀⠀⠀⠀⠈⠙⠻⣎⡁⠀⠀⣸⡾⠀⠀⠀⠀⣀⡹⠂ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠉⠓⠶⢟⠀⢀⡤⠖⠋⠁ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠒⠦⡀⠙⠦⣀⠀⠀⠀⠀⠀⠀⢀⣴⡷⠋⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⢦⣀⠈⠓⣦⣤⣤⣤⢶⡟⠁⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣤⣤⡤⠤⠤⠤⠤⣌⡉⠉⠁⠀⠀⢸⢸⠁⡠⠖⠒⠒⢒⣒⡶⣶⠤ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠲⣍⠓⠦⣄⠀⠀⠙⣆⠀⠀⠀⡞⡼⡼⢀⣠⠴⠊⢉⡤⠚⠁ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⠈⠙⢦⡀⢸⡀⠀⢰⢣⡧⠷⣯⣤⠤⠚⠉ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⣲⠤⠬⠿⠧⣠⢏⡞⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡴⠚⠉⠉⢉⣳⣄⣠⠏⡞⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⣟⣒⣋⣉⣉⡭⠟⢡⠏⡼⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠀⠀⠀⠀⠀⠀⠀⢀⠏⣸⠁⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡞⢠⠇⠀⠀⠀ ]],
		[[⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠓⠚⠀⠀⠀ ]],
	},

	highlights = {
		header    = "WelcomeRose",
		quote     = "WelcomeQuote",
		quotemark = "Keyword",
		key       = "DiagnosticHint",
		label     = "Comment",
		flower    = "WelcomeRose",
		stem      = "WelcomeStem",
		bracket   = "Delimiter",
		sep       = "NonText",
	}
}

-- =============================================================================
--  UTILS
-- =============================================================================
local function get_str_width(str)
	return vim.fn.strdisplaywidth(str)
end

local function wrap_text(text, limit)
	limit = limit or 50
	local lines = {}
	local current_line = ""
	for word in text:gmatch("%S+") do
		if get_str_width(current_line .. " " .. word) > limit then
			table.insert(lines, current_line)
			current_line = word
		else
			current_line = (#current_line > 0) and (current_line .. " " .. word) or word
		end
	end
	if #current_line > 0 then table.insert(lines, current_line) end
	return lines
end

-- =============================================================================
--  RENDER ENGINE
-- =============================================================================
function M.draw()
	local buf = vim.api.nvim_get_current_buf()
	local ns_id = vim.api.nvim_create_namespace("Ephemera_welcome")

	-- 1. Buffer Setup
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'filetype', 'dashboard')
	vim.opt_local.number, vim.opt_local.relativenumber = false, false
	vim.opt_local.list, vim.opt_local.cursorline, vim.opt_local.wrap = false, false, false
	vim.opt_local.signcolumn = "no"
	vim.opt_local.fillchars = { eob = " " }

	-- 2. BLOCK EVERYTHING
	local block_keys = {
		'h', 'j', 'k', 'l', '<Up>', '<Down>', '<Left>', '<Right>',
		'w', 'b', 'e', 'ge', '0', '$', '^',
		'<C-u>', '<C-d>', '<C-f>', '<C-b>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb', '<PageUp>', '<PageDown>',
		'gg', 'G', 'H', 'M', 'L', '{', '}', '(', ')', '%',
		'<ScrollWheelUp>', '<ScrollWheelDown>', '<ScrollWheelLeft>', '<ScrollWheelRight>',
		'<LeftMouse>', '<RightMouse>', '<MiddleMouse>', '<2-LeftMouse>', '<3-LeftMouse>', '<4-LeftMouse>',
		'i', 'I', 'a', 'A', 'o', 'O', 'v', 'V', '<C-v>', 'r', 'R', 's', 'S', 'c', 'C',
		'x', 'X', 'd', 'D', 'y', 'Y', 'p', 'P', 'u', '<C-r>',
		'/', '?', 'n', 'N', '*', '#', '<CR>', '<kEnter>'
	}

	for _, key in ipairs(block_keys) do
		vim.keymap.set({ 'n', 'v', 'o' }, key, '<nop>', { buffer = buf, silent = true })
	end

	local win_w = vim.api.nvim_win_get_width(0)
	local win_h = vim.api.nvim_win_get_height(0)
	local draw_queue = {}

	local function queue(row, col, text, hl_group, extra_meta)
		if row < 0 or row >= win_h then return end
		if col < 0 then col = 0 end
		table.insert(draw_queue, {
			row = row,
			col = col,
			text = text,
			group = hl_group,
			meta = extra_meta
		})
	end

	-- 3. MEASUREMENTS
	local header_w = 0
	for _, l in ipairs(M.config.header_text) do header_w = math.max(header_w, get_str_width(l)) end

	local rose_w = 0
	for _, l in ipairs(M.config.flower_art) do rose_w = math.max(rose_w, get_str_width(l)) end

	local max_btn_w = 0
	for _, btn in ipairs(M.config.buttons) do
		local w = get_str_width(string.format("[ %s ]  %s", btn[1], btn[2]))
		max_btn_w = math.max(max_btn_w, w)
	end

	local quote_lines = wrap_text(M.config.quote, header_w)
	if #quote_lines > 0 then
		quote_lines[1] = '"' .. quote_lines[1]
		quote_lines[#quote_lines] = quote_lines[#quote_lines] .. '"'
	end

	-- 4. VERTICAL CENTERING CALCULATION
	local left_content_h = #M.config.header_text + 1 + #quote_lines + 2 + #M.config.buttons
	local rose_h = #M.config.flower_art
	local total_content_h = math.max(left_content_h, rose_h)
	local start_row = math.max(0, math.floor((win_h - total_content_h) / 2))

	-- 5. RESPONSIVE HORIZONTAL POSITIONING
	local gap = 4
	local total_dual_w = header_w + gap + 1 + gap + rose_w
	local show_rose = (win_w >= total_dual_w + 4)

	local left_col_x, right_col_x, sep_col_x

	if show_rose then
		local origin = math.floor((win_w - total_dual_w) / 2)
		left_col_x   = math.max(2, origin)
		sep_col_x    = left_col_x + header_w + gap
		right_col_x  = sep_col_x + gap + 1
	else
		left_col_x = math.max(2, math.floor((win_w - header_w) / 2))
		right_col_x, sep_col_x = -1, -1
	end

	-- 6. POSITIONING WITH START_ROW OFFSET
	local header_y = start_row
	local quote_y = header_y + #M.config.header_text + 1
	local btn_start_y = quote_y + #quote_lines + 2
	local btn_end_y = btn_start_y + #M.config.buttons - 1

	-- A. Header
	for i, line in ipairs(M.config.header_text) do
		queue(header_y + i - 1, left_col_x, line, M.config.highlights.header)
	end

	-- B. Quote
	for i, line in ipairs(quote_lines) do
		local w = get_str_width(line)
		local pad = math.max(0, math.floor((header_w - w) / 2))
		queue(quote_y + i - 1, left_col_x + pad, line, nil, {
			type = "quote", has_start = (i == 1), has_end = (i == #quote_lines)
		})
	end

	-- C. Buttons
	local btn_pad = math.max(0, math.floor((header_w - max_btn_w) / 2))
	for i, btn in ipairs(M.config.buttons) do
		local str = string.format("[ %s ]  %s", btn[1], btn[2])
		queue(btn_start_y + i - 1, left_col_x + btn_pad, str, nil, { is_btn = true, key = btn[1] })
	end

	-- D. Separator & Rose
	if show_rose then
		local rose_start_y = header_y
		local total_h = math.max(btn_end_y, rose_start_y + #M.config.flower_art - 1)

		for i = header_y, total_h do
			queue(i, sep_col_x, "│", M.config.highlights.sep)
		end

		for i, line in ipairs(M.config.flower_art) do
			local group = (i < 11) and M.config.highlights.flower or M.config.highlights.stem
			queue(rose_start_y + i - 1, right_col_x, line, group)
		end
	end

	-- 7. RENDER
	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
	local empty_lines = {}
	for i = 1, win_h do empty_lines[i] = string.rep(" ", win_w) end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, empty_lines)

	table.sort(draw_queue, function(a, b)
		if a.row ~= b.row then
			return a.row < b.row
		else
			return a.col > b.col
		end
	end)

	for _, item in ipairs(draw_queue) do
		local row, col, text = item.row, item.col, item.text
		pcall(vim.api.nvim_buf_set_text, buf, row, col, row, col + get_str_width(text), { text })

		local end_byte = col + #text
		if item.meta and item.meta.is_btn then
			local k_len = #item.meta.key
			vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.bracket, row, col, col + 1)
			vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.key, row, col + 2, col + 2 + k_len)
			vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.bracket, row, col + 3 + k_len, col + 4 + k_len)
			vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.label, row, col + 4 + k_len + 2, end_byte)
		elseif item.meta and item.meta.type == "quote" then
			local s, e = col, end_byte
			if item.meta.has_start then
				vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.quotemark, row, s, s + 1)
				s = s + 1
			end
			if item.meta.has_end then
				vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.quotemark, row, e - 1, e)
				e = e - 1
			end
			if s < e then vim.api.nvim_buf_add_highlight(buf, ns_id, M.config.highlights.quote, row, s, e) end
		elseif item.group then
			vim.api.nvim_buf_add_highlight(buf, ns_id, item.group, row, col, end_byte)
		end
	end

	vim.api.nvim_buf_set_option(buf, 'modifiable', false)
	for _, btn in ipairs(M.config.buttons) do
		vim.api.nvim_buf_set_keymap(buf, 'n', btn[1], btn[3] .. "<CR>", { noremap = true, silent = true })
	end
end

function M.setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function() if vim.fn.argc() == 0 then M.draw() end end,
	})
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function() if vim.bo.filetype == "dashboard" then M.draw() end end,
	})
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "dashboard",
		callback = function()
			vim.opt_local.statusline = " "
		end,
	})
	vim.api.nvim_create_autocmd("TabNewEntered", {
		callback = function()
			local buf = vim.api.nvim_get_current_buf()
			if vim.bo[buf].buftype ~= "" or vim.fn.bufname(buf) ~= "" then return end
			if vim.api.nvim_buf_line_count(buf) ~= 1 then return end
			local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
			if #lines == 0 or #lines[1] ~= 0 then return end
			M.draw()
            vim.opt_local.statusline = " "
            vim.opt_local.winhl = "StatusLine:Normal,StatusLineNC:Normal"
		end,
	})
end

return M
