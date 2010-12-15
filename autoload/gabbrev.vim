" inoremap <silent> <expr> <C-]> gabbrev#i_start()
" setlocal completefunc=gabbrev#complete

function! gabbrev#setup()
    let col = col('.')
    let line = line('.')
    let mode = col == len(getline('.')) ? 'a' : 'i'
    let pat = '\i*\%' . (col + (mode == 'a' ? 1 : 0)) . 'c'
    let word = matchstr(getline('.'), pat)

    return [ col, line, mode, pat, word ]
endfunction

function! gabbrev#expand(default)
    let [ col, line, mode, pat, word ] = gabbrev#setup()

    if (!len(word))
        return
    endif

    let expanded = gabbrev#gabbrev(word)
    if !len(expanded)
        let expanded = word . a:default
        let b:gabbrev_last_expand = ''
    else
        let b:gabbrev_last_expand = expanded
    endif

    execute 'substitute/' . pat . '/\=expanded/'
    call cursor('.', col - len(word) + len(expanded))
endfunction

function! gabbrev#complete(findstart, base)
    let [ col, line, mode, pat, word ] = gabbrev#setup()

    if (a:findstart)
        return len(word) > 0 ? col('.') - len(word) - 1 : -1
    endif

    return gabbrev#gabbrev(a:base, { 'all': 1, 'completefunc': 1 })
endfunction

" TODO customize regex
function! gabbrev#gabbrev(word, ...)
    let option = a:0 ? a:1 : {}

    for p in [ 'all', 'completefunc' ]
        if !exists('option.' . p)
            let option[p] = 0
        endif
    endfor

    " eg. 'AbCD' -> \<Ab\i*\(\i\@!\k\)\+C\i*\(\i\@!\k\)\+D\i*
    let pat = '\<' . join(map(split(a:word, '\u\U*\zs'), "v:val . '\\i*'"), '\(\i\@!\k\)\+')

    let cands = {}

    let bufnrs = range(0, bufnr('$'))
    call remove(bufnrs, bufnr('%'))
    call insert(bufnrs, bufnr('%'))

    for i in bufnrs
        if !bufexists(i) | continue | endif
        if getbufvar(i, '&filetype') != &filetype | continue | endif
        let lines = getbufline(i, 1, '$')
        for j in range(0, len(lines) - 1)
            if i == bufnr('%') && j == line('.')
                continue
            endif

            let m = matchstr(lines[j], pat)
            if !len(m) | continue | endif

            if option.completefunc
                call complete_add(m)
                if complete_check()
                    return
                endif
            elseif option.all
                let cands[m] = get(cands, m, 0) + 1
            else
                return m
            endif
        endfor
    endfor

    if !option.all
        return ''
    end

    let b:gabbrev_candidates = cands
    function! s:cmp(k1, k2)
        return b:gabbrev_candidates[a:k1] < b:gabbrev_candidates[a:k2] ? 1 : -1
    endfunction

    let keys = keys(cands)
    return sort(keys, function('s:cmp'))
endfunction

function! gabbrev#i_start()
    let [ col, line, mode, pat, word ] = gabbrev#setup()

    if pumvisible()
        return "\<C-N>"
    endif

    if exists('b:gabbrev_last_expand') && len(b:gabbrev_last_expand)
                \ && [ line, col - len(b:gabbrev_last_expand) ] == b:gabbrev_complete_pos
        if &completefunc == 'gabbrev#complete'
            return repeat("\<BS>", len(b:gabbrev_last_expand)) . b:gabbrev_last_abbrev . "\<C-X>\<C-U>"
        else
            return "\<C-R>=[complete(b:gabbrev_complete_pos[1], gabbrev#gabbrev(b:gabbrev_last_abbrev, { 'all': 1 })),''][1]\<CR>"
        endif
    else
        let b:gabbrev_last_abbrev = word
        let b:gabbrev_complete_pos = [ line, col - len(word) ]
        return len(word) ? "\<C-O>:call gabbrev#expand('')\<CR>" : ''
    end
endfunction

if exists('g:gabbrev_develop') && g:gabbrev_develop
    augroup gabbrev#develop
        autocmd!
        autocmd CursorHold *
                    \ silent! delfunction gabbrev#i_start
                    \ | augroup gabbrev#develop
                    \ |     execute 'autocmd!'
                    \ | augroup END
    augroup END
endif
