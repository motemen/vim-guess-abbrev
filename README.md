gabbrev.vim
===========

DESCRIPTION
-----------

gabbrev.vim expands your input dynamically.

For example, it expands `SM` to `\<S\i*\(\i\@!\k\)\+M\i*`
and search over buffers with this pattern, and would eventually suggest `Some::Module`.

SETTING UP
----------

Write in your ftplugin/perl.vim

	inoremap <silent> <expr> <C-]> gabbrev#start()
	setlocal completefunc=gabbrev#complete

Typing uppercase letters and hitting `<C-]>` in insertmode will suggest first match. Next type will start full popup completion.
