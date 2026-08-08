return {
    {
        "lukas-reineke/indent-blankline.nvim",
        mwin = "ibl", -- Tells lizy.nvim to use the 'ibl' module for the default setup
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            -- Core indentation settings
            indent = {
                char = "┊", -- Options: "│", "┃", "┆", "┊", ""
                tab_char = "┊",
            },

            -- Highlights the block your cursor is currently inside
            scope = {
                enabled = true,
                show_start = false,
                show_end = false,
                highlight = { "IblScope" },
            },

            -- Keeps the plugin from cluttering non-code windows
            exclude = {
                filetypes = {
                    "help",
                    "alpha",
                    "dashboard",
                    "neo-tree",
                    "Trouble",
                    "lazy",
                    "mason",
                    "notify",
                    "toggleterm",
                },
                buftypes = { "terminal", "nofile" },
            },

            -- Clean up trailing whitespace lines
            whitespace = {
                remove_blankline_trail = true,
            },
        },

        config = function(_, opts)
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#696969" })
            vim.api.nvim_set_hl(0, "IblScope", { fg = "#e6b499" })
            require("ibl").setup(opts)
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = false,
    }, -- devicons

    -- show devicons in netrw
    {
        "prichrd/netrw.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("netrw").setup({})
        end
    },

    -- Live server
    {
        'barrett-ruth/live-server.nvim',
        build = 'pnpm add -g live-server',
        cmd = { 'LiveServerStart', 'LiveServerStop' },
        -- This defines the "basic" setup the new version wants
        init = function()
            vim.g.live_server = {}
        end,
        -- config = true is removed because it triggers the warning
        ft = { "javascript", "jsx", "tsx", "typescript", "html", "css" }
    },

    -- TODO: better quick fix list??? idk how to use this
    {
        "stevearc/quicker.nvim",
        config = function()
            require("quicker").setup({
                -- Local options to set for quickfix
                opts = {
                    buflisted = false,
                    number = false,
                    relativenumber = false,
                    signcolumn = "auto",
                    winfixheight = true,
                    wrap = false,
                },
                -- Set to false to disable the default options in `opts`
                use_default_opts = true,
                -- Keymaps to set for the quickfix buffer
                keys = {
                    { ">", "<cmd>lua require('quicker').expand()<CR>", desc = "Expand quickfix content" },
                },
                -- Callback function to run any custom logic or keymaps for the quickfix buffer
                on_qf = function(bufnr) end,
                edit = {
                    -- Enable editing the quickfix like a normal buffer
                    enabled = true,
                    -- Set to true to write buffers after applying edits.
                    -- Set to "unmodified" to only write unmodified buffers.
                    autosave = "unmodified",
                },
                -- Keep the cursor to the right of the filename and lnum columns
                constrain_cursor = true,
                highlight = {
                    -- Use treesitter highlighting
                    treesitter = true,
                    -- Use LSP semantic token highlighting
                    lsp = true,
                    -- Load the referenced buffers to apply more accurate highlights (may be slow)
                    load_buffers = false,
                },
                follow = {
                    enabled = true,
                },
                -- Map of quickfix item type to icon
                type_icons = {
                    E = "󰅚 ",
                    W = "󰀪 ",
                    I = " ",
                    N = " ",
                    H = " ",
                },
                -- Border characters
                borders = {
                    vert = "┃",
                    -- Strong headers separate results from different files
                    strong_header = "━",
                    strong_cross = "╋",
                    strong_end = "┫",
                    -- Soft headers separate results within the same file
                    soft_header = "╌",
                    soft_cross = "╂",
                    soft_end = "┨",
                },
                -- How to trim the leading whitespace from results. Can be 'all', 'common', or false
                trim_leading_whitespace = "common",
                -- Maximum width of the filename column
                max_filename_width = function()
                    return math.floor(math.min(95, vim.o.columns / 2))
                end,
                -- How far the header should extend to the right
                header_length = function(type, start_col)
                    return vim.o.columns - start_col
                end,
            })
        end

    },

    -- gives the discord "playing" thing
    {
        'vyfor/cord.nvim',
        build = ':Cord update',
    },

    -- screenkey
    {
        "NStefan002/screenkey.nvim",
        lazy = false,
        version = "*",
        config = function()
            require("screenkey").setup({
                compress_after = 3,
                clear_after = 2,
                win_opts = {
                    row = vim.o.lines - vim.o.cmdheight - 1,
                    col = vim.o.columns - 1,
                    relative = "editor",
                    anchor = "SE",
                    width = 20,
                    height = 1,
                    border = "single",
                    title = "Keylog",
                    title_pos = "center",
                    style = "minimal",
                    focusable = false,
                    noautocmd = true,
                },
            })
        end,
    },
    {
        "rcarriga/nvim-notify",
        keys = {
            {
                "<leader>un",
                function()
                    require("notify").dismiss({ silent = true, pending = true })
                end,
                desc = "Dismiss All Notifications",
            },
        },
        opts = {
            -- How long the notification stays on screen (in ms)
            timeout = 2000,

            -- Animation style: "fade", "slide", "fade_in_slide_out", "static"
            stages = "fade_in_slide_out",

            -- Transparency (0 is opaque, 100 is fully transparent)
            background_colour = "#000000",

            max_width = 50,

            icons = {
                ERROR = "",
                WARN = "",
                INFO = "",
                DEBUG = "",
                TRACE = "✎",
            },
        },
        config = function(_, opts)
            local notify = require("notify")
            notify.setup(opts)

            -- This line makes nvim-notify the default for all Neovim messages
            vim.notify = notify
        end,
    },

    --camaflage
    {
        'zeybek/camouflage.nvim',
        event = 'VeryLazy',
        opts = {
            enabled = true,
            auto_enable = true,
            style = 'text',
            mask_char = '',
            debounce_ms = 150,
            max_lines = 5000,

            reveal = {
                follow_cursor = false,
            },

            yank = {
                confirm = true,
                auto_clear_seconds = 30,
            },

            integrations = {
                telescope = true,
                cmp = { disable_in_masked = true },
            },

            pwned = {
                enabled = false,
            }
        },

        keys = {
            { '<leader>ct', '<cmd>CamouflageToggle<cr>', desc = 'Toggle Camouflage' },
            { '<leader>cr', '<cmd>CamouflageReveal<cr>', desc = 'Reveal Line' },
            { '<leader>cy', '<cmd>CamouflageYank<cr>',   desc = 'Yank Value' },
        }
    },

    {
        "zion-off/mole.nvim",
        event = "VeryLazy",
        dependencies = { "MunifTanjim/nui.nvim" },
        opts = {},
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
        },
        keys = {
            {
                "<leader>?",
                function()
                    require("which-key").show({ global = false })
                end,
                desc = "Buffer Local Keymaps (which-key)",
            },
        },
    },
    {
        "shortcuts/no-neck-pain.nvim",
        version = "*",
        config = function()
            require("no-neck-pain").setup({
                width = 100, -- total centered width (adjust this)
            })
        end
    },

    -- Marks
    {
        "chentoast/marks.nvim",
        event = "VeryLazy",
        config = true,
        keys = {
            { "m/", "<cmd>MarksListAll<cr>", desc = "List all marks" },
        },
    },

    -- Registers
    -- {
    --     "tversteeg/registers.nvim",
    --     event = "VeryLazy",
    --     config = true,
    -- },
}
