
# vim-jumptoline

## Usage

### :JumpToLine

Jump to the line if cursorline matches one of the following:

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

## Concepts

* This plugin does not provide to customize user-settings.
* This plugin provides only one command.

## License

Distributed under MIT License. See LICENSE.
