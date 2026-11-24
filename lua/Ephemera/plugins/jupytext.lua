return {
  "goerz/jupytext.vim",
  lazy = false,
  init = function()
    vim.g.jupytext_fmt = "py:percent"
    vim.g.jupytext_style = "percent"
  end,
}
