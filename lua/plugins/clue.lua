return {
  {
    "echasnovski/mini.clue",
    version = false,
    opts = function()
      local miniclue = require("mini.clue")
      return {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          { mode = "n", keys = "d" },
          { mode = "n", keys = "c" },
          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
        },
        window = {
          config = {
            width = "auto",
          },
          delay = 0,
        },
        clues = {
          { mode = "n", keys = "<leader>b", desc = "+buffer" },
          { mode = "n", keys = "<leader>c", desc = "+code" },
          { mode = "n", keys = "<leader>cd", desc = "+debug" },
          { mode = "n", keys = "<leader>cw", desc = "+workspace" },
          { mode = "n", keys = "<leader>d", desc = "+debug" },
          { mode = "n", keys = "<leader>da", desc = "+adapters" },
          { mode = "n", keys = "<leader>f", desc = "+find" },
          { mode = "n", keys = "<leader>g", desc = "+git" },
          { mode = "n", keys = "<leader>l", desc = "+lsp" },
          { mode = "n", keys = "<leader>h", desc = "+hunk" },
          { mode = "n", keys = "<leader>o", desc = "+overseer" },
          { mode = "n", keys = "<leader>t", desc = "+test" },
          { mode = "n", keys = "<leader>s", desc = "+search" },
          { mode = "n", keys = "<leader>sn", desc = "+noice" },
          { mode = "n", keys = "<leader>U", desc = "+ui" },
          { mode = "n", keys = "<leader>x", desc = "+utils" },
          { mode = "n", keys = "<leader>z", desc = "+notes" },
          { mode = "n", keys = "<leader>w", desc = "+window" },
          { mode = "n", keys = "<leader><tab>", desc = "+tabs" },
          { mode = "n", keys = "<leader>q", desc = "+exit" },
          { mode = "n", keys = "gz", desc = "+surround" },
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = "n", keys = "ci", desc = "Change inside" },
          { mode = "n", keys = "cic", desc = "Class" },
          { mode = "n", keys = "cif", desc = "Function" },
          { mode = "n", keys = "cib", desc = "Block" },
          { mode = "n", keys = "ciC", desc = "Comment" },
          { mode = "n", keys = "ca", desc = "Change around" },
          { mode = "n", keys = "cac", desc = "Class" },
          { mode = "n", keys = "caf", desc = "Function" },
          { mode = "n", keys = "cab", desc = "Block" },
          { mode = "n", keys = "caC", desc = "Comment" },
          { mode = "n", keys = "di", desc = "Delete inside" },
          { mode = "n", keys = "dic", desc = "Class" },
          { mode = "n", keys = "dif", desc = "Function" },
          { mode = "n", keys = "dib", desc = "Block" },
          { mode = "n", keys = "diC", desc = "Comment" },
          { mode = "n", keys = "da", desc = "Delete around" },
          { mode = "n", keys = "dac", desc = "Class" },
          { mode = "n", keys = "daf", desc = "Function" },
          { mode = "n", keys = "dab", desc = "Block" },
          { mode = "n", keys = "daC", desc = "Comment" },
        },
      }
    end,
  },
}
