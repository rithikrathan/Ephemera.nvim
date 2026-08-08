--==-=-=-=-=-=-=-=-=-==[AUTOCOMMANDS]==--=-=-=-=-=-=-=-=--

-- Setting the filetype for SystemVerilog and Verilog
vim.api.nvim_create_autocmd(
	{ "BufNewFile", "BufRead" }, {
		pattern = { "*.sv" },
		command = "set filetype=systemverilog",
	}
)

vim.api.nvim_create_autocmd(
	{ "BufNewFile", "BufRead" }, {
		pattern = { "*.v" },
		command = "set filetype=verilog",
	}
)

-- file type of processing5 python
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.pyde",
	callback = function()
		vim.bo.filetype = "python"
	end,
})

-- file type of processing java
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.pde",
	callback = function()
		vim.bo.filetype = "processing"
	end,
})

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank { higroup = "IncSearch", timeout = 120 }
	end,
})

-- Netrw Tweaks
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "<leader>d", function()
			local dir = vim.b.netrw_curdir
			local target = vim.fn.expand("<cfile>")
			if target ~= "" then
				vim.fn.system({ "cp", "-r", dir .. "/" .. target, dir .. "/" .. target .. ".bak" })
				vim.cmd("edit " .. vim.fn.fnameescape(dir))
				print("Backup created.")
			end
		end, { buffer = true, remap = false })

		vim.keymap.set('n', '<C-P>', function()
			local path = vim.fn.fnamemodify(vim.b.netrw_curdir .. "/" .. vim.fn.expand('<cfile>'), ':.')
			print(path)
			vim.fn.setreg('+', path)
		end, { buffer = true })
	end
})

--==-=-=-=-=-=-=-=-=-==[USER DEFINED COMMANDS]==--=-=-=-=-=-=-=-=--
-- set status messages
 
-- 1. Initialize globals
_G.statusMessage = ""
local last_recorded_symbol = "" 

-- Status Look Up Table (SLUT)
local status_lookup = {
    wtf = "what the fuck mate",
    ok = "All systems operational",
    error = "Critical failure detected",
    busy = "Working on it..."
}

-- 4. Create the command
vim.api.nvim_create_user_command('SetStatus', function(opts)
    local mode, payload = opts.args:match("^(%S+)%s*(.*)$")

    -- Clean up overhead when switching modes
    pcall(vim.api.nvim_del_augroup_by_name, "StatusSmartUpdate")

    if mode == "text" then
        _G.statusMessage = payload
        vim.cmd("redrawstatus")

    elseif mode == "msg" then
        local msg = status_lookup[payload]
        if msg then 
            _G.statusMessage = msg 
            vim.cmd("redrawstatus")
        end

    elseif mode == "aerial" then
        -- Aerial mode removed for vanilla config
        _G.statusMessage = "Aerial mode not available in vanilla config"
        vim.cmd("redrawstatus")
    end
end, {
    nargs = '+',
    complete = function(ArgLead, CmdLine)
        local args = vim.split(CmdLine, "%s+")
        if #args == 2 then return {"text", "msg"} end
        if #args == 3 and args[2] == "msg" then return vim.tbl_keys(status_lookup) end
    end
})