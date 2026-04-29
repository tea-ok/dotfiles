return {
  "mason-org/mason.nvim",
  event = "User FilePost",
  cmd = { "Mason", "MasonInstall", "MasonUpdate" },
  opts = function()
    return require("configs.mason").opts
  end,
  config = function(_, opts)
    require("mason").setup(opts)
    require("configs.mason").install_missing()
  end,
}
