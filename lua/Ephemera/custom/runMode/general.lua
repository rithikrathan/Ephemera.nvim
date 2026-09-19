-- =============================================================================
-- runMode -- General pattern matcher (additive, works alongside error patterns)
-- Own namespace + state so it never touches the error pipeline.
-- Specs live in opts.general_patterns: { name = { pattern, handler?, hl?, blink? } }
-- =============================================================================
local compile = {}
compile.general = {}

compile.general.state = {
	ns = vim.api.nvim_create_namespace("RunGeneral"),
}

local opts = {}

local DEFAULT_LINK_PATTERN = '[%w][%w+.-]*://[%w%.~:/%?#%[%]@!$&\'()*+,;=%%-]+'

local BLINK_MS = 250

-- Strip sentence/closing punctuation that broad URL char classes swallow
-- (e.g. `https://a.b/x).` -> keep `https://a.b/x`).
local TRAILING = "[%)%]%}%,%.;:%%?!\"']+$"
local function trim_link(s, start)
	local trimmed = s:gsub(TRAILING, "")
	return trimmed, start + #trimmed - 1
end

local function setup_link_hl()
	vim.api.nvim_set_hl(0, "RunLink", {
		fg = "#000000",
		bg = "#0f6fff",
		bold = true,
	})
end

--- Initialize general-pattern module
function compile.general.setup(o)
	opts = o or {}
	setup_link_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		callback = setup_link_hl,
		desc = "Refresh RunLink highlight",
	})
end

--- The pattern used to find openable links, pulled from the url spec if
--- configured, so open_link() and display stay in sync.
function compile.general.get_link_pattern()
	if opts and opts.general_patterns and opts.general_patterns.url and opts.general_patterns.url.pattern then
		return opts.general_patterns.url.pattern
	end
	return DEFAULT_LINK_PATTERN
end

--- Extract the first match on a line, with capture spans.
--- Returns nil, or { match, span, captures, spans }.
function compile.general.match_line(line, pattern)
	local mstart, mend = string.find(line, pattern)
	if not mstart then
		return nil
	end

	local captures = { string.match(line, pattern) }
	local spans = {}
	local from = mstart
	for i, cap in ipairs(captures) do
		if cap == "" then
			spans[i] = { from - 1, from }
		else
			local s, e = string.find(line, cap, from, true)
			if not s then
				s, e = string.find(line, cap, 1, true)
			end
			s = s or mstart
			e = e or (s + #cap - 1)
			spans[i] = { s - 1, e }
			from = e + 1
		end
	end

	local raw = line:sub(mstart, mend)
	local trimmed = raw:gsub(TRAILING, "")

	return {
		match = trimmed,
		span = { mstart - 1, mstart - 1 + #trimmed },
		captures = captures,
		spans = spans,
	}
end

--- Find all openable links in a line: { text, start (1-based), finish (1-based) }
function compile.general.match_links(line)
	local pattern = compile.general.get_link_pattern()
	local links = {}
	local from = 1
	while true do
		local s, e = string.find(line, pattern, from)
		if not s then
			break
		end
		local text, finish = trim_link(line:sub(s, e), s)
		links[#links + 1] = { text = text, start = s, finish = finish }
		from = e + 1
	end
	return links
end

--- Flash a range in the term buffer using the general namespace.
---@param buf number buffer
---@param row number 1-based row
---@param col_start number 0-based start col
---@param col_end number 1-based end col (matches existing hl.range convention)
---@param timeout number blink duration ms
---@param group string? highlight group, defaults to RunLink
function compile.general.blink_span(buf, row, col_start, col_end, timeout, group)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	timeout = timeout or BLINK_MS
	group = group or "RunLink"
	pcall(vim.hl.range, buf, compile.general.state.ns, group, { row, col_start }, { row, col_end }, {
		priority = 2000,
		timeout = timeout,
	})
end

--- Process newly arrived terminal lines against general patterns.
function compile.general.process_lines(lines, first_line)
	local patterns = (opts and opts.general_patterns) or {}
	for name, spec in pairs(patterns) do
		if type(spec) == "table" and spec.pattern and spec.pattern ~= "" then
			for index, line in ipairs(lines) do
				local m = compile.general.match_line(line, spec.pattern)
				if m then
					local row = first_line + index - 1
					local buf = require("Ephemera.custom.runMode.term").state.buf

					local function pick(which)
						if which == nil or which == "match" then
							return m.span
						end
						return m.spans[which]
					end

					local ctx = {
						name = name,
						buf = buf,
						row = row,
						line = line,
						match = m.match,
						span = m.span,
						captures = m.captures,
						spans = m.spans,
						hl = function(group, which, priority)
							local span = pick(which)
							if span and vim.api.nvim_buf_is_valid(buf) then
								pcall(vim.hl.range, buf, compile.general.state.ns, group, { row, span[1] }, { row, span[2] }, { priority = priority or 2000 })
							end
						end,
						blink = function(group, timeout, which)
							local span = pick(which)
							if span then
								compile.general.blink_span(buf, row, span[1], span[2], timeout, group)
							end
						end,
					}

					if spec.hl then
						ctx.hl(spec.hl)
					end
					if spec.blink then
						ctx.blink(spec.blink, BLINK_MS)
					end
					if spec.handler then
						local ok, err = pcall(spec.handler, ctx)
						if not ok then
							vim.notify(string.format("RunGeneral[%s]: %s", name, tostring(err)), vim.log.levels.ERROR)
						end
					end
				end
			end
		end
	end
end

return compile.general