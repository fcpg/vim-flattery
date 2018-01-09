Vim-Flattery
=============

> _Flattery will lead you everywhere._

Flattery provides targets for `f`/`t` searches, either as a conveniency
[eg. `fb` searching for `)`, as for text-objects] or creating new target types.

All mappings are configurable.

*Example:*

```
          tl  2tl   3tl     fd    fu  2fu   fgr   fr          fh   fgb fb
          |    |     |      |     |   |     |     |           |    |   |
  let snake_case_ident = foo.camelCaseMember['bar'] . autoload#func(baz)
      |                |                            |                 |
   <Cursor>            fe                          2fd                fz
```

Targets
--------

*a*  
  Jump to the next closing angle bracket, like `f>`.

*b*  
  Jump to the next closing paren, like `f)`.

*c*  
  Jump to the next closing curly brace, like `f}`.

*r*  
  Jump to the next closing square bracket, like `f]`.

*u*  
  Jump to the next uppercase letter.

*l*  
  Jump to the next word limit, ie. the char just after an "alnum-word".
  An alnum-word is defined here as a series of alphanumerics,
  irrespective of the 'iskeyword' or 'isident' options.

*w*  
  Jump to the next alnum-word.
  Useful to move around in, for instance, snake-case identifiers
  like 'did_load_filetypes'.

*z*  
  Jump to the char just before end-of-line.

*d*  
  Jump to the next dot char `.`.

*e*  
  Jump to the next equal sign `=`.

*h*  
  Jump to the next hash char `#`.

*p*  
  Jump to the next pipe char `|`.

*s*  
  Jump to the next slash char `/`.


Pairs
------

Parens, curly braces and brackets (angle & square) usually work in pairs:
by default, Flattery jumps forward to the closing one, and backward to the
opening one. This is entirely configurable; it can be reversed, or set to
always jump to the opening or closing element.


Mappings
---------

In addition to targets, the following mappings are available by default:

- `ff` maps to `F`
- `tt` maps to `T`
- `fv` maps to builtin `f` (so you can hit `fva` to search an `a` char)
- `fg` swaps the opening/closing element for pairs (parens and brackets)
- `fj` repeats the last search
- `fx` goes one char farther, eg. `fxb` jumps just after a closing paren
  (only works for flattery targets)


Settings
---------

Check the [doc](doc/flattery.txt) for the full list of settings.


"Ain't Gonna Need It"
----------------------

It is trivial to replace the simplest targets with maps in your .vimrc,
[eg. `nnoremap fb f)`], and this is how it was initially done by yours truly.
If this is all you will ever need (eg. no new targets, no pair handling),
please do so.


Installation
-------------
Use your favorite method:
*  [Pathogen][1] - git clone https://github.com/fcpg/vim-flattery ~/.vim/bundle/vim-flattery
*  [NeoBundle][2] - NeoBundle 'fcpg/vim-flattery'
*  [Vundle][3] - Plugin 'fcpg/vim-flattery'
*  [Plug][4] - Plug 'fcpg/vim-flattery'
*  manual - copy all files into your ~/.vim directory

License
--------
[Attribution-ShareAlike 4.0 Int.](https://creativecommons.org/licenses/by-sa/4.0/)

[1]: https://github.com/tpope/vim-pathogen
[2]: https://github.com/Shougo/neobundle.vim
[3]: https://github.com/gmarik/vundle
[4]: https://github.com/junegunn/vim-plug
