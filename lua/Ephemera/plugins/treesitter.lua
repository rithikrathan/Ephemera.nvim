local parsers = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
    "python",
    "cpp",
    "java",
    "gdscript",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        opts = {
            ensure_installed = parsers,
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter")
            TS.setup(opts)

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("ephemera_treesitter", { clear = true }),
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(args.match)
                    if not lang then
                        return
                    end
                    pcall(vim.treesitter.start, args.buf)
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })

            local install = vim.tbl_filter(function(lang)
                return not TS.get_installed()[lang]
            end, opts.ensure_installed or {})
            if #install > 0 then
                vim.defer_fn(function()
                    TS.install(install)
                end, 0)
            end
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        lazy = false,
        init = function()
            vim.g.no_plugin_maps = true
        end,
        config = function()
            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")

            require("nvim-treesitter-textobjects").setup({
                select = {
                    lookahead = true,
                },
                move = {
                    set_jumps = true,
                },
            })

            for _, mode in ipairs({ "x", "o" }) do
                vim.keymap.set(mode, "af", function()
                    select.select_textobject("@function.outer", "textobjects")
                end)
                vim.keymap.set(mode, "if", function()
                    select.select_textobject("@function.inner", "textobjects")
                end)
                vim.keymap.set(mode, "ac", function()
                    select.select_textobject("@class.outer", "textobjects")
                end)
                vim.keymap.set(mode, "ic", function()
                    select.select_textobject("@class.inner", "textobjects")
                end)
            end

            for _, mode in ipairs({ "n", "x", "o" }) do
                vim.keymap.set(mode, "]m", function()
                    move.goto_next_start("@function.outer", "textobjects")
                end)
                vim.keymap.set(mode, "[m", function()
                    move.goto_previous_start("@function.outer", "textobjects")
                end)
                vim.keymap.set(mode, "]c", function()
                    move.goto_next_start("@class.outer", "textobjects")
                end)
                vim.keymap.set(mode, "[c", function()
                    move.goto_previous_start("@class.outer", "textobjects")
                end)
            end
        end,
    },
}
