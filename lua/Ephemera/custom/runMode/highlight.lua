-- =============================================================================
-- runMode -- Fork of pohlrabi404/compile.nvim
-- Original: https://github.com/pohlrabi404/compile.nvim
-- License: MIT
-- Modified by: Ephemera (Rithik)
-- =============================================================================
local compile = {}
compile.highlight = {}

compile.highlight.state = {
	warning_list = {},
	warning_index = {},
	current_warning = 0,
}

compile.highlight.ns = vim.api.nvim_create_namespace("TermHl")

local function setup_run_blink()
	local orange = "#bb1111"
	local red = "#ff5555"
	vim.api.nvim_set_hl(0, "RunBlink", {
        fg = "#000000",
		bg = orange,
		bold = true,
		italic = true,
	})
	-- Persistent error-file/row/col highlighting (red, not the yellowish defaults)
	vim.api.nvim_set_hl(0, "RunError", {
		fg = red,
		bold = true,
	})
end

--- Initialize highlight module
function compile.highlight.setup(o)
	opts = o
	setup_run_blink()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = setup_run_blink,
		desc = "Refresh RunBlink highlight from Boolean color",
	})
end

--- Clear all warning highlights
function compile.highlight.clear_hl_warning()
	if vim.api.nvim_buf_is_valid(require("Ephemera.custom.runMode.term").state.buf) then
		vim.api.nvim_buf_clear_namespace(require("Ephemera.custom.runMode.term").state.buf, compile.highlight.ns, 0, -1)
	end
	compile.highlight.state.warning_list = {}
	compile.highlight.state.warning_index = {}
end

--- Check if warnings exist
function compile.highlight.has_warnings()
	return compile.highlight.state.warning_index and #compile.highlight.state.warning_index > 0
end

--- Get current warning data
function compile.highlight.get_current_warning()
	if not compile.highlight.has_warnings() then
		return nil
	end
	local idx = compile.highlight.state.current_warning
	if not idx or idx < 1 or idx > #compile.highlight.state.warning_index then
		idx = 1
		compile.highlight.state.current_warning = 1
	end
	local key = compile.highlight.state.warning_index[idx]
	return compile.highlight.state.warning_list[key]
end

--- Navigate to next warning
function compile.highlight.next_warning()
	if not compile.highlight.has_warnings() then
		return
	end
	if compile.highlight.state.current_warning >= #compile.highlight.state.warning_index then
		compile.highlight.state.current_warning = 1
	else
		compile.highlight.state.current_warning = compile.highlight.state.current_warning + 1
	end
end

--- Navigate to previous warning
function compile.highlight.prev_warning()
	if not compile.highlight.has_warnings() then
		return
	end
	if compile.highlight.state.current_warning <= 1 then
		compile.highlight.state.current_warning = #compile.highlight.state.warning_index
	else
		compile.highlight.state.current_warning = compile.highlight.state.current_warning - 1
	end
end

--- Navigate to first warning
function compile.highlight.first_warning()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.highlight.state.current_warning = 1
end

--- Navigate to last warning
function compile.highlight.last_warning()
	if not compile.highlight.has_warnings() then
		return
	end
	compile.highlight.state.current_warning = #compile.highlight.state.warning_index
end

-- Process new terminal lines for warnings
-- Each entry is a logical (wrap-joined) line: { text, start_row, nseg, wrap }.
-- Match offsets (from string.find) are logical byte positions; they are mapped
-- back to physical buffer rows/cols so highlights and goto positions stay exact
-- even when the PTY hard-wrapped a long compiler line across several rows.
local function highlight_extract(location_pattern, entry)
	local utils = require("Ephemera.custom.runMode.utils")
	if utils.is_runmode_footer(entry.text) then
		return
	end
	local pattern = location_pattern[1]
	local positions = utils.split_to_num(location_pattern[2])
	local term_buf = require("Ephemera.custom.runMode.term").state.buf
	local map = utils.map_logical_pos

	if #positions == 2 then
		local a, b = string.match(entry.text, pattern)
		if not (a and b) then
			return
		end

		local as, ae = string.find(entry.text, a, 1, true)
		as = as or 1
		ae = ae or #a

		local bs, be = string.find(entry.text, b, ae + 1, true)
		if not bs then
			bs, be = string.find(entry.text, b, 1, true)
		end
		bs = bs or (ae + 1)
		be = be or (bs + #b - 1)

		local sorted = {}
		sorted[positions[1]] = { a, as, ae }
		sorted[positions[2]] = { b, bs, be }

		local formatted = {}
		local f_r, f_c = map(entry, sorted[1][2])
		local f_r2, f_c2 = map(entry, sorted[1][3] + 1)
		formatted["file"] = {
			val = sorted[1][1],
			pos = { { f_r, f_c }, { f_r2, f_c2 } },
		}
		local r_r, r_c = map(entry, sorted[2][2])
		local r_r2, r_c2 = map(entry, sorted[2][3] + 1)
		formatted["row"] = {
			val = tonumber(sorted[2][1]) or 1,
			pos = { { r_r, r_c }, { r_r2, r_c2 } },
		}
		formatted["col"] = {
			val = 0,
			pos = { { r_r, r_c }, { r_r2, r_c2 } },
		}

		-- Apply highlights if buffer is valid
		if vim.api.nvim_buf_is_valid(term_buf) then
			pcall(vim.hl.range,
				term_buf,
				compile.highlight.ns,
				opts.colors.file,
				formatted.file.pos[1],
				formatted.file.pos[2]
			)
			pcall(vim.hl.range,
				term_buf,
				compile.highlight.ns,
				opts.colors.row,
				formatted.row.pos[1],
				formatted.row.pos[2]
			)
		end

		-- Store warning (preventing duplicate matches on the same terminal line)
		local key = formatted.file.val .. ":" .. formatted.row.val .. ":" .. formatted.col.val
		if not compile.highlight.state.warning_list[key] then
			local line_num = formatted.file.pos[1][1]
			local already_exists = false
			for _, existing_key in ipairs(compile.highlight.state.warning_index) do
				local existing = compile.highlight.state.warning_list[existing_key]
				if existing and existing.file.pos[1][1] == line_num and existing.file.val == formatted.file.val and existing.row.val == formatted.row.val then
					already_exists = true
					break
				end
			end

			if not already_exists then
				compile.highlight.state.warning_list[key] = formatted
				table.insert(compile.highlight.state.warning_index, key)
			end
		end
		return
	end

	local a, b, c = string.match(entry.text, pattern)
	if not (a and b and c) then
		return
	end

	local as, ae = string.find(entry.text, a, 1, true)
	as = as or 1
	ae = ae or #a

	local bs, be = string.find(entry.text, b, ae + 1, true)
	if not bs then
		bs, be = string.find(entry.text, b, 1, true)
	end
	bs = bs or (ae + 1)
	be = be or (bs + #b - 1)

	local cs, ce = string.find(entry.text, c, be + 1, true)
	if not cs then
		cs, ce = string.find(entry.text, c, 1, true)
	end
	cs = cs or (be + 1)
	ce = ce or (cs + #c - 1)

	local sorted = {}
	sorted[positions[1]] = { a, as, ae }
	sorted[positions[2]] = { b, bs, be }
	sorted[positions[3]] = { c, cs, ce }

	local formatted = {}
	local f_r, f_c = map(entry, sorted[1][2])
	local f_r2, f_c2 = map(entry, sorted[1][3] + 1)
	formatted["file"] = {
		val = sorted[1][1],
		pos = { { f_r, f_c }, { f_r2, f_c2 } },
	}
	local r_r, r_c = map(entry, sorted[2][2])
	local r_r2, r_c2 = map(entry, sorted[2][3] + 1)
	formatted["row"] = {
		val = tonumber(sorted[2][1]) or 1,
		pos = { { r_r, r_c }, { r_r2, r_c2 } },
	}
	local c_r, c_c = map(entry, sorted[3][2])
	local c_r2, c_c2 = map(entry, sorted[3][3] + 1)
	formatted["col"] = {
		val = tonumber(sorted[3][1]) or 0,
		pos = { { c_r, c_c }, { c_r2, c_c2 } },
	}

	-- Apply highlights if buffer is valid
	if vim.api.nvim_buf_is_valid(term_buf) then
		pcall(vim.hl.range,
			term_buf,
			compile.highlight.ns,
			opts.colors.file,
			formatted.file.pos[1],
			formatted.file.pos[2]
		)
		pcall(vim.hl.range,
			term_buf,
			compile.highlight.ns,
			opts.colors.row,
			formatted.row.pos[1],
			formatted.row.pos[2]
		)
		pcall(vim.hl.range,
			term_buf,
			compile.highlight.ns,
			opts.colors.col,
			formatted.col.pos[1],
			formatted.col.pos[2]
		)
	end

	-- Store warning (preventing duplicate matches on the same terminal line)
	local key = formatted.file.val .. ":" .. formatted.row.val .. ":" .. formatted.col.val
	if not compile.highlight.state.warning_list[key] then
		local line_num = formatted.file.pos[1][1]
		local already_exists = false
		for _, existing_key in ipairs(compile.highlight.state.warning_index) do
			local existing = compile.highlight.state.warning_list[existing_key]
			if existing and existing.file.pos[1][1] == line_num and existing.file.val == formatted.file.val and existing.row.val == formatted.row.val then
				already_exists = true
				break
			end
		end

		if not already_exists then
			compile.highlight.state.warning_list[key] = formatted
			table.insert(compile.highlight.state.warning_index, key)
		end
	end
end

--- Process incoming terminal output
---@param logical_lines table[] entries { text, start_row, nseg, wrap }
function compile.highlight.process_lines(logical_lines)
	local pattern_keys = vim.tbl_keys(opts.patterns)
	table.sort(pattern_keys)
	for _, key in ipairs(pattern_keys) do
		for _, entry in ipairs(logical_lines) do
			highlight_extract(opts.patterns[key], entry)
		end
	end
end

return compile.highlight
