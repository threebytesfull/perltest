" Vim syntax file
" Language:    Verbose TAP Output
" Maintainer:  Rufus Cable <rufus@threebytesfull.com>
" Remark:      Simple syntax highlighting for TAP output
" License:
" Copyright (c) 2008 Rufus Cable

if exists("b:current_syntax")
  finish
endif

syn match tapTestDiag /^#.*/
syn match tapTestTime /^\[\d\d:\d\d:\d\d\].*/ contains=tapTestFile
syn match tapTestFile /\w\+\/[^. ]*/ contained
syn match tapTestFileWithDot /\w\+\/[^ ]*/ contained

syn match tapTestPlan /^\d\+\.\.\d\+$/

" tapTest is a line like 'ok 1', 'not ok 2', 'ok 3 - xxxx'
syn match tapTest /^\(not \)\?ok \d\+.*/ contains=tapTestStatusOK,tapTestStatusNotOK,tapTestLine

" tapTestLine is the line without the ok/not ok status - i.e. number and
" optional message
syn match tapTestLine /\d\+\( .*\|$\)/ contains=tapTestNumber,tapTestLoadMessage contained

" turn ok/not ok messages green/red respectively
syn match tapTestStatusOK /ok/ contained
syn match tapTestStatusNotOK /not ok/ contained

" look behind so "ok 123" and "not ok 124" match test number
syn match tapTestNumber /\(ok \)\@<=\d\d*/ contained
syn match tapTestLoadMessage /\*\*\*.*\*\*\*/ contained contains=tapTestThreeStars,tapTestFileWithDot
syn match tapTestThreeStars /\*\*\*/ contained

syn region tapTestRegion start=/^\(not \)\?ok.*$/me=e+1 end=/^\(\(not \)\?ok\|# Looks like you planned \|All tests successful\|Bailout called\)/me=s-1 fold transparent excludenl
syn region tapTestResultsRegion start=/^\(# Looks like you planned \|All tests successful\|Bailout called\)/ end=/$/

set foldtext=TAPTestLine_foldtext()
function! TAPTestLine_foldtext()
    let line = getline(v:foldstart)
    let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
    return sub
endfunction

set foldminlines=5
set foldcolumn=2
set foldenable
set foldmethod=syntax
syn sync fromstart

if !exists("did_tapverboseoutput_syntax_inits")
  let did_tapverboseoutput_syntax_inits = 1

  hi      tapTestStatusOK    term=bold    ctermfg=green  guifg=Green
  hi      tapTestStatusNotOK term=reverse ctermbg=red    guibg=Red
  hi      tapTestTime        term=bold    ctermfg=blue   guifg=Blue
  hi      tapTestFile        term=reverse ctermbg=yellow ctermfg=black guibg=Yellow guifg=Black
  hi      tapTestLoadedFile  term=bold    ctermfg=black  ctermbg=cyan guifg=Black guibg=Cyan
  hi      tapTestThreeStars  term=reverse ctermfg=blue   guifg=Blue
  hi      tapTestPlan        term=bold    ctermfg=yellow guifg=Yellow

  hi link tapTestFileWithDot tapTestLoadedFile
  hi link tapTestNumber      Number
  hi link tapTestDiag        Comment

  hi tapTestRegion ctermbg=green
  hi tapTestResultsRegion ctermbg=red
endif

let b:current_syntax="tapVerboseOutput"
