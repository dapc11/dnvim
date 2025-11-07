" Fallback diff syntax file for vim-fugitive
" This ensures diff syntax is available when fugitive needs it

if exists("b:current_syntax")
  finish
endif

" Basic diff syntax highlighting
syntax match diffRemoved "^-.*"
syntax match diffAdded "^+.*"
syntax match diffChanged "^!.*"
syntax match diffSubname "^@@.*@@"
syntax match diffLine "^[0-9,]*[acd][0-9,]*$"
syntax match diffComment "^#.*"

" Link to standard highlight groups
highlight link diffRemoved Special
highlight link diffAdded Identifier
highlight link diffChanged PreProc
highlight link diffSubname Statement
highlight link diffLine LineNr
highlight link diffComment Comment

let b:current_syntax = "diff"

