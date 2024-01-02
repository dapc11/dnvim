-- Improvement:
--  - It uses not only 'ignorecase' but also 'smartcase' unlike
--    default |star|.
--  - It works in visual mode in addition to |Normal| & |Visual|.
--    Search selected text.
--  - "z" prefixed mappings doesn't move the cursor.

return {
  "haya14busa/vim-asterisk",
  lazy = false,
  init = function()
    local map = require("util").map
    map("n", "*", [[<Plug>(asterisk-*)]])
    map("n", "#", [[<Plug>(asterisk-#)]])
    map("n", "g*", [[<Plug>(asterisk-g*)]])
    map("n", "g#", [[<Plug>(asterisk-g#)]])
    map("n", "z*", [[<Plug>(asterisk-z*)]])
    map("n", "gz*", [[<Plug>(asterisk-gz*)]])
    map("n", "z#", [[<Plug>(asterisk-z#)]])
    map("n", "gz#", [[<Plug>(asterisk-gz#)]])
  end,
}
