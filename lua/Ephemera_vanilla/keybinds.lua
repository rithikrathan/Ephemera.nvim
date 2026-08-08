-- Insert Mode Cursor Movement (Alt + hjkl)
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move cursor right" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "Move cursor down" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "Move cursor up" })
vim.keymap.set("i", "<A-o>", '<Esc>o')
vim.keymap.set("i", "<A-O>", '<Esc>O')

-- Basic Mappings
vim.keymap.set({ "n", "v", "t", "i" }, "<A-n>", '<CR>', { remap = true })
vim.keymap.set({ "n", "v", "t", "i" }, "<leader>h", '"+y', { remap = true })
vim.keymap.set({ "n", "v", "t", "i" }, "<F5>", ':w | nohl | make<CR>', { remap = true })
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set({ "n", "i" }, "<A-[>", "zt")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set({ "v", "i" }, "<leader><Tab>", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("t", "<leader><Tab>", "<C-\\><C-n>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>d", "yyp", { desc = "Duplicate current line" })
vim.keymap.set("i", "<leader>tn", "<C-o>", { desc = "Temporary normal mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "g_")
vim.keymap.set("v", "<leader>dd", "y'>p")

-- Wraps
vim.keymap.set("v", "<leader>wp", ":s/\\%V.*\\%V/(&)/ | nohl<CR>")
vim.keymap.set("v", "<leader>wpp", ":s/\\%V.*\\%V/{&}/ | nohl<CR>")
vim.keymap.set("v", "<leader>wqq", ':s/\\%V.*\\%V/"&"/ | nohl<CR>')
vim.keymap.set("v", "<leader>wq", ":s/\\%V.*\\%V/'&'/ | nohl<CR>")
vim.keymap.set("v", "<leader>wb", ":s/\\%V.*\\%V/`&`/ | nohl<CR>")

-- Misc Insert helpers
vim.keymap.set("i", "<leader>fjk", "<><left>")
vim.keymap.set("n", "ct", 'vitc')
vim.keymap.set("i", "<A-=>", ' := ')
vim.keymap.set("n", "vt", 'vit')

-- Splits & Windows
vim.keymap.set("n", "<leader>h", ":split<CR>")
vim.keymap.set("n", "<leader>v", ":vsplit<CR>")
vim.keymap.set("n", "<A-h>", "<C-w><C-h>")
vim.keymap.set("n", "<A-l>", "<C-w><C-l>")
vim.keymap.set("n", "<C-j>", "<C-w><C-j>")
vim.keymap.set("n", "<C-k>", "<C-w><C-k>")
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Files & Finder (Native)
vim.keymap.set("n", "<leader>nf", function()
	local netrw_dir = vim.fn.expand("%:p:h")
	local filename = vim.fn.input("New file: ")
	if filename ~= "" then
		local filepath = netrw_dir .. "/" .. filename
		vim.fn.system("touch " .. vim.fn.shellescape(filepath))
		print("Created: " .. filepath)
	else
		print("Canceled.")
	end
end)

vim.keymap.set('n', '<leader>x', function() os.execute('xdg-open ' .. vim.fn.expand('%:p:h')) end)

vim.keymap.set('n', '<leader>xx', function()
	local app = vim.fn.input("Open with: ")
	if app ~= "" then os.execute(app .. " " .. vim.fn.shellescape(vim.fn.expand('%:p')) .. " &") end
end)

-- vim.opt.path:append("**")
-- vim.opt.wildmenu = true
-- vim.keymap.set("n", "<leader>pf", ":find *")
-- vim.keymap.set("n", "<leader>fb", ":ls<CR>:b<Space>")
--
-- vim.keymap.set("n", "<leader>ff", function()
--     local path = vim.fn.input("Find file: ", "", "file")
--     if path ~= "" then vim.cmd("edit " .. path) end
-- end)

vim.keymap.set("n", "<leader>fg", function()
	local pattern = vim.fn.input("Grep > ")
	if pattern ~= "" then
		vim.cmd("grep! -r " .. pattern .. " ."); vim.cmd("copen")
	end
end)

-- Replace Word
vim.keymap.set("n", "<leader>rw", function()
	local word = vim.fn.expand("<cword>")
	local replacement = vim.fn.input("Replace '" .. word .. "' with: ")
	if replacement ~= "" then vim.cmd("%s/\\<" .. word .. "\\>/" .. replacement .. "/gc") end
end)

-- Floating Terminal
vim.keymap.set('n', '<leader>t', function()
	local file_dir = vim.fn.expand('%:p:h')
	local buf, win = _G.create_floating_window()
	vim.keymap.set({ "n", "t" }, "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
	vim.fn.termopen(vim.o.shell, { cwd = file_dir })
	vim.cmd('startinsert')
end)

-- Make Run
vim.keymap.set("n", "<leader>r", function()
	local arg = vim.fn.input("Arg: ")
	local buf, win = _G.create_floating_window()
	vim.keymap.set("t", "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
	local job = vim.fn.termopen(vim.o.shell)
	vim.fn.chansend(job, "make run " .. arg .. "\n")
	vim.cmd("startinsert")
end)