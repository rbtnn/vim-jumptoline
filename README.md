
# vim-jumptoline

## Usage

### :JumpToLine

Jump to the line which matches one of the following:

```C#:
main.cs(9,10): error CS1002: ; expected
```

```Python:
Traceback (most recent call last):
  File "./prog.py", line 1, in <module>
```

```Ruby:
prog.rb:1:in `<main>': undefined local variable or method `aaaa' for main:Object (NameError)
```

```Rust:
error: expected expression, found `:`
 --> src\main.rs:7:42
  |
7 |     println!("{:?}", String::from_utf8(x[:n].to_vec()));
  |                                          ^ expected expression
```


## License

Distributed under MIT License. See LICENSE.
