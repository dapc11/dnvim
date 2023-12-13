local function all_visible_buffers()
  local bufs = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    bufs[vim.api.nvim_win_get_buf(win)] = true
  end
  return vim.tbl_keys(bufs)
end

return {
  "hrsh7th/nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    "FelipeLema/cmp-async-path",
    {
      "L3MON4D3/LuaSnip",
      lazy = false,
      dependencies = {
        "rafamadriz/friendly-snippets",
        lazy = false,
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
        end,
      },
      opts = {
        history = true,
        delete_check_events = "TextChanged",
      },
    },
  },
  config = function(_, opts)
    local cmp = require("cmp")

    for _, source in ipairs(opts.sources) do
      source.group_index = source.group_index or 1
    end

    cmp.setup.filetype({ "gitcommit" }, {
      sources = cmp.config.sources({
        {
          name = "buffer",
          option = {
            get_bufnrs = all_visible_buffers,
          },
        },
        { name = "luasnip" },
      }),
    })
    cmp.setup(opts)
  end,
  opts = function(_, opts)
    local luasnip = require("luasnip")
    local cmp = require("cmp")

    local has_words_before = function()
      unpack = unpack or table.unpack
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    opts.sources = cmp.config.sources({
      {
        name = "nvim_lsp",
        entry_filter = function(entry, _)
          return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind()
            or require("cmp").lsp.CompletionItemKind.Snippet ~= entry:get_kind()
        end,
      },
      { name = "luasnip" },
      { name = "path" },
      {
        name = "buffer",
        option = {
          indexing_interval = 1000,
          keyword_length = 5,
          get_bufnrs = function()
            local buf = vim.api.nvim_get_current_buf()
            local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
            if byte_size > 1024 * 1024 then -- 1 Megabyte max
              return {}
            end
            return all_visible_buffers()
          end,
        },
      },
    })
    opts.preselect = cmp.PreselectMode.None
    opts.mapping = vim.tbl_extend("force", opts.mapping, {
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<CR>"] = cmp.mapping({
        i = function(fallback)
          if cmp.visible() then
            cmp.confirm()
          else
            fallback()
          end
        end,
        s = cmp.mapping.confirm({ select = true }),
        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
      }),
    })
  end,
}
