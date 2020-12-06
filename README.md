# kakoune-number-comparison

[kakoune](http://kakoune.org) plugin to do number comparison using regex.

## Setup

Add `number-comparison.kak` and `number-comparison-regex.sh` to your autoload dir: `~/.config/kak/autoload/`, or source the kakoune file manually.
The two files must be in the same directory for the plugin to function.

## Usage

The plugin adds a single command:
```
number-comparison [-no-bounds-check] [-register REGISTER] OPERATOR NUMBER
```
`OPERATOR` and `NUMBER` are mandatory. `OPERATOR` must be one of  `<`,`<=`,`>=`,`=`,`!=`. `NUMBER` is the number to be compared to, it may be any integer.

The command sets the `/` (search) register to a regular expression that will match any integer such that `MATCH OPERATOR NUMBER` is fulfilled. For example, after calling `number-comparison < 3`, numbers smaller than `3` (such as `1`, `0`, `-011`)  will be matched.

By default, the regex will be surrounded by the lookarounds `(?<![0-9-])` and `(?![0-9]-)`, to avoid partial number matches. This can be disabled with the `-no-bounds-check` flags.

A register other than `/` may be specified with `-register`.

### Standalone usage

The regex generation is entirely contained in `number-comparison-regex.sh` and can be used standalone.
The usage is similar to the kakoune command: `./number-comparison-regex.sh OPERATOR NUMBER`.
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
