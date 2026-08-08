return {
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local gitignore_cache = {}
            require("oil").setup({

                default_file_explorer = false,

                columns = {
                    "permissions",
                    "size",
                    "icon",
                },
                skip_confirm_for_simple_edits = true,

                win_options = {
                    wrap = false,
                    signcolumn = "no",
                    cursorcolumn = false,
                    foldcolumn = "0",
                    spell = false,
                    list = false,
                    conceallevel = 3,
                    concealcursor = "nvic",
                },

                float = {
                    padding = 2,
                    max_width = 80,
                    max_height = 0,
                    border = "double",
                    win_options = {
                        winblend = 0,
                    },
                },

                keymaps = {
                    ["g?"] = "actions.show_help",
                    ["<CR>"] = "actions.select",
                    ["<C-s>"] = "actions.select_vsplit",
                    ["<C-h>"] = "actions.select_split",
                    ["<C-t>"] = "actions.select_tab",
                    ["<C-p>"] = "actions.preview",
                    ["<Esc>"] = "actions.close",
                    ["<C-l>"] = "actions.refresh",
                    ["-"] = "actions.parent",
                    ["_"] = "actions.open_cwd",
                    ["`"] = "actions.cd",
                    ["~"] = "actions.tcd",
                    ["gs"] = "actions.change_sort",
                    ["gx"] = "actions.open_external",
                    ["g."] = "actions.toggle_hidden",
                    ["<leader>gh"] = function()
                        local bufnr = vim.api.nvim_get_current_buf()
                        vim.b[bufnr].oil_gitignore_hide = not vim.b[bufnr].oil_gitignore_hide
                        gitignore_cache = {}
                        require("oil.actions").refresh.callback()
                    end,
                },
                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name, bufnr)
                        if not vim.b[bufnr].oil_gitignore_hide then
                            return false
                        end
                        local dir = require("oil").get_current_dir(bufnr)
                        if not dir then return false end
                        local key = dir .. "\0" .. name
                        if gitignore_cache[key] ~= nil then
                            return gitignore_cache[key]
                        end
                        local ok, result = pcall(vim.fn.systemlist,
                            "git -C " .. vim.fn.shellescape(dir) .. " check-ignore " .. vim.fn.shellescape(name) .. " 2>/dev/null")
                        local ignored = ok and #result > 0 and result[1] ~= ""
                        gitignore_cache[key] = ignored
                        return ignored
                    end,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                },
            })

            vim.keymap.set("n", "we", require("oil").toggle_float, { desc = "Toggle Oil Floating Window" })
        end,
    },

    {
        'nvim-telescope/telescope.nvim',
        version = false,
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-fzf-native.nvim' },
        config = function()
            local telescope = require('telescope')
            telescope.setup({
                defaults = {
                    initial_mode = 'normal',
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = 'smart_case',
                    },
                },
            })
            telescope.load_extension('fzf')
        end,
    },

    -- Harpoon
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local harpoon = require("harpoon")
            harpoon:setup({})
            local conf = require("telescope.config").values
            local function toggle_telescope(harpoon_files)
                local file_paths = {}
                for _, item in ipairs(harpoon_files.items) do table.insert(file_paths, item.value) end
                require("telescope.pickers").new({}, {
                    prompt_title = "Harpoon",
                    finder = require("telescope.finders").new_table({ results = file_paths }),
                    previewer = conf.file_previewer({}),
                    sorter = conf.generic_sorter({}),
                    initial_mode = "normal",
                }):find()
            end
            vim.keymap.set("n", "<leader>e", function() toggle_telescope(harpoon:list()) end,
                { desc = "Open harpoon window" })
        end
    },

    -- fzf ik I got the telescope like shut the fuck up its my config
    {
        "junegunn/fzf.vim",
        dependencies = { "junegunn/fzf" },
        event = "VeryLazy",
    },

}
