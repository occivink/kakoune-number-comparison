# kakoune-number-comparison

[kakoune](http://kakoune.org) plugin to do number comparison using regex.

## Setup

Add `number-comparison.kak` and `number-comparison-regex.sh` to your autoload dir: `~/.config/kak/autoload/`, or source the kakoune file manually.
The two files must be in the same directory for the plugin to function.

## Usage

The plugin adds a single command, `number-comparison`. The command takes two arguments, the operator and the number to compare to. The operator can be any of `<`,`<=`,`>=`,`=`,`!=`. The number may be any integer.
The command sets the `/` (search) register to a regular expression that will match any integer such that ``MATCH OPERATOR NUMBER`` is fulfilled.
For example, after calling `number-comparison < 3`, numbers smaller than `3` (such as `1`, `0`, `-011`)  will be matched.

### Standalone usage

The regex generation is entirely contained in `number-comparison-regex.sh` and can be used standalone.
The usage is similar to the kakoune command: `./number-comparison-regex.sh OPERATOR NUMBER`.
The generated regex is printed to stdout should hopefully work in most engines.

Be careful that operators such as `<` and `>` are special shell syntax, as such they should be wrapped in quotes.

## Testing

The plugin comes with unit testing. It can be ran by simply doing `kak -e 'source test.kak ; start-test 10'`.
`10` can be replaced by any positive integer. The higher the number, the more thorough the tests, but also the longer they will take.
If the tests succeed, kakoune will exit after running the tests.
If they fail, it should stay open in the `*debug*` buffer, with hopefully a debug message indicating what is the failure.

## Why?

It is somewhat fun, and sometimes can actually be useful. Of course, this is a terribly inefficient way to do number comparison but it has the advantage of not being limited to a certain integer range. The only limitation is that of the regex engine.

## License

Unlicense
