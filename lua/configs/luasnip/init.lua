local M = {}

function M.config()
  local ls = require("luasnip")
  local s = ls.snippet
  local t = ls.text_node
  local i = ls.insert_node
  local c = ls.choice_node

  ls.add_snippets(nil, {
    -- When trying to expand a snippet, luasnip first searches the tables for
    -- each filetype specified in 'filetype' followed by 'all'.
    -- If ie. the filetype is 'lua.c'
    --     - luasnip.lua
    --     - luasnip.c
    --     - luasnip.all
    -- are searched in that order.
    all = {
      s("cve", {
        c(1, {
          t("CVE-"),
          t(""),
        }),
        i(2, "cve-id"),
        t(":"),
        t({ "", "\tmitigation: " }),
        i(3, "mitigation"),
        t({ "", "\tcategory: " }),
        i(4, "category"),
        t({ "", "\trationale_for_category: " }),
        i(5, "rationale"),
        t(""),
        t({ "", "\tsce:" }),
        t({ "", "\t\tsce-id: todo_sce_id" }),
        t({ "", "\t\tstatus: Approved" }),
        t({ "", "\t\texpires: " }),
        i(6, "expires"),
        t({ "", "\t\tplanned_fix: " }),
        i(7, "planned fix"),
        t({ "", "\t\toriginal-sce-id: todo_sce_id" }),
        i(0),
      }),
      s("cvelow", {
        c(1, {
          t("CVE-"),
          t(""),
        }),
        i(2, "cve-id"),
        t(":"),
        t({ "", "\tmitigation: " }),
        i(3, "mitigation"),
      }),
    },
    python = {
      s("#", {
        c(1, {
          t({ "#!/usr/bin/env python3" }),
          t({ "#!/usr/bin/python3" }),
        }),
        c(2, {
          t(""),
          t({ " -B" }),
        }),
        i(0),
      }),
    },
  })
  require("luasnip.loaders.from_vscode").lazy_load()
end

return M
