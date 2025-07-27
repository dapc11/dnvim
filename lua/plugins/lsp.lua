local function readlines(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end

  local lines = {}

  for line in io.lines(path) do
    table.insert(lines, line)
  end

  file:close()
  return lines
end

local function writeLines(packages, path)
  local file = io.open(path, "w")
  if not file then
    return nil
  end
  for _, package in ipairs(packages) do
    file:write(package .. "\n")
  end
  file:close()
end

return {
  { "williamboman/mason.nvim", opts = {} },
  { "mfussenegger/nvim-jdtls", ft = "java" },
  {
    "rafaelsq/nvim-goc.lua",
    ft = "go",
    opts = { verticalSplit = false },
    config = function(_, opts)
      require("nvim-goc").setup(opts)
    end,
  },
  {
    "fredrikaverpil/godoc.nvim",
    event = lazyfile,
    version = "2.x",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
