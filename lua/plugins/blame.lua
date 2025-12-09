return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    keys = {
      { "<leader>gb", "<cmd>BlameToggle<CR>", desc = "Blame" },
    },
    config = function()
      local function get_gerrit_url(commit_hash)
        local gerrit_url = os.getenv("GERRIT_URL")
        if not gerrit_url then return nil end

        local remote_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
        local change_id = vim.fn.system("git log --format=%B -n 1 " ..
          commit_hash .. " | grep -o 'Change-Id: I[a-f0-9]*' | sed 's/Change-Id: //'"):gsub("\n", "")

        if change_id == "" then return nil end

        local project_path = remote_url:match("/([^/]+/[^/]+/[^/]+)%.git") or remote_url:match("/a/(.+)%.git") or
            remote_url:match("/a/(.+)$")
        local api_url = gerrit_url .. "/a/changes/?q=change:" .. change_id .. "+project:" .. project_path
        local response = vim.fn.system("curl -s --netrc '" .. api_url .. "'")
        local change_num = response:gsub("^[^%[]*", ""):match('"_number":(%d+)')

        return change_num and gerrit_url .. "/c/" .. project_path .. "/+/" .. change_num
      end

      local function get_github_url(commit_hash, remote_url)
        local repo_path = remote_url:gsub("git@github%.com:", ""):gsub("https://github%.com/", ""):gsub("%.git$", "")
        return "https://github.com/" .. repo_path .. "/commit/" .. commit_hash
      end

      local function open_commit_url(commit_hash)
        local remote_url = vim.fn.system("git config --get remote.origin.url"):gsub("\n", "")
        local url = remote_url:match("gerrit") and get_gerrit_url(commit_hash) or
            remote_url:match("github") and get_github_url(commit_hash, remote_url)

        if url then
          vim.fn.system("xdg-open '" .. url .. "'")
        else
          print("Could not generate URL for commit")
        end
      end

      local function open_jira_from_commit(commit_hash, field_type)
        local commit_msg = vim.fn.system("git log --format=%B -n 1 " .. commit_hash)
        local pattern = field_type == "jira" and "Jira:%s*([A-Z]+-[0-9]+)" or "Requirement:%s*([A-Z]+-[0-9]+)"
        local jira_id = commit_msg:match(pattern)

        if not jira_id then
          print("No " .. field_type .. " ID found in commit")
          return
        end

        local JIRA_URL = os.getenv("JIRA_URL") or ""
        if JIRA_URL == "" then
          print("JIRA_URL environment variable not set")
          return
        end

        vim.fn.jobstart({ "xdg-open", JIRA_URL .. jira_id }, { detach = true })
      end

      local function add_blame_keymaps(bufnr)
        vim.keymap.set("n", "o", function()
          local line = vim.api.nvim_get_current_line()
          local commit_hash = line:match("^([a-f0-9]+)")
          if commit_hash then
            open_commit_url(commit_hash)
          end
        end, { buffer = bufnr, desc = "Open commit in browser" })

        vim.keymap.set("n", "j", function()
          local line = vim.api.nvim_get_current_line()
          local commit_hash = line:match("^([a-f0-9]+)")
          if commit_hash then
            open_jira_from_commit(commit_hash, "jira")
          end
        end, { buffer = bufnr, desc = "Open Jira ticket" })

        vim.keymap.set("n", "r", function()
          local line = vim.api.nvim_get_current_line()
          local commit_hash = line:match("^([a-f0-9]+)")
          if commit_hash then
            open_jira_from_commit(commit_hash, "requirement")
          end
        end, { buffer = bufnr, desc = "Open requirement ticket" })
      end

      require("blame").setup {
        mappings = {
          commit_info = "i",
          stack_push = "n",
          stack_pop = "p",
          show_commit = "<CR>",
          close = { "<esc>", "q" },
        },
      }

      -- Add keymap to blame window when it opens
      vim.api.nvim_create_autocmd("User", {
        pattern = "BlameViewOpened",
        callback = function(event)
          if event.data == "window" then
            vim.schedule(function()
              add_blame_keymaps(vim.api.nvim_get_current_buf())
            end)
          end
        end,
      })

      -- Override commit_info open function
      local original_open = require("blame.commit_info").open
      require("blame.commit_info").open = function(self, commit)
        original_open(self, commit)
        if not self.commit_info_window then return end

        vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat,FloatBorder:FloatBorder",
          { win = self.commit_info_window })
        vim.api.nvim_set_current_win(self.commit_info_window)

        local info_buf = vim.api.nvim_win_get_buf(self.commit_info_window)
        vim.keymap.set("n", "g", function()
          open_commit_url(commit.hash)
        end, { buffer = info_buf, desc = "Open commit in browser" })

        vim.keymap.set("n", "j", function()
          open_jira_from_commit(commit.hash, "jira")
        end, { buffer = info_buf, desc = "Open Jira ticket" })

        vim.keymap.set("n", "r", function()
          open_jira_from_commit(commit.hash, "requirement")
        end, { buffer = info_buf, desc = "Open requirement ticket" })
      end
    end,
  },
}
