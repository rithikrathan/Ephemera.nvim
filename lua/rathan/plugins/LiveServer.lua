return {
	{
		'barrett-ruth/live-server.nvim',
		build = 'pnpm add -g live-server',
		cmd = { 'LiveServerStart', 'LiveServerStop' },
		config = true,
		ft = { "javascript", "jsx", "tsx", "typescript", "html", "css" }
	}
}
