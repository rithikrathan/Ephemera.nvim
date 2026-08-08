-- Insert Mode Cursor Movement (Alt + hjkl)
vim.keymap.set("i", "<A-h>", "<Left>", { desc = "Move cursor left" })
vim.keymap.set("i", "<A-l>", "<Right>", { desc = "Move cursor right" })
vim.keymap.set("i", "<A-j>", "<Down>", { desc = "Move cursor down" })
vim.keymap.set("i", "<A-k>", "<Up>", { desc = "Move cursor up" })

vim.keymap.set("n", "<leader>0", "q:", { desc = "bufferCommand" })
vim.keymap.set("n", "<leader>9", "q/", { desc = "bufferSearch" })

-- some vertical navigation in insert mode
vim.keymap.set("i", "<A-o>", '<Esc>o', { desc = "Insert line below" })
vim.keymap.set("i", "<A-O>", '<Esc>O', { desc = "Insert line above" })

-- Toggle github/copilot.vim plugin
vim.keymap.set("n", "<leader>cp", function()
    -- 0 means disabled, 1 means enabled
    if vim.g.copilot_enabled == 1 or vim.g.copilot_enabled == nil then
        vim.cmd("Copilot disable")
        -- Explicitly set the global var just in case
        vim.g.copilot_enabled = 0
        print("Copilot Sleep Mode ")
    else
        vim.cmd("Copilot enable")
        vim.g.copilot_enabled = 1
        print("Copilot Active ")
    end
end, { desc = "Toggle Copilot (github/copilot.vim)" })

-- treesitter conftext
vim.keymap.set("n", "[c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true, desc = "Treesitter context jump" })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

-- Basic Mappings
vim.keymap.set({ "n", "v", "t", "i" }, "<A-n>", '<CR>', { remap = true, desc = "Enter/confirm" })

-- copy and paste with system clipboard
vim.keymap.set("v", "<leader>y", function() vim.api.nvim_exec('normal! "+y', false) end,
    { remap = true, desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>p", '"+p', { remap = true, desc = "Paste from system clipboard" })

vim.keymap.set("n", "<F8>", ":e!<CR>", { desc = "Reload current file" })

vim.keymap.set("v", ">", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<", "<gv", { desc = "Dedent and reselect" })
vim.keymap.set({ "n", "i" }, "<A-[>", "zt", { desc = "Scroll cursor to top" })
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Netrw file explorer" })
vim.keymap.set({ "v", "i" }, "<leader><Tab>", "<Esc>", { noremap = true, silent = true, desc = "Escape to normal mode" })
vim.keymap.set("t", "<leader><Tab>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Escape terminal to normal" })
vim.keymap.set("n", "<leader>d", "yyp", { desc = "Duplicate current line" })
vim.keymap.set("i", "<leader>tn", "<C-o>", { desc = "Temporary normal mode" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev search (centered)" })
vim.keymap.set("n", "H", "^", { desc = "Go to line start" })
vim.keymap.set("n", "L", "g_", { desc = "Go to line end (non-blank)" })
vim.keymap.set("v", "<leader>dd", "y'>p", { desc = "Duplicate line below" })

-- Wraps
-- vim.keymap.set("v", "<leader>wp", ":s/\\%V.*\\%V/(&)/ | nohl<CR>")
-- vim.keymap.set("v", "<leader>wpp", ":s/\\%V.*\\%V/{&}/ | nohl<CR>")
-- vim.keymap.set("v", "<leader>wqq", ':s/\\%V.*\\%V/"&"/ | nohl<CR>')
-- vim.keymap.set("v", "<leader>wq", ":s/\\%V.*\\%V/'&'/ | nohl<CR>")
-- vim.keymap.set("v", "<leader>wb", ":s/\\%V.*\\%V/`&`/ | nohl<CR>")

-- Misc Insert helpers
vim.keymap.set("i", "<leader>fjk", "<><left>", { desc = "Wrap with <>" })
vim.keymap.set("n", "ct", 'vitc', { desc = "Change inside tag" })
vim.keymap.set("i", "<A-=>", ' := ', { desc = "Insert := " })
vim.keymap.set("n", "vt", 'vit', { desc = "Visual select tag content" })

-- Splits & Windows
vim.keymap.set("n", "<leader>h", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<A-h>", "<C-w><C-h>", { desc = "Move to left window" })
vim.keymap.set("n", "<A-l>", "<C-w><C-l>", { desc = "Move to right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move to window above" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase split height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease split height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease split width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase split width" })

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
end, { desc = "Create new file" })

vim.keymap.set('n', '<leader>x', function() os.execute('xdg-open ' .. vim.fn.expand('%:p:h')) end,
    { desc = "Open current dir in file manager" })

vim.keymap.set('n', '<leader>xx', function()
    local app = vim.fn.input("Open with: ")
    if app ~= "" then os.execute(app .. " " .. vim.fn.shellescape(vim.fn.expand('%:p')) .. " &") end
end, { desc = "Open current file with app" })

-- vim.opt.path:append("**")
-- vim.opt.wildmenu = true
-- vim.keymap.set("n", "<leader>pf", ":find *")
-- vim.keymap.set("n", "<leader>fb", ":ls<CR>:b<Space>")
--
-- vim.keymap.set("n", "<leader>ff", function()
--     local path = vim.fn.input("Find file: ", "", "file")
--     if path ~= "" then vim.cmd("edit " .. path) end
-- end)

vim.keymap.set("n", "<leader>fw", function()
    local pattern = vim.fn.input("Grep > ")
    if pattern ~= "" then
        vim.cmd("grep -rn " .. pattern .. " ."); vim.cmd("copen")
    end
end, { desc = "Grep pattern in quickfix" })

-- Replace Word
vim.keymap.set("n", "<leader>rw", function()
    local word = vim.fn.expand("<cword>")
    local replacement = vim.fn.input("Replace '" .. word .. "' with: ")
    if replacement ~= "" then vim.cmd("%s/\\<" .. word .. "\\>/" .. replacement .. "/gc") end
end, { desc = "Replace word globally" })

-- Floating Terminal
vim.keymap.set('n', '<leader>t', function()
    local file_dir = vim.fn.expand('%:p:h')
    local buf, win = _G.create_floating_window()
    vim.keymap.set({ "n", "t" }, "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    vim.fn.termopen(vim.o.shell, { cwd = file_dir })
    vim.cmd('startinsert')
end, { desc = "Open floating terminal" })

-- Make Run
vim.keymap.set("n", "<leader>r", function()
    local arg = vim.fn.input("Arg: ")
    local buf, win = _G.create_floating_window()
    vim.keymap.set("t", "<esc>", function() vim.api.nvim_win_close(win, true) end, { buffer = buf })
    local job = vim.fn.termopen(vim.o.shell)
    vim.fn.chansend(job, "make run " .. arg .. "\n")
    vim.cmd("startinsert")
end, { desc = "Run make with args" })

--LSP-zero keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    desc = "LSP actions",
    callback = function(event)
        local opts = { buffer = event.buf }
        -- > change these in the future
        vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover({border = 'rounded'})<cr>",
            { desc = "LSP hover", buffer = event.buf })
        vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>",
            { desc = "LSP definition", buffer = event.buf })
        vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>",
            { desc = "LSP declaration", buffer = event.buf })
        vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>",
            { desc = "LSP implementation", buffer = event.buf })
        vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>",
            { desc = "LSP type definition", buffer = event.buf })
        vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>",
            { desc = "LSP references", buffer = event.buf })
        vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>",
            { desc = "LSP signature help", buffer = event.buf })
        vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "LSP rename", buffer = event.buf })
        vim.keymap.set({ "n","i", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
            { desc = "LSP format", buffer = event.buf })
        vim.keymap.set({ "n","i", "x" }, "<A-f>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>",
            { desc = "LSP format", buffer = event.buf })
        vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>",
            { desc = "LSP code action", buffer = event.buf })
    end,
})

-- find files and dirs
vim.keymap.set('n', '<leader>jdf', function()
    vim.cmd("Files")
end, { desc = "Fzf files (lf)" })

--Harpoon with telescope setup and keymaps
local harpoon = require("harpoon")

vim.keymap.set("n", "<leader>a", function()
    harpoon:list():add()
end, { desc = "Harpoon add file" })
vim.keymap.set("n", "<leader>s", function()
    harpoon:list():remove()
end, { desc = "Harpoon remove file" })
vim.keymap.set("n", "<leader>1", function()
    harpoon:list():select(1)
end, { desc = "Harpoon goto 1" })
vim.keymap.set("n", "<leader>2", function()
    harpoon:list():select(2)
end, { desc = "Harpoon goto 2" })
vim.keymap.set("n", "<leader>3", function()
    harpoon:list():select(3)
end, { desc = "Harpoon goto 3" })
vim.keymap.set("n", "<leader>4", function()
    harpoon:list():select(4)
end, { desc = "Harpoon goto 4" })
vim.keymap.set("n", "<A-[>", function()
    harpoon:list():prev()
end, { desc = "Harpoon prev file" })
vim.keymap.set("n", "<A-]>", function()
    harpoon:list():next()
end, { desc = "Harpoon next file" })

--Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fgi", builtin.git_files, { desc = "Telescope git file search" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<leader>fg*", function()
    builtin.grep_string({ search = vim.fn.expand("<cword>") })
end, { desc = "Telescope grep word under cursor" })

vim.keymap.set({ "n", "v" }, "<leader>va", vim.lsp.buf.code_action, { desc = "LSP code actions" })

vim.keymap.set("n", "<leader>gr", function()
    vim.ui.input({ prompt = "Grep > " }, function(search)
        if search and search ~= "" then builtin.grep_string({ search = search }) end
    end)
end, { desc = "Telescope grep" })

vim.keymap.set("n", "<leader>gq", function()
    vim.ui.input({ prompt = "Grep > " }, function(search)
        if search and search ~= "" then
            require("telescope.builtin").grep_string({
                search = search,
                attach_mappings = function(_, map)
                    map("i", "<CR>", function(prompt_bufnr)
                        require("telescope.actions").send_to_qflist(prompt_bufnr)
                        require("telescope.actions").open_qflist(prompt_bufnr)
                    end)
                    return true
                end,
            })
        end
    end)
end, { desc = "Grep → quickfix" })



--Plugin specific keymaps
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open lazygit" })
vim.keymap.set("n", "<leader>gg", vim.cmd.GitGutterToggle, { desc = "Toggle GitGutter" })
vim.keymap.set("n", "<leader>gt", "<cmd>GitGutterLineHighlightsToggle | GitGutterLineNrHighlightsToggle<CR>",
    { desc = "Toggle git line highlights" })
vim.keymap.set("n", "<leader>tt", "<cmd>sp | term<CR>", { desc = "Open terminal in split" })

-- Relative path copy of a buffer
vim.keymap.set('n', '<C-P>', function()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then return end
    local rel = vim.fn.fnamemodify(path, ':.')
    print(rel)
    vim.fn.setreg('+', vim.fn.shellescape(rel))
end, { desc = "Copy relative file path" })

vim.keymap.set('n', '<leader>X', function()
    local dir = vim.fn.expand('%:p:h')      -- directory of current file
    local app = vim.fn.input("Open with: ") -- prompt for application
    if app ~= "" then
        os.execute(vim.fn.shellescape(app) .. " " .. vim.fn.shellescape(dir) .. " &")
    end
end, { desc = 'Open current directory with custom application' })

-- toggle boolean and inverses
local function toggle_logic()
    local toggle_map = {
        -- Logic & Booleans
        ["true"] = "false",
        ["0"] = "1",
        ["True"] = "False",
        ["Output"] = "Input",
        ["output"] = "input",
        ["OUTPUT"] = "INPUT",
        ["TRUE"] = "FALSE",
        ["yes"] = "no",
        ["Yes"] = "No",
        ["YES"] = "NO",
        ["on"] = "off",
        ["On"] = "Off",
        ["ON"] = "OFF",

        -- Comparisons & Operators
        ["=="] = "!=",
        ["==="] = "!==",
        ["&&"] = "||",
        ["and"] = "or",
        [">"] = "<",
        [">="] = "<=",
        ["+"] = "-",
        ["++"] = "--",
        ["+="] = "-=",

        -- Visibility & Access
        ["public"] = "private",
        ["protected"] = "private",
        ["static"] = "dynamic",
        ["const"] = "let",
        ["readonly"] = "readwrite",

        -- State & Actions
        ["enable"] = "disable",
        ["enabled"] = "disabled",
        ["start"] = "stop",
        ["open"] = "close",
        ["opened"] = "closed",
        ["show"] = "hide",
        ["visible"] = "hidden",
        ["valid"] = "invalid",
        ["success"] = "failure",
        ["attach"] = "detach",
        ["lock"] = "unlock",
        ["bind"] = "unbind",

        -- Directions & UI Layout
        ["top"] = "bottom",
        ["left"] = "right",
        ["up"] = "down",
        ["high"] = "low",
        ["height"] = "width",
        ["inner"] = "outer",
        ["inside"] = "outside",
        ["min"] = "max",
        ["minimum"] = "maximum",
        ["horizontal"] = "vertical",
        ["row"] = "column",
        ["inline"] = "block",

        -- Flex & Grid
        ["flex"] = "grid",
        ["around"] = "between",
        ["relative"] = "absolute",

        -- Order & Position
        ["first"] = "last",
        ["prev"] = "next",
        ["previous"] = "next",
        ["head"] = "tail",
        ["push"] = "pop",
        ["shift"] = "unshift",

        -- HTTP & DevOps
        ["get"] = "post",
        ["put"] = "delete",
        ["master"] = "main",
        ["stage"] = "unstage",
        ["pull"] = "push",
        ["define"] = "undefine",
    }

    local lookup = {}
    for k, v in pairs(toggle_map) do
        lookup[k] = v
        lookup[v] = k
    end

    -- Use <cWORD> to get the full string including symbols
    local full_word = vim.fn.expand("<cWORD>")

    -- This pattern splits the string into: [Leading Symbols][The Word][Trailing Symbols]
    -- %W* = Non-word characters (brackets, dots, etc.)
    -- [%w_!=<>%&%|%+%-%*%/^%%#]+ = The "Core" (letters, numbers, and common operators)
    local lead, core, trail = full_word:match("^(%W*)([%w_!=<>%&%|%+%-%*%/^%%#]+)(%W*)$")

    if core and lookup[core] then
        local inverse = lookup[core]
        -- Reassemble the word with its original surrounding characters
        local replacement = lead .. inverse .. trail

        -- Use 'set_current_line' for a surgical strike that won't trigger unwanted motions
        local line = vim.api.nvim_get_current_line()
        local col = vim.api.nvim_win_get_cursor(0)[2]

        -- Replace the <cWORD> at the cursor position
        -- We use vim.fn.setline to make sure undo history is preserved nicely
        vim.cmd("normal! ciW" .. replacement)
    else
        print("No toggle found for core: " .. (core or "nil"))
    end
end

vim.keymap.set("n", "<leader>i", toggle_logic, { desc = "Smart Toggle Inverse" })

-- Toggle Read Mode
vim.keymap.set("n", "<A-z>", function()
  require("Ephemera.custom.readMode").toggle()
end, { desc = "Toggle Read Mode" })

-- testing new keymaps
vim.keymap.set("n", "]]]", function()
    print(vim.fn.expand('%:p:h'))
end, { desc = "Print current file directory" })

-- Telescope keymaps search
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope search keymaps" })

-- Scratchpad
vim.keymap.set("n", "<leader>ss", function() require("Ephemera.custom.scratchpad").open() end,
    { desc = "Scratchpad open" })
vim.keymap.set("n", "<leader>sq", function() require("Ephemera.custom.scratchpad").close() end,
    { desc = "Scratchpad close" })
vim.keymap.set("n", "<leader>sp", function() require("Ephemera.custom.scratchpad").clone() end,
    { desc = "Scratchpad clone" })
vim.keymap.set("n", "<leader>sy", function() require("Ephemera.custom.scratchpad").yank() end,
    { desc = "Scratchpad yank" })

-- Insert banner
vim.keymap.set('n', '<leader>b', function()
  local cs = vim.bo.commentstring ~= '' and vim.bo.commentstring or '# %s'
  local text = vim.fn.input('Banner: ')
  if text == '' then return end
  local banner = ('=-=-=-=-=-=-=-= [ %s ] =-=-=-=-=-=-=-='):format(text:upper())
  vim.fn.append(vim.fn.line('.'), (cs:gsub('%%s', banner)))

end, { desc = 'Insert banner below cursor' })

vim.keymap.set("n", "<Esc>", function()
  local qf_win = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win ~= 0 then
    vim.cmd("cclose")
  else
    vim.cmd("nohlsearch")
  end
end, { desc = "Close qf or clear search highlight" })

vim.keymap.set("n", "<leader>qf", function()
  local qf_win = vim.fn.getqflist({ winid = 0 }).winid
  if qf_win ~= 0 then vim.cmd("cclose") else vim.cmd("copen") end
end, { desc = "Toggle quickfix list" })
