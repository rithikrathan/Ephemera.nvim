return {
	{
		"github/copilot.vim",
		cmd = "Copilot",
		init = function()
			-- Use the locally installed language server instead of npx (avoids
			-- re-downloading the package on every start after :Copilot upgrade).
			vim.g.copilot_command = "/home/rithik/.local/share/nvim/copilot-language-server/node_modules/@github/copilot-language-server/dist/language-server.js"
		end,
		config = function()
			-- Accept suggestion with Alt+i
			vim.keymap.set("i", "<A-i>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				silent = true,
				replace_keycodes = false,
			})

			-- Next suggestion with <leader>cn
			vim.keymap.set("i", "<leader>cn", "<Plug>(copilot-next)")
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