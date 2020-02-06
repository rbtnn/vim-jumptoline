
# vim-jumptoline [![Build Status](https://travis-ci.org/rbtnn/vim-jumptoline.svg?branch=master)](https://travis-ci.org/rbtnn/vim-jumptoline)

This plugin provides to jump to the line if cursorline includes a filename with lnum such as a line of build errors.

![](https://raw.githubusercontent.com/rbtnn/vim-jumptoline/master/jumptoline.gif)

## Concepts

* This plugin supports Vim and Neovim. If your Vim has `+popupwin` feature, use `popup_menu()` instead of `inputlist()`.
* This plugin does not provide to customize user-settings.
* This plugin provides only one command.

## Installation

This is an example of installation using [vim-plug](https://github.com/junegunn/vim-plug).

```
Plug 'rbtnn/vim-jumptoline'
```

## Usage

### :JumpToLine

Jump to the line if cursorline matches one of the following patterns.  
If no match is found on the quickfix window, use the information under the cursor of quickfix.  

You map a key to `:JumpToLine` in your .vimrc, then it's so useful for jumpping.

```
nnoremap <silent><nowait><space>     :<C-u>JumpToLine<cr>
```

## Patterns

__QuickFix on Vim__
```
xxx.vim|1006 col 8| call system(prog)
```

__MSBuild__
```
  C:\Users\rbtnn\Desktop\main.vb(923,21): warning BC42021: ...
```

__VC__
```
  C:\Users\rbtnn\Desktop\main.vb(923): warning BC42021: ...
```

__C#,F#__
```
main.cs(9,10): error CS1002: ; expected
```

__Python__
```
  File "./prog.py", line 1, in <module>
```

__Ruby__
```
prog.rb:1:in `<main>': undefined local variable or method `aaaa' for main:Object (NameError)
```

__Rust__
```
 --> src\main.rs:7:42
```

__Go,gcc,Clang__
```
prog.go:1:1: expected 'package', found aaaaaa
```

## License

Distributed under MIT License. See LICENSE.
