local utils = require("core.utils")

utils.disabled_builtins()

utils.bootstrap()

utils.impatient()

package.path = package.path .. ";" .. os.getenv("HOME") .. "/.config/nvim/lua/configs/lsp/?/init.lua"

-- Disable plugins
_G.plugins = {}
_G.plugins.hop = true

local sources = {
  "core.globals",
  "core.plugins",
  "core.options",
  "core.autocommands",
  "core.keymaps",
  "core.custom-theme",
}

for _, source in ipairs(sources) do
  local ok, err_msg = pcall(require, source)
  if not ok then
    error("Failed to load " .. source .. "\n\n" .. err_msg)
  end
end

map("n", "<", "]", { noremap = false })
map("o", "<", "]", { noremap = false })
map("x", "<", "]", { noremap = false })
map("n", ">", "[", { noremap = false })
map("o", ">", "[", { noremap = false })
map("x", ">", "[", { noremap = false })

vim.cmd([[
" using range-aware function
function! QFdelete(bufnr) range
    " get current qflist
    let l:qfl = getqflist()
    " no need for filter() and such; just drop the items in range
    call remove(l:qfl, a:firstline - 1, a:lastline - 1)
    " replace items in the current list, do not make a new copy of it;
    " this also preserves the list title
    call setqflist([], 'r', {'items': l:qfl})
    " restore current line
    call setpos('.', [a:bufnr, a:firstline, 1, 0])
    call cursor(a:firstline, 1)
endfunction

" using buffer-local mappings
" note: still have to check &bt value to filter out `:e quickfix` and such
augroup QFList | au!
    autocmd BufWinEnter quickfix if &bt ==# 'quickfix'
    autocmd BufWinEnter quickfix    nnoremap <silent><buffer>dd :call QFdelete(bufnr())<CR>
    autocmd BufWinEnter quickfix    vnoremap <silent><buffer>d  :call QFdelete(bufnr())<CR>
    autocmd BufWinEnter quickfix endif
augroup end
]])

utils.compiled()
