# kakoune-number-comparison

[kakoune](http://kakoune.org) plugin to do number comparison using regex.

## Setup

Add `number-comparison.kak` and `number-comparison-regex.sh` to your autoload dir: `~/.config/kak/autoload/`, or source the kakoune file manually.
The two files must be in the same directory for the plugin to function.

## Usage

The plugin adds a single command:
```
number-comparison [<switches>] <operator> <number>
```
`<operator>` and `<number>` are mandatory.  
`<operator>` must be one of  `<`,`<=`,`>=`,`=`,`!=`.  
`<number>` is the number to be compared to, it must conform to the format described below.  

The command sets the `/` (search) register to a regular expression that will match any integer such that `<match> <operator> <number>` is fulfilled. For example, after calling `number-comparison < 3`, numbers smaller than `3` (such as `2.99`, `1`, `0`, `-011`)  will be matched.

The regex will be surrounded by the lookarounds `(?<![0-9-.])` and `(?![0-9.])`, to avoid partial number matches.

### Switches

The following switches are supported:

*`-no-bounds-check`: The surrounding with lookarounds is disabled.  
*`-no-negative`: The matching of negative numbers is disabled.  
*`-no-decimal`: The matching of decimal numbers is disabled.  
*`-register <reg>`: The register `<reg>` (instead of `/`) will be used to store the result.  
*`-prepend <pre>`: The resulting regex is prefixed with `<pre>`.  
*`-append <post>`: The resulting regex is suffixed with `<post>`.  

### Number format

The number format for both input (the command argument) and output (the matched numbers) is represented by the regex `-?(\d+(\.\d*)?|\.\d+)`. Note that the options described above can disable certain classes of numbers.
Practically speaking, this means positive and negative with an optional decimal part.  
Some examples include:
```
0
10
-0123
0001
5.8
27.
0.1200
.25
-.25
```

### Standalone usage

The regex generation is entirely contained in `number-comparison-regex.sh` and can be used standalone.
The usage is similar to the kakoune command: `./number-comparison-regex.sh <operator> <number>`.
The generated regex is printed to stdout should hopefully work in most engines.

Be careful that operators such as `<` and `>` are special shell syntax, as such they should be wrapped in quotes.

## Testing

The plugin comes with testing, implemented in the separate `test.kak`. It can be ran by simply doing `kak -n -e 'source test.kak ; start-test 10'`.  
`10` can be replaced by any positive integer. The higher the number, the more thorough the tests, but also the longer they will take.

If the tests succeed, kakoune will exit after running the tests.  
If they fail, it should stay open in the `*debug*` buffer, with hopefully a debug message indicating what is the failure.

Since the tests use a lot of shell scopes, it is recommended to use `dash`, for example with `KAKOUNE_POSIX_SHELL=/bin/dash`. Compared to bash, running the tests is roughly 4 times faster.

## Why?

It is somewhat fun, and sometimes can actually be useful. Of course, this is a terribly inefficient way to do number comparison but it has the advantage of not being limited to a certain integer range. The only limitation is that of the regex engine.

## License

Unlicense
