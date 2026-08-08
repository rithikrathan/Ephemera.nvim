vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true
vim.opt.mouse = "a"
vim.opt.wrap = false
vim.opt.timeoutlen = 273
vim.opt.signcolumn = "yes"
vim.opt.laststatus = 3
vim.g.netrw_winsize = 25
vim.g.netrw_banner = 1
vim.g.netrw_localcopydircmd = 'cp -r'
vim.g.netrw_keepdir = true --if false update the currentworkingdirectory everytime you navigate the netrw
vim.opt.expandtab = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.g.have_nerd_font = true
vim.opt.undofile = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.updatetime = 400
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.autoread = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "┊ ", trail = ".", nbsp = "␣" }
vim.opt.cmdheight = 1
vim.opt.guicursor = "n:block,i:hor20,v:block,r:hor50"
-- vim.opt.guicursor = "n:block,i:hor20,v:block,r:hor50"

-- folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.fillchars = {
    foldopen = "▾", -- Symbol for an open fold
    foldclose = "▸", -- Symbol for a closed fold (+)
    foldsep = "┊", -- Symbol for lines within an open fold (|)
    fold = " " -- Filler character for empty space in the fold column
}

function _G.foldText()
    local fs, fe = vim.v.foldstart, vim.v.foldend
    local line = vim.fn.getline(fs)
    local line_count = fe - fs + 1
    local total_lines = vim.api.nvim_buf_line_count(0)
    local percentage = math.floor((line_count / total_lines) * 100)
    return string.format("➤  %s ... %d lines (%d%%)", line, line_count, percentage)
end

_G.create_floating_window = function()
    local width = math.floor(vim.o.columns * 0.80)
    local height = math.floor(vim.o.lines * 0.80)
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor((vim.o.lines - height) / 2)

    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#ff3322' })
    return buf, win
end

-- some symbols for the symbol column
vim.opt.foldtext = "v:lua.foldText()"
vim.fn.sign_define("DiagnosticSignError", { text = "❖", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "⚑", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignHint", { text = "✯", texthl = "DiagnosticSignHint" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "⧐", texthl = "DiagnosticSignInfo" })
