-- -- Git Logic (Async)
_G.git_branch = ""

local function update_git()
	-- vim.system runs in the background (Async)
	vim.system({ "git", "branch", "--show-current" }, { text = true }, function(out)
		-- The callback runs in a background thread, so we must wrap UI updates
		-- in vim.schedule() to bring them back to the main Neovim thread.
		vim.schedule(function()
			if out.code == 0 then
				local b = vim.trim(out.stdout)
				_G.git_branch = (b ~= "") and ("  " .. b .. " ") or ""
			else
				_G.git_branch = ""
			end
			-- Force the statusline to update now that we have the data
			vim.cmd("redrawstatus")
		end)
	end)
end

vim.api.nvim_create_autocmd({ "BufEnter", "DirChanged" }, { callback = update_git })

-- Define your frames here (Proper Drumming Bongo Cat)
local frames_set = {
	" ₍^. .^₎⟆ ", -- Frame 1: Right Paw Tap
	" ₍^. .^₎  ", -- Frame 2: Lift / Idle
	" ⟅₍^. .^₎ ", -- Frame 3: Left Paw Tap
	" ₍^. .^₎  ", -- Frame 4: Lift / Idle
}

-- List of Static Texts (Selectable via index)
local static_texts = {
	"꧁  ✧ 🌹✧ ꧂", -- Index 1 (Default)
	" ꧁  ⎝𓆩༺  ✧ ༻  𓆪⎠꧂  ", -- Index 2
	" ˗ˏˋ 💤 ˎˊ˗ ", -- Index 3
	"────୨ৎ────", -- Index 4
	" ─── ★ ─── ", -- Index 5
	"  ( ˘ ³˘)♥ ", -- Index 6
	"· · ─ ·𖥸· ─ · ·", -- Index 7
	"ﮩ٨ـﮩﮩ٨ـ 🌹 ﮩ٨ـﮩﮩﮩ٨ـ", -- Index 8
}

-- Global State Table
_G.AnimState = {
	output = static_texts[1],     -- Start with default static text
	idx = 1,                      -- Current frame index
	timer = vim.loop.new_timer(), -- The internal timer
	interval = 200,               -- Speed in ms
	augroup = vim.api.nvim_create_augroup("StatusAnimGroup", { clear = true }),
}

-- Helper: Advances the frame by 1
local function advance_frame()
	_G.AnimState.idx = (_G.AnimState.idx % #frames_set) + 1
	_G.AnimState.output = frames_set[_G.AnimState.idx]
	vim.cmd("redrawstatus") -- Force update
end

function _G.SetAnimMode(input_str)
	-- Split input into mode and argument
	local split_data = vim.split(input_str or "", " ", { trimempty = true })
	local mode = split_data[1] or "static"
	local arg = tonumber(split_data[2]) -- Returns nil if not a number

	local state = _G.AnimState

	-- 1. CLEANUP: Stop everything first (CRITICAL for zero overhead)
	state.timer:stop()
	vim.api.nvim_clear_autocmds({ group = state.augroup })

	-- 2. APPLY NEW MODE
	if mode == "time" then
		-- Set custom speed if provided, else default to 200
		state.interval = arg or 200

		state.timer:start(0, state.interval, vim.schedule_wrap(function()
			advance_frame()
		end))
		-- print("Animation Mode: TIME (".. state.interval .."ms)")
	elseif mode == "input" then
		-- Update on Cursor Move or Typing
		-- Pure 1-to-1 mapping: 1 Input = 1 Frame Advance. No loops, no args.
		state.output = frames_set[1]
		vim.cmd("redrawstatus")

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertCharPre" }, {
			group = state.augroup,
			callback = advance_frame,
		})
		-- print("Animation Mode: INPUT")
	elseif mode == "static" then
		-- Freeze on Static Text
		-- ZERO COMPUTATION: Timer is stopped, AutoCmds cleared. Just setting a string.
		local text_idx = (arg and static_texts[arg]) and arg or 1
		state.output = static_texts[text_idx]

		vim.cmd("redrawstatus")
		-- print("Animation Mode: STATIC (Index: " .. text_idx .. ")")
	else
		-- print("Unknown Mode. Use: time [ms] | input | static [index]")
	end
end

-- Initialize default mode (Static = Zero Overhead)
_G.SetAnimMode("static 1")

-- Create User Command
vim.api.nvim_create_user_command("SlAnimMode", function(opts)
	_G.SetAnimMode(opts.args)
end, {
	nargs = 1,
	complete = function() return { "time", "input", "static" } end
})

function _G.EphemeraStatusLine()
	local width = vim.o.columns
	-- Thresholds
	local show_right = width >= 70
	local show_full  = width >= 90

	local m          = vim.fn.mode()
	local state      = "Norm"
	local label      = "NORMAL"

	if m == 'i' then
		state = "Ins"
		label = "INSERT"
	elseif m:match("^[vV\22]") then
		state = "Vis"
		label = "VISUAL"
	elseif m == 'c' then
		label = "COMMAND"
	elseif m == 'R' then
		label = "REPLACE"
	elseif m == 't' then
		label = "TERMINAL"
	end

	-- Check if branch exists
	local has_branch = _G.git_branch and _G.git_branch ~= ""
	local branch = has_branch and _G.git_branch or ""

	local mod = vim.bo.modified and " 𔒝 " or ""

	local time = os.date("| %a %b %d %I:%M %p")

	-- --- COMPONENT DEFINITIONS ---
	-- 1. LEFT CORE (Sections 1 & 2) -> Always Visible
	local left_core_list = {
		-- Section 1: Mode
		"%#Mode" .. state .. "# " .. label .. " ",
		"%#Sep" .. state .. "A# "
	}

	local filename = ""
	if vim.bo.filetype == "netrw" then
		filename =  " 📂 Explorer"
	else
		-- filename =  " %f"
		filename =  " %t"
	end

	-- Section 2: Branch | Filename
	local info_content = ""
	if has_branch then
		info_content = branch .. " ┆" .. filename
	else
		info_content = filename
	end
	table.insert(left_core_list, "%#Info" .. state .. "#" .. info_content .. mod .. "%r ")

	table.insert(left_core_list, "%#Sep" .. state .. "B# ")

	table.insert(left_core_list, "%#StatusBody#")

	local left_core = table.concat(left_core_list)

    local left_extra = "%#SlRef#" .. _G.statusMessage

	-- 3. MIDDLE SIDE
	local middle_part = "" .. _G.AnimState.output .. ""

	-- 4. RIGHT SIDE
	local right_part = table.concat({
		"%#StatusBody#",
		" %y %l:%c %p%%  ",
		time,
		" "
	})

	-- --- RENDER LOGIC ---
	if not show_right then
		return left_core
	end

	if not show_full then
		return left_core .. "%=" .. right_part
	end

	return left_core .. left_extra .. "%=" .. middle_part .. "%=" .. right_part
end

vim.opt.statusline = "%!v:lua.EphemeraStatusLine()"