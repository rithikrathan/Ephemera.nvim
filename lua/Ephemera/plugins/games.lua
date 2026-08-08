return {
    { 'ThePrimeagen/vim-be-good' }, -- Game to learn vim
    { "Maelwalser/speed-motion.nvim" },

    {
        "ryansaxe/buffergolf.nvim",
        dependencies = { "nvim-mini/mini.diff" },
        opts = {
            -- Default values shown, all are optional
            disabled_plugins = "auto", -- auto-detect and disable conflicting plugins
            auto_dedent = true,        -- auto-dedent practice buffer for consistent indentation
            keymaps = {
                toggle = "<leader>bg",
                countdown = "<leader>bG",
                golf = {
                    next_hunk = "]h",
                    prev_hunk = "[h",
                    first_hunk = "[H",
                    last_hunk = "]H",
                    toggle_overlay = "<leader>do",
                },
            },
            windows = {
                reference = {
                    position = "right", -- "right", "left", "top", "bottom"
                    size = 50,          -- width for left/right, height for top/bottom
                },
                stats = {
                    position = "top", -- "top" or "bottom"
                    height = 3,
                },
            },
            -- Mode-specific overrides
            typing_mode = {
                disabled_plugins = {
                    matchparen = true,         -- disable match parens in typing mode
                    treesitter_context = true, -- disable context in typing mode
                },
            },
            golf_mode = {
                disabled_plugins = {
                    matchparen = false, -- keep match parens in golf mode
                },
            },
        },
    },

    { 'alanfortlink/blackjack.nvim', requires = { 'nvim-lua/plenary.nvim' },
    },
    { "alec-gibson/nvim-tetris" },
    {
        "sidebar-nvim/sidebar.nvim",
        opts = {
            open = false,
            initial_width = 42,
        },
        config = function()
            local Code_ft = {
                "lua", "python", "javascript", "typescript", "javascriptreact", "typescriptreact",
                "json", "yaml", "toml", "markdown", "html", "css", "scss", "go", "rust",
                "c", "cpp", "ruby", "php", "swift", "kotlin", "scala", "zig", "ziggy"
            }

            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = Code_ft,
                callback = function(args)
                    local buf = args.buf
                    local bufname = vim.api.nvim_buf_get_name(buf)
                    if bufname ~= "" and not vim.bo[buf].bfu_disable then
                        require("sidebar-nvim").open()
                    end
                end,
            })

            vim.api.nvim_create_autocmd("BufWinEnter", {
                pattern = { "startup", "nofile", "help", "peek", "terminal" },
                callback = function()
                    require("sidebar-nvim").close()
                end,
            })

            vim.api.nvim_create_autocmd("VimEnter", {
                callback = function()
                    require("sidebar-nvim").close()
                end,
            })
        end,
    }
}
