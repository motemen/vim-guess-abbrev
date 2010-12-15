gabbrev.vim
===========

DESCRIPTION
-----------

gabbrev.vim expands your input dynamically.

For example, it expands your input `SM` to `\<S[[:alnum:]]*\%([[:alnum:]]\@!\k\)\+M[[:alnum:]]*`
and search over buffers with this pattern, and would eventually suggest `Some::Module` or `SUPER_METHOD`.

SETTING UP
----------

Write in your ftplugin/<var>language</var>.vim

	inoremap <silent> <expr> <C-]> gabbrev#i_start()
	setlocal completefunc=gabbrev#complete " not necessary

Typing uppercase letters and hitting `<C-]>` in insertmode will suggest first match. Next type will start full popup completion.

OPTIONS
-------

### `g:gabbrev#abbrev_ch_pattern`

Default: `'[[:alnum:]]'`

Pattern for characters which compose abbreviation (your input).

### `g:gabbrev#keyword_ch_pattern`

Default: `'\k'`

Pattern for characters which compose expanded word.

HOW THIS WORKS
--------------

When called, gabbrev splits your input by uppercase (`/\u`) characters.

	'FoBB' -> ['Fo', 'B', 'B']

And fill join them by character patterns

	['Fo', 'B', 'B'] -> '\v<Fo[[:alnum:]]*([[:alnum:]]@!\k)+B[[:alnum:]]*([[:alnum:]]@!\k)+B[[:alnum:]]*'

And search with this pattern, which matches 'Foo::Bar::Baz' or 'foo_bar_baz'. (depends on 'iskeyword' and 'ignorecase')

AUTHOR
------

motemen <motemen@gmail.com>
