try %{
    require-module number-comparison
} catch %{
    source number-comparison.kak
    require-module number-comparison
}

define-command assert-command-fails -params 1 %{
    eval -save-regs e %{
        reg e ''
        try %{
            eval %arg{1}
            reg e 'fail "TODO, but should have"'
        }
        eval %reg{e}
    }
}

define-command assert-all-match -params 1.. %{
    reg dquote %arg{@}
    exec '%<a-d><a-P>a<ret><esc>ged%<a-s>H'
    reg e ''
    try %{
        exec '<a-K><ret>'
        reg e 'fail "Matched, but should not"'
    }
    eval %reg{e}
    eval -draft %{
        exec '%S<ret>'
        assert-command-fails %{ exec '<a-K>\n<ret>' }
    }
}

define-command assert-none-match -params 1.. %{
    reg dquote %arg{@}
    exec '%<a-d><a-P>a<ret><esc>ged%<a-s>H'
    reg e ''
    try %{
        exec '<a-k><ret>'
        reg e 'fail "Matched, but should not"'
    }
    eval %reg{e}
    assert-command-fails %{ exec '%s<ret>' }
}

assert-command-fails %{ number-comparison }
assert-command-fails %{ number-comparison '<' }
assert-command-fails %{ number-comparison 10 }
assert-command-fails %{ number-comparison '!' 10 }
assert-command-fails %{ number-comparison 10 10 }
assert-command-fails %{ number-comparison '<' '>' }
assert-command-fails %{ number-comparison -base 1 '>' 0 }
assert-command-fails %{ number-comparison -base 20 '>' 10 }
assert-command-fails %{ number-comparison -no-negative '<' 0 }

declare-option str-list never_matches 'z' '''' 'bob' '%{}' '""' '_foobar_' '%sh{printf abc}' '23.34.56' '0..1'

declare-option str-list zeros '0' '.0' '000' '0.' '0.0' '0.0000000000' '-0' '-.0' '-0.0' '-000.' '-000.000'
declare-option str-list positive '.1' '.09' '2.' '1' '2' '9.9999' '.000000000000000000000001' \
    '999999999999999999999999999999999999' '10' '010' '0123456789' '23.34456' '321.' '45.67' '1.1'
declare-option str-list negative '-1' '-0.1' '-0.09' '-.000000000000000000000001' '-2.2' '-23' \
    '-456' '-9999' '-0.01' '-123.5999' '-23' '-000123' '-0.10101010' '-0005' '-0123456789' '-1.1'

# compare to 0
number-comparison < 0
assert-all-match %opt{negative}
assert-none-match %opt{zeros} %opt{positive} %opt{never_matches}

number-comparison > .000
assert-all-match %opt{positive}
assert-none-match %opt{zeros} %opt{negative} %opt{never_matches}

number-comparison != 000.
assert-all-match %opt{positive} %opt{negative}
assert-none-match %opt{zeros} %opt{never_matches}

number-comparison == -0
assert-all-match %opt{zeros}
assert-none-match %opt{negative} %opt{positive} %opt{never_matches}

number-comparison >= -000.000
assert-all-match %opt{zeros} %opt{positive}
assert-none-match %opt{negative} %opt{never_matches}

number-comparison <= -.0
assert-all-match %opt{zeros} %opt{negative}
assert-none-match %opt{positive} %opt{never_matches}

# compare to some positive number
number-comparison < 55.53
assert-all-match %opt{negative} %opt{zeros} 55.522222229 1 10 55 29
assert-none-match 55.53 55.530000000 55.53000001 56 99 100 2345 45678 %opt{never_matches}

number-comparison > 2
assert-all-match 2.0001 3 02.5 5.00001 10 55 300 0333.0
assert-none-match %opt{negative} %opt{zeros} %opt{never_matches}

number-comparison != 0.025
assert-all-match 1.025 10.025 0.02501 25 0.25 123 0.1 %opt{negative} %opt{zeros}
assert-none-match .025 000.025 0.025000 %opt{never_matches}

number-comparison == 555.123
assert-all-match 555.123 555.1230 0555.123 000555.123000
assert-none-match 55.53 55.530000000 55.53000001 56 99 100 2345 45678 %opt{negative} %opt{zeros} %opt{never_matches}

number-comparison >= 4876.
assert-all-match 4876 04876 4876. 4876.0 004876.00 4876.00001 4877 9999 10000 12345.00 012345.01 099999
assert-none-match 4875.9999 1 123 1234 02345 04875 04000.0 %opt{negative} %opt{zeros} %opt{never_matches}

number-comparison <= 1.23456789
assert-all-match 1.23456789 001.2345678900 1.0 1.23456788 1.1000 0.1000 %opt{negative} %opt{zeros}
assert-none-match 001.23456789000001 2 2.005 002.5 5 10 95 123 333.333 %opt{never_matches}

# compare to some negative number
number-comparison < -0.01
assert-all-match -0.011 -0.02 -.02 -10 -010 -2 -.010000001000 -15.00 -027.123 -345034805
assert-none-match -0.001 -.009 -00.009999000 %opt{positive} %opt{zeros} %opt{never_matches}

number-comparison > -151.282
assert-all-match %opt{positive} %opt{zeros} -1 -151 -0151.281999999999999999 -28.12 -030 -5.000 -5.0009
assert-none-match -151.28200 -152 -00152.283 -152.28200000001 -155 -1515.1 -09999 %opt{never_matches}

number-comparison != -83.00
assert-all-match -82.9999 -83.0001 -1 -10 -100 -01 -010 -0100 -830 %opt{positive} %opt{zeros}
assert-none-match -83 -83.0 -083.0 -00083 %opt{never_matches}

number-comparison == -3.03
assert-all-match -03.0300 -3.03 -3.0300 -003.03
assert-none-match -3.033 -3.02 -2.03 -30.3 -303 -3.03000001 -10 -5 -15.5 -123.55 %opt{positive} %opt{zeros} %opt{never_matches}

number-comparison >= -0.9
assert-all-match -0.89999 -0.09 -0.1 -0.50000 %opt{positive} %opt{zeros}
assert-none-match -1 -0.900001 -.99 -1.0000001 -10. -23.45  %opt{never_matches}

number-comparison <= -531.
assert-all-match -532 -532.000000001 -999 -1000.123
assert-none-match -530 -530.99999999 -300 -99.000 -5.3535 -1.000 %opt{positive} %opt{zeros} %opt{never_matches}
