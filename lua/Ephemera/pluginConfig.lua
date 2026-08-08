-- lsp configs
local mason = require("mason")
local masonConf = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason.setup({ ui = { border = "rounded" }, registries = { "github:mason-org/mason-registry" } })

-- lsp border thing
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover,
    { border = "rounded" } -- single | double | rounded | solid | shadow
)

-- Global Capabilities
local caps = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities())
vim.lsp.config("*", { capabilities = caps })

-- Mason LSP Config
masonConf.setup({
    ensure_installed = { "clangd", "jdtls", "verible" },

    handlers = {
        -- Default handler: Setup every server Mason finds automatically...
        function(server_name)
            lspconfig[server_name].setup({ capabilities = caps })
        end,

        -- exclude jdtls, we are using another plugin to handle that
        -- bruh
        ["jdtls"] = function() end,

        ["clangd"] = function()
            lspconfig.clangd.setup({
                capabilities = caps,
                cmd = { "clangd", "--compile-commands-dir=" .. vim.loop.cwd() },
                filetypes = { "c", "cpp", "objc", "objcpp", "ino" },
                init_options = { usePlaceholders = true, completeUnimported = true },
            })
        end,

        ["arduino_language_server"] = function()
            lspconfig.arduino_language_server.setup({
                capabilities = caps,
                cmd = {
                    "arduino-language-server",
                    "-clangd", "/home/rathan/.local/share/nvim/mason/bin/clangd",
                    "-clangd", "/usr/bin/clangd",
                    "-cli", "/home/rathan/.local/bin/arduino-cli",
                    "-cli-config", "/home/rathan/.arduino15/arduino-cli.yaml",
                    -- "-fqbn", "esp8266:esp8266:nodemcuv2"
                    "-fqbn", "arduino:avr:uno"
                },
            })
        end,

        ["verible"] = function()
            lspconfig.verible.setup({
                capabilities = caps,
                cmd = { "verible-verilog-ls", "--indentation_spaces=0", "--rules_config_search" },
                filetypes = { "verilog", "systemverilog" },
            })
        end,
    }
})

-- Define the config natively
vim.lsp.config.gdscript = {
    capabilities = caps,
    cmd = vim.lsp.rpc.connect('127.0.0.1', 6005),
    -- if you need it to attach to specific filetypes:
    filetypes = { 'gdscript' }
}
vim.lsp.enable('gdscript')

-- Verilog Auto-format
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.v", "*.sv" },
    callback = function() vim.lsp.buf.format({ async = false }) end,
})

-- completion
local cmp = require("cmp")
local lspkind = require("lspkind")
-- local cmp_autopairs = require("nvim-autopairs.completion.cmp")

vim.g.cmp_ghost = vim.g.cmp_enabled

local function apply_cmp()
    cmp.setup({
        enabled = true,

        snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
        },

        completion = {
            autocomplete = vim.g.cmp_enabled and { cmp.TriggerEvent.TextChanged } or false,
        },
        experimental = {
            ghost_text = vim.g.cmp_ghost,
        },

        window = {
            completion = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:CmpBorder,CursorLine:Visual",
                max_height = 8, -- shows only 6 entries
                max_width = 20, -- shows only 6 entries
            }),
            documentation = cmp.config.window.bordered({
                border = "rounded",
                winhighlight = "Normal:Normal,FloatBorder:CmpBorder,CursorLine:Visual",
                max_height = 14,
                max_width = 69,
            }),
        },

        formatting = {
            format = lspkind.cmp_format({
                -- mode = "text_symbol",
                -- mode = "symbol",
                mode = "text",
                maxwidth = { menu = 50, abbr = 50 },
                ellipsis_char = "...",
                show_labelDetails = false,
            }),
        },

        mapping = cmp.mapping.preset.insert({
            ["<A-k>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
            ["<A-j>"] = cmp.mapping.select_next_item({ behavior = "select" }),
            ["<A-i>"] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Replace }),
            ["<A-;>"] = cmp.mapping.complete(),

            ["<C-u>"] = cmp.mapping.scroll_docs(-4),
            ["<C-d>"] = cmp.mapping.scroll_docs(4),

            ["<A-b>"] = cmp.mapping(function(fallback)
                local entry = cmp.get_selected_entry()
                if entry then
                    cmp.open_docs()
                else
                    fallback()
                end
            end, { "i", "s" }),
        }),

        sources = {
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "verible" },
            { name = "html-css" },
            { name = "luasnip" },
            {
                name = "buffer",
                option = {
                    get_bufnrs = function()
                        return vim.api.nvim_list_bufs()
                    end,
                },
            },
            { name = "rg",   keyword_length = 3 },
            { name = "calc" },
            { name = "spell" },
        },
    })
end

apply_cmp()

-- userdefined command
vim.api.nvim_create_user_command("ToggleCompletion", function()
    vim.g.cmp_enabled = not vim.g.cmp_enabled
    vim.g.cmp_ghost = vim.g.cmp_enabled
    apply_cmp()
end, {})

cmp.setup.filetype("go", {
    preselect = cmp.PreselectMode.None,
    completion = { completeopt = "menu,menuone,noinsert,noselect" },
})

-- cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- treesitter config moved to plugins/treesitter.lua

-- ==========================================================================
-- JDTLS MASTER CONFIGURATION
-- ==========================================================================
vim.filetype.add({ extension = { pde = "java" } })
local java_cmds = vim.api.nvim_create_augroup("java_cmds", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    group = java_cmds,
    callback = function()
        local jdtls = require("jdtls")
        -- A. ROBUST MASON PATHS
        local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
        local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        local config_dir = jdtls_path .. "/config_linux"
        -- B. ROOT DETECTION
        local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
        local root_dir = jdtls.setup.find_root(root_markers)
        if root_dir == "" then
            root_dir = os.getenv("HOME") .. "/.cache/jdtls-sandbox"
        end
        local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
        local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local extendedClientCapabilities = jdtls.extendedClientCapabilities
        extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
        -- C. LIBRARY LOGIC
        local ref_libraries = {}
        local current_file = vim.fn.expand("%:p")
        local file_extension = vim.fn.expand("%:e") -- Get "pde" or "java"
        -- FIX: Check file extension explicitly!
        -- If it's a .pde file, WE MUST LOAD CORE.JAR, no matter what the folder is named.
        local cmd = {
            "java",
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-Xms1g",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher_jar,
            "-configuration", config_dir,
            "-data", workspace_dir,
        }
        local config = {
            cmd = cmd,
            root_dir = root_dir,
            capabilities = capabilities,
            settings = {
                java = {
                    signatureHelp = { enabled = true },
                    project = { referencedLibraries = ref_libraries },
                    configuration = {
                        runtimes = {
                            { name = "JavaSE-17",  path = "/usr/lib/jvm/java-17-openjdk-amd64/", default = true },
                            { name = "JavaSE-1.8", path = "/usr/lib/jvm/java-8-openjdk-amd64/" },
                        },
                    },
                },
            },
            init_options = { extendedClientCapabilities = extendedClientCapabilities },
        }
        jdtls.start_or_attach(config)
    end,
})

-- venn.nvim settings
function _G.Toggle_venn()
    local venn_enabled = vim.inspect(vim.b.venn_enabled)
    print("")
    if venn_enabled == "nil" then
        vim.b.venn_enabled = true
        vim.cmd [[setlocal ve=all]]
        vim.api.nvim_buf_set_keymap(0, "n", "<A-j>", "<C-v>j:VBox<CR>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "<A-k>", "<C-v>k:VBox<CR>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "<A-l>", "<C-v>l:VBox<CR>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "n", "<A-h>", "<C-v>h:VBox<CR>", { noremap = true })
        vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
    else
        vim.cmd [[setlocal ve=]]
        vim.api.nvim_buf_del_keymap(0, "n", "<A-j>")
        vim.api.nvim_buf_del_keymap(0, "n", "<A-k>")
        vim.api.nvim_buf_del_keymap(0, "n", "<A-l>")
        vim.api.nvim_buf_del_keymap(0, "n", "<A-h>")
        vim.api.nvim_buf_del_keymap(0, "v", "f")
        vim.b.venn_enabled = nil
    end
end

vim.api.nvim_set_keymap('n', '<leader>vn', ":lua Toggle_venn()<CR>", { noremap = true })
-- require("bufferline").setup {} -- useless
--
--
