" perltest.vim - Perl Testing plugin for Vim
"
" Maintainer:     Rufus Cable <rufus@threebytesfull.com>
" Version:        0.0.13
" Copyright:      (c) 2008-2013 Rufus Cable

if exists('g:perltest_version') || &cp
    finish
endif

" Version number
let g:perltest_version = '0.0.13'

" Check for Vim 7+
if v:version < 700
    echo 'PerlTest '.g:perltest_version.' requires Vim 7.0 or later'
    finish
endif

function! s:SetupPerlTestBuffer(command)
    " buffer contents will be TAP output
    setf TAPVerboseOutput
    " set buffer up as a scratch buffer
    setlocal buftype=nofile bufhidden=hide noswapfile nomodifiable wrap
    if (version >= 703)
        setlocal colorcolumn=""
    endif
    " save test command for subsequent re-runs
    let b:runTestsCommand = a:command
    " pressing 'q' should close and drop this buffer
    nmap <buffer> <silent> q :q<cr>
    " pressing 'r' should re-run the tests in this buffer
    exec 'nmap <buffer> <silent> r :call <SID>RunPerlTests("' . b:runTestsCommand . '")<cr>'
    " pressing '<Leader>F' should jump to the next test failure
    noremap <buffer> <silent> <Leader>F /^not ok<cr>:nohl<cr>
    " run the tests
    call <SID>RunPerlTests(b:runTestsCommand)
endfunction

function! s:RunPerlTests(command)
    " temporarily make buffer modifiable
    setlocal modifiable
    " wipe the buffer clean
    exec ':1,$d'
    " run the tests
    exec a:command
    " skip the 'press enter' bit
    let x = &ruler | let y=&showcmd
    set noruler noshowcmd
    redraw
    let &ruler = x | let &showcmd = y
    " add the help header
    call append(0, ["Press 'r' to re-run tests, 'q' to quit", ''])
    " make buffer read-ony again
    setlocal nomodifiable
endfunction

function! s:PerlTest(testfile)
    exe 'new [PerlTest : ' . a:testfile . ']'
    call <SID>SetupPerlTestBuffer('%! prove -vl -I t/lib --norc --merge ' . a:testfile)
endfunction

function! s:PerlTestMappings()
    noremap <buffer> <Leader>t :!prove -vl --norc --merge %<cr>
    noremap <buffer> <Leader>T :call <SID>PerlTest(bufname('%'))<cr>
    noremap <buffer> <Leader>d :!perl -Ilib -d %<cr>
endfunction

au! FileType perl :call <SID>PerlTestMappings()
