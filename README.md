
# vim-jumptoline

## Usage

### :JumpToLine

Jump to the line if cursorline matches one of the following:

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
