vim.opt.mouse = "a"
vim.opt.timeoutlen = 273

--Plugin specific keymaps
vim.keymap.set("n", "<leader>gs", vim.cmd.Git)                                                                --open a Git window
vim.keymap.set("n", "<leader>gg", vim.cmd.GitGutterToggle)                                                    --Toggle gitgutter
vim.keymap.set("n", "<leader>gt", "<cmd>GitGutterLineHighlightsToggle | GitGutterLineNrHighlightsToggle<CR>") --toggle git line highlights
vim.keymap.set("n", "<leader>1", vim.cmd.Mason)                                                               --open Mason window
vim.keymap.set("n", "<leader>2", vim.cmd.Lazy)                                                                --open Lazy window
vim.keymap.set("n", "<leader>m", vim.cmd.MinimapToggle)
vim.keymap.set("n", "<leader>tt", "<cmd>sp | term<CR>")

--use this keybind to test some function
vim.keymap.set("n", "]]]", function()
	-- print(vim.fn.getcwd())
	print(vim.fn.expand('%:p:h'))
end)

-- testing new keymaps

--  Netrw + current buffer relative path copy
-- normal buffers
vim.keymap.set('n', '<C-P>', function()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then return end
	local rel = vim.fn.fnamemodify(path, ':.')
	print(rel)
	vim.fn.setreg('+', vim.fn.shellescape(rel))
end)

-- netrw
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'netrw',
	callback = function()
		vim.keymap.set('n', '<C-P>', function()
			local dir = vim.b.netrw_curdir
			local entry = vim.fn.expand('<cfile>')
			if not dir or entry == "" then return end
			local path = vim.fn.fnamemodify(dir .. "/" .. entry, ':.')
			print(path)
			vim.fn.setreg('+', vim.fn.shellescape(path))
		end, { buffer = true })
	end
})

--GODlike keymaps
--create a new file without opening it in the editor
vim.keymap.set("n", "<leader>nf", function()
	local netrw_dir = vim.fn.expand("%:p:h")
	local filename = vim.fn.input("New file: ")
	if filename ~= "" then
		local filepath = netrw_dir .. "/" .. filename
		vim.fn.system("touch " .. vim.fn.shellescape(filepath))
		print("Created: " .. filepath)
	else
		print("Canceled file creation.")
	end
end, { desc = "Create file in current netrw directory" })

-- Floating terminal
vim.keymap.set('n', '<leader>t', function()
	local file_dir = vim.fn.expand('%:p:h')

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = math.floor(vim.o.columns * 0.80),
		height = math.floor(vim.o.lines * 0.80),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor(vim.o.columns * 0.1),
		style = 'minimal',
		border = 'rounded',
	})

	-- esc = close
	vim.keymap.set({ "n", "t" }, "<esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.api.nvim_set_hl(0, 'Terminal', { fg = '#00ff00', bg = '#000000' })
	vim.api.nvim_set_hl(0, 'Terminal', { bg = '#000000', fg = '#00ff00' })
	vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff3322' })

	vim.fn.termopen(vim.o.shell, { cwd = file_dir })
	vim.cmd('startinsert')
end)

-- make run
vim.keymap.set("n", "<leader>r", function()
	local arg = vim.fn.input("Arg: ")
	local file_dir = vim.fn.expand("%:p:h")

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = math.floor(vim.o.columns * 0.80),
		height = math.floor(vim.o.lines * 0.80),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor(vim.o.columns * 0.1),
		style = 'minimal',
		border = 'rounded',
	})


	-- esc = close
	vim.keymap.set({ "n", "t" }, "<esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.api.nvim_set_hl(0, 'Terminal', { fg = '#00ff00', bg = '#000000' })
	vim.api.nvim_set_hl(0, 'Terminal', { bg = '#000000', fg = '#00ff00' })
	vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff3322' })

	local job = vim.fn.termopen(vim.o.shell, { cwd = file_dir })
	vim.fn.chansend(job, "make run " .. arg .. "\n")
	vim.cmd("startinsert")
end)

-- make <anything>
vim.keymap.set("n", "<F6>", function()
	local arg = vim.fn.input("Make: ")
	local file_dir = vim.fn.expand("%:p:h")

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = 'editor',
		width = math.floor(vim.o.columns * 0.80),
		height = math.floor(vim.o.lines * 0.80),
		row = math.floor(vim.o.lines * 0.1),
		col = math.floor(vim.o.columns * 0.1),
		style = 'minimal',
		border = 'rounded',
	})

	-- esc = close
	vim.keymap.set({ "n", "t" }, "<esc>", function()
		vim.api.nvim_win_close(win, true)
	end, { buffer = buf })

	vim.api.nvim_set_hl(0, 'Terminal', { fg = '#00ff00', bg = '#000000' })
	vim.api.nvim_set_hl(0, 'Terminal', { bg = '#000000', fg = '#00ff00' })
	vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff3322' })

	local job = vim.fn.termopen(vim.o.shell, { cwd = file_dir })
	vim.fn.chansend(job, "make " .. arg .. "\n")
	vim.cmd("startinsert")
end)


vim.keymap.set('n', '<leader>x', function()
	local fileDir = vim.fn.expand('%:p:h')
	print("Opening: ", fileDir) -- optional, for debug
	os.execute('xdg-open ' .. fileDir)
end, { desc = 'Open the current file directory in the file explorer' })

vim.keymap.set('n', '<leader>xx', function()
	local file = vim.fn.expand('%:p')    -- full path of current file
	local app = vim.fn.input("Open with: ") -- prompt for application
	if app ~= "" then
		os.execute(app .. " " .. vim.fn.shellescape(file) .. " &")
	end
end, { desc = 'Open current file with custom application' })

vim.keymap.set('n', '<leader>X', function()
	local dir = vim.fn.expand('%:p:h')   -- directory of current file
	local app = vim.fn.input("Open with: ") -- prompt for application
	if app ~= "" then
		os.execute(vim.fn.shellescape(app) .. " " .. vim.fn.shellescape(dir) .. " &")
	end
end, { desc = 'Open current directory with custom application' })


-- Replace the word under the cursor
vim.keymap.set("n", "<leader>rw", function()
	local word = vim.fn.expand("<cword>")
	local replacement = vim.fn.input("Replace '" .. word .. "' with: ")
	if replacement ~= "" then
		vim.cmd("%s/\\<" .. word .. "\\>/" .. replacement .. "/gc")
	end
end, { desc = "Replace word under cursor with prompt" })

vim.keymap.set({ "n", "v", "t", "i" }, "<A-n>", '<CR>', { remap = true })                --map enter to alt-n
vim.keymap.set({ "n", "v", "t", "i" }, "<F5>", ':w | nohl | make<CR>', { remap = true }) --run make
vim.keymap.set("v", ">", ">gv")
vim.keymap.set({ "n", "i" }, "<A-[>", "zt")
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("i", "<leader><Tab>", "<Esc>", { noremap = true, silent = true, desc = "Exit insert mode" })
vim.keymap.set("v", "<leader><Tab>", "<Esc>", { noremap = true, silent = true, desc = "Exit visual mode" })
vim.keymap.set("t", "<leader><Tab>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>d", "yyp", { desc = "Duplicate current line" })
vim.keymap.set("i", "<leader>;", "<C-o>", { desc = "Temporary normal mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move selected lines down
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "H", "^")                                       -- Move to the first non-blank character
vim.keymap.set("n", "L", "g_")                                      -- Move to the last non-blank character
vim.keymap.set("v", "<leader>dd", "y'>p")                           -- Duplicate visual selection
vim.keymap.set("v", "<leader>wp", ":s/\\%V.*\\%V/(&)/ | nohl<CR>")  --wrap the selected text around parentheses
vim.keymap.set("v", "<leader>wpp", ":s/\\%V.*\\%V/{&}/ | nohl<CR>") --wrap the selected text around curly braces
vim.keymap.set("v", "<leader>wqq", ':s/\\%V.*\\%V/"&"/ | nohl<CR>') --wrap the selected text around double quotes
vim.keymap.set("v", "<leader>wq", ":s/\\%V.*\\%V/'&'/ | nohl<CR>")  --wrap the selected test around single quotes
vim.keymap.set("v", "<leader>wb", ":s/\\%V.*\\%V/`&`/ | nohl<CR>")  --wrap the selected test around back ticks
vim.keymap.set("i", "<leader>fjk", "<><left>")                      --type <> and place your cursor between it in insert mode
vim.keymap.set("n", "ct", 'vitc')                                   --change text between tags(html)
vim.keymap.set("i", "<A-=>", ' := ')
vim.keymap.set("n", "vt", 'vit')                                    --select text between tags(html)
vim.keymap.set("i", "<A-o>", '<Esc>o')                              --write a new line below
vim.keymap.set("i", "<A-O>", '<Esc>O')                              --write a new line abovo
vim.keymap.set("i", "<A-l>", "<right>")
vim.keymap.set("i", "<A-h>", "<left>")
vim.keymap.set("i", "<A-k>", "<C-right>")
vim.keymap.set("i", "<A-j>", "<C-left>")


--Split windows,navigation keymaps CTRL+<hjkl>
vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Split horizontal windowx" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Split vertical windowx" })
vim.keymap.set("n", "<A-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<A-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Resize splits using arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>")
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>")
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

--Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fgi", builtin.git_files, { desc = "Telescope git file search" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fs", function()
	builtin.grep_string({ search = vim.fn.input("Grep >") })
end, { desc = "Telescope grep" })

--Harpoon with telescope setup and keymaps
local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>s", function()
	harpoon:list():remove()
end)
vim.keymap.set("n", "<A-=>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<A-->", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<A-0>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<A-9>", function()
	harpoon:list():select(4)
end)
--Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
	harpoon:list():next()
end)

-- find files and dirs
vim.keymap.set('n', '<leader>jdf', function()
	vim.cmd("Files")
end)

--LSP-zero keymaps
vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP actions",
	callback = function(event)
		local opts = { buffer = event.buf }
		-- > change these in the future
		vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
		vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
		vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
		vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
		vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
		vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
		vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
		vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
		vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
		vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
	end,
})


--nvim-toggle keymap
vim.keymap.set({ 'n', 'v' }, '<leader>i', require("nvim-toggler").toggle)

--nvim cht.sh thing
vim.keymap.set("n", "<leader>ch", function()
	local lang = vim.fn.input("Language: ")
	if lang == "" then return end

	local lib = vim.fn.input("Library/Framework (optional): ")
	local topic = vim.fn.input("Topic: ")
	if topic == "" then return end

	-- Build query string safely
	local query = lang
	if lib ~= "" then
		query = query .. "~" .. lib
	end
	query = query .. "/" .. topic

	-- URL encode spaces
	query = query:gsub(" ", "+")

	local url = "https://cht.sh/" .. query .. "?T&style=rrt"
	local cmd = "curl -s '" .. url .. "' | sed 's/\\x1b\\[[0-9;]*m//g'"
	local output = vim.fn.systemlist(cmd)

	if vim.tbl_isempty(output) then
		print("No results found!")
		return
	end

	vim.cmd("vnew")
	local buf = vim.api.nvim_get_current_buf()

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false
	vim.bo[buf].modifiable = true

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, output)
end, { desc = "cht.sh query with optional library" })

-- toggle autopairs
vim.keymap.set({ "n", "i" }, "<A-p>", function()
	print("Toggle autoPairs")
	require("nvim-autopairs").toggle()
end, { desc = "Toggle autopairs" })

-- create backup of a file in netrw
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	desc = "Bind backup keymap only in Netrw",
	callback = function()
		vim.keymap.set("n", "<leader>d", function()
			local dir = vim.b.netrw_curdir
			local target_name = vim.fn.expand("<cfile>")

			if not dir or target_name == "" then
				print("No file selected")
				return
			end

			local file_path = dir .. "/" .. target_name

			local backup_path = file_path .. ".bak"
			vim.fn.system({ "cp", "-r", file_path, backup_path })

			if vim.v.shell_error ~= 0 then
				print("Backup failed")
				return
			end

			vim.cmd("edit " .. vim.fn.fnameescape(dir))

			vim.fn.search("\\V" .. target_name, "cw")

			print("Backup created: " .. target_name .. ".bak")
		end, { buffer = true, remap = false, desc = "Netrw: Backup file" })
	end
})
