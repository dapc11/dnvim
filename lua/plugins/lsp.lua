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
    opts = {
      adapters = {
        {
          command = "PyDoc",
          get_items = function()
            local function split_by_whitespace(input_str)
              local result = {}
              for match in input_str:gmatch("%S+") do
                table.insert(result, match)
              end
              return result
            end

            local packages = {}
            local cache_file = vim.fn.stdpath("data") .. "/pydoc_cache.txt"

            -- Check if the cache_file already exists, if exists, return cached packages
            if vim.loop.fs_stat(cache_file) then
              return readlines(cache_file)
            end

            local std_packages = vim.fn.systemlist("python3 -c 'help(\"modules\")'")
            -- Filter out the first few lines which are not actual package names.
            for index, value in ipairs(std_packages) do
              if index > 11 and index < #std_packages - 2 then
                for _, package in ipairs(split_by_whitespace(value)) do
                  table.insert(packages, package)
                end
              end
            end

            table.sort(packages)

            -- Cache packages list
            writeLines(packages, cache_file)
            return packages
          end,
          get_content = function(choice)
            return vim.fn.systemlist("python3 -m pydoc " .. choice)
          end,
          get_syntax_info = function()
            return {
              filetype = "pydoc",
              language = "python",
            }
          end,
        },
      },
    },
  },
}
