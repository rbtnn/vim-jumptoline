
# vim-jumptoline

## Usage

### :JumpToLine

Jump to the line which matches one of the following:

__C#__
```
main.cs(9,10): error CS1002: ; expected
```

__Python__
```
Traceback (most recent call last):
  File "./prog.py", line 1, in <module>
```

__Ruby__
```
prog.rb:1:in `<main>': undefined local variable or method `aaaa' for main:Object (NameError)
```

__Rust__
```
error: expected expression, found `:`
 --> src\main.rs:7:42
  |
7 |     println!("{:?}", String::from_utf8(x[:n].to_vec()));
  |                                          ^ expected expression
```

__Go__
```
prog.go:1:1: expected 'package', found aaaaaa
```


## License

Distributed under MIT License. See LICENSE.
