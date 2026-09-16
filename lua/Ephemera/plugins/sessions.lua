return {
	{
		"rmagatti/auto-session",
		lazy = false,

		opts = {
			auto_save = false,
			auto_restore = false,
			auto_create = false,
			bypass_save_filetypes = { "dashboard", "tabBar" },
			suppressed_dirs = { "~", "/" },
			session_lens = {
				picker = "telescope",
				load_on_setup = true,
			},
		},

		config = function(_, opts)
			vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
			require("auto-session").setup(opts)
		end,
	},
}
