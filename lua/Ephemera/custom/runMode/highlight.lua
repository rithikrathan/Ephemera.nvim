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
	vim.api.nvim_set_hl(0, "RunBlink", {
        fg = "#000000",
		bg = orange,
		bold = true,
		italic = true,
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
local function highlight_extract(location_pattern, lines, first_line)
	local pattern = location_pattern[1]
	local positions = require("Ephemera.custom.runMode.utils").split_to_num(location_pattern[2])
	local term_buf = require("Ephemera.custom.runMode.term").state.buf

	if #positions == 2 then
		for index, line in ipairs(lines) do
			local a, b = string.match(line, pattern)
			if not (a and b) then
				goto continue
			end

			local as, ae = string.find(line, a, 1, true)
			as = as or 1
			ae = ae or #a

			local bs, be = string.find(line, b, ae + 1, true)
			if not bs then
				bs, be = string.find(line, b, 1, true)
			end
			bs = bs or (ae + 1)
			be = be or (bs + #b - 1)

			local sorted = {}
			sorted[positions[1]] = { a, as, ae }
			sorted[positions[2]] = { b, bs, be }

			local formatted = {}
			formatted["file"] = {
				val = sorted[1][1],
				pos = { { first_line + index - 1, sorted[1][2] - 1 }, { first_line + index - 1, sorted[1][3] } },
			}
			formatted["row"] = {
				val = tonumber(sorted[2][1]) or 1,
				pos = { { first_line + index - 1, sorted[2][2] - 1 }, { first_line + index - 1, sorted[2][3] } },
			}
			formatted["col"] = {
				val = 0,
				pos = { { first_line + index - 1, sorted[2][2] - 1 }, { first_line + index - 1, sorted[2][3] } },
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

			::continue::
		end
		return
	end

	for index, line in ipairs(lines) do
		local a, b, c = string.match(line, pattern)
		if not (a and b and c) then
			goto continue
		end

		local as, ae = string.find(line, a, 1, true)
		as = as or 1
		ae = ae or #a

		local bs, be = string.find(line, b, ae + 1, true)
		if not bs then
			bs, be = string.find(line, b, 1, true)
		end
		bs = bs or (ae + 1)
		be = be or (bs + #b - 1)

		local cs, ce = string.find(line, c, be + 1, true)
		if not cs then
			cs, ce = string.find(line, c, 1, true)
		end
		cs = cs or (be + 1)
		ce = ce or (cs + #c - 1)

		local sorted = {}
		sorted[positions[1]] = { a, as, ae }
		sorted[positions[2]] = { b, bs, be }
		sorted[positions[3]] = { c, cs, ce }

		local formatted = {}
		formatted["file"] = {
			val = sorted[1][1],
			pos = { { first_line + index - 1, sorted[1][2] - 1 }, { first_line + index - 1, sorted[1][3] } },
		}
		formatted["row"] = {
			val = tonumber(sorted[2][1]) or 1,
			pos = { { first_line + index - 1, sorted[2][2] - 1 }, { first_line + index - 1, sorted[2][3] } },
		}
		formatted["col"] = {
			val = tonumber(sorted[3][1]) or 0,
			pos = { { first_line + index - 1, sorted[3][2] - 1 }, { first_line + index - 1, sorted[3][3] } },
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

		::continue::
	end
end

--- Process incoming terminal lines
function compile.highlight.process_lines(lines, first_line)
	for _, location_pattern in pairs(opts.patterns) do
		highlight_extract(location_pattern, lines, first_line)
	end
end

return compile.highlight
