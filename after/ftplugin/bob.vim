" Bob filetype plugin - disable treesitter and force syntax
if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

" Disable treesitter highlighting
if exists(':TSBufDisable')
  TSBufDisable highlight
endif

" Force syntax highlighting
setlocal syntax=bob

" Debug info
echom "Bob filetype loaded for: " . expand('%:t')
