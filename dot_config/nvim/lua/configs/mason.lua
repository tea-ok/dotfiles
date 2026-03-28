pcall(function()
  dofile(vim.g.base46_cache .. "mason")
end)

local M = {}

M.opts = {
  PATH = "skip",
  ui = {
    icons = {
      package_pending = " ",
      package_installed = " ",
      package_uninstalled = " ",
    },
  },
  max_concurrent_installers = 10,
}

M.ensure_installed = {
  "lua-language-server",
  "stylua",
  "html-lsp",
  "css-lsp",
  "typescript-language-server",
  "json-lsp",
  "yaml-language-server",
  "taplo",
  "bash-language-server",
  "marksman",
  "prettier",
  "shfmt",
  "gopls",
  "goimports",
  "gofumpt",
  "python-lsp-server",
  "black",
  "ruff",
  "dockerfile-language-server",
  "docker-compose-language-service",
  "terraform-ls",
}

M.package_requirements = {
  ["html-lsp"] = "npm",
  ["css-lsp"] = "npm",
  ["typescript-language-server"] = "npm",
  ["json-lsp"] = "npm",
  ["yaml-language-server"] = "npm",
  ["bash-language-server"] = "npm",
  ["prettier"] = "npm",
  ["dockerfile-language-server"] = "npm",
  ["docker-compose-language-service"] = "npm",
  ["gopls"] = "go",
  ["goimports"] = "go",
  ["gofumpt"] = "go",
  ["python-lsp-server"] = "python3",
  ["black"] = "python3",
  ["ruff"] = "python3",
}

local function resolve_install_list()
  local installable = {}
  local skipped = {}

  for _, package_name in ipairs(M.ensure_installed) do
    local requirement = M.package_requirements[package_name]
    if requirement and vim.fn.executable(requirement) ~= 1 then
      skipped[requirement] = skipped[requirement] or {}
      table.insert(skipped[requirement], package_name)
    else
      table.insert(installable, package_name)
    end
  end

  return installable, skipped
end

local warned_for_missing_prereqs = false

function M.install_missing()
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local install_list, skipped = resolve_install_list()
  if next(skipped) and not warned_for_missing_prereqs then
    warned_for_missing_prereqs = true
    vim.schedule(function()
      local skipped_chunks = {}
      for requirement, packages in pairs(skipped) do
        table.sort(packages)
        table.insert(skipped_chunks, requirement .. ": " .. table.concat(packages, ", "))
      end
      table.sort(skipped_chunks)

      vim.notify(
        "Mason skipped packages due to missing prerequisites ("
          .. table.concat(skipped_chunks, " | ")
          .. "). Install missing tools and run :MasonInstall to retry.",
        vim.log.levels.WARN
      )
    end)
  end

  local function install_packages()
    for _, package_name in ipairs(install_list) do
      local pkg_ok, pkg = pcall(registry.get_package, package_name)
      if pkg_ok and not pkg:is_installed() then
        pkg:install()
      end
    end
  end

  if registry.refresh then
    local refreshed = pcall(registry.refresh, install_packages)
    if refreshed then
      return
    end
  end

  install_packages()
end

return M
