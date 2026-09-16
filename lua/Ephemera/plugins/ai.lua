return {
	{
		"github/copilot.vim",
		cmd = "Copilot",
		config = function()
			-- Accept suggestion with Alt+i
			vim.keymap.set("i", "<A-i>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				silent = true,
				replace_keycodes = false,
			})

			-- Next suggestion with Alt+l
			vim.keymap.set("i", "<A-l>", "<Plug>(copilot-next)")
		end,
	},
	{
		"ziontee113/ollama.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
		},
		keys = {
			{
				"<leader>ai",
				function() require("ollama").show() end,
				desc = "ollama prompt",
				mode = { "n", "v" },
			},
		},
		opts = {
			model = "qwen2.5-coder-1.5b:latest",
			url = "http://localhost:11434",
		},
	},
}