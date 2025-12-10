" Bob 2.0 YAML Syntax Highlighting - Simplified
" All keys blue, all values white

if exists("b:current_syntax")
  finish
endif

syntax clear

" YAML comments
syn match bobComment /#.*$/ contains=bobVarRef,bobEnvRef,bobPropertyRef,bobRulesetRef

" Property/variable references (with containedin for higher priority)
syn match bobVarRef /\${var\.[a-zA-Z0-9._-]\+}/ containedin=ALL
syn match bobEnvRef /\${env\.[a-zA-Z0-9._-]\+}/ containedin=ALL
syn match bobPropertyRef /\${[a-zA-Z0-9._-]\+}/ containedin=ALL
syn match bobRulesetRef /\${ruleset\.[a-zA-Z0-9._-]\+}/ containedin=ALL

" Special handling for cmd: sh -c with multi-line quotes
syn region bobCmdShellScript start=/cmd:\s*sh -c\s*'/ end=/'/ contains=bobVarRef,bobEnvRef,bobPropertyRef,bobRulesetRef
syn region bobCmdShellScriptDouble start=/cmd:\s*sh -c\s*"/ end=/"/ contains=bobVarRef,bobEnvRef,bobPropertyRef,bobRulesetRef

" Multi-line quoted strings
syn region bobQuotedString start=/"/ end=/"/ contains=bobVarRef,bobEnvRef,bobPropertyRef,bobRulesetRef
syn region bobSingleQuotedString start=/'/ end=/'/ contains=bobVarRef,bobEnvRef,bobPropertyRef,bobRulesetRef

" Simplified: All keys blue, all values white
syn match bobKey /^\s*-\?\s*[a-zA-Z0-9_-]\+:/
syn match bobValue /:\s*\zs.*$/

" Highlight groups
hi def link bobKey Keyword
hi def link bobValue Normal
hi def link bobQuotedString String
hi def link bobSingleQuotedString String
hi def link bobCmdShellScript Normal
hi def link bobCmdShellScriptDouble Normal
hi def link bobComment Comment
hi def link bobPropertyRef Function
hi def link bobEnvRef Function
hi def link bobVarRef Function
hi def link bobRulesetRef Function

let b:current_syntax = "bob"

" Sync patterns for better parsing
syn sync match bobSync grouphere NONE /^\s*[a-zA-Z0-9_-]\+:/
syn sync match bobSync grouphere NONE /^\s*-\s*task:/
syn sync clear
syn sync minlines=50
