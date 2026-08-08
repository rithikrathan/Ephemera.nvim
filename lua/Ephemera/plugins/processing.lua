return {
    "sophieforrest/processing.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    ft = "processing",
    config = function()
        vim.g.processing_nvim = {
            default = {
                highlight = {
                    enable = true,
                },
                lsp = {
                    -- The command to use for processing-lsp.
                    -- processing does not bundle their LSP as a separate package, so this requires manual setup.
                    -- Leave as nil if you don't have the LSP installed.
                    cmd = nil,
                    -- Example if installed: cmd = { "processing-lsp" }
                },
            },
        }
    end,
}
