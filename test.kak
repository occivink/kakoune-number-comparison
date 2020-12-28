source number-comparison.kak

define-command start-test -params 1 %{
    edit -scratch *test-buffer*
    reg | "
        for i in $(seq %arg{1} -1 0); do
            printf -- '-%%s\n' $i
            printf -- '-0%%s\n' $i
            printf -- '-00000%%s\n' $i
        done
        for i in $(seq 0 1 %arg{1}); do
            printf -- '%%s\n' $i
            printf -- '0%%s\n' $i
            printf -- '00000%%s\n' $i
        done
        for sign in '' '-'; do
            for int in '' 100 010 10 05 5 1 0; do
                for dec in '' 0 00 1 01 05 10 005 080800; do
                    [ ""$int"" = '' ] && [ ""$dec"" = '' ] && continue
                    printf -- '%%s.%%s\n' ""$int"" ""$dec""
                done
            done
        done
    "
    exec '|<ret>'
    exec '%<a-s>H'
    eval -itersel %{
        compare-number-to-rest < "%val{selection}"
        compare-number-to-rest <= "%val{selection}"
        compare-number-to-rest > "%val{selection}"
        compare-number-to-rest >= "%val{selection}"
        compare-number-to-rest = "%val{selection}"
        compare-number-to-rest != "%val{selection}"
    }

    try %{
        buffer *debug*
        exec '%<a-K>failed<ret>'
        quit! 0
    }
}

define-command compare-number-to-rest -params 2 %{
    number-comparison "%arg{1}" "%arg{2}"
    eval -draft %{
        exec '%<a-s>H'
        try %{
            eval -draft %{
                exec '<a-k><ret>'
                check-matches '' "%arg{1}" "%arg{2}"
            }
        }
        try %{
            eval -draft %{
                exec '<a-K><ret>'
                check-matches '!' "%arg{1}" "%arg{2}"
            }
        }
    }
}

define-command check-matches -params 3 %{
    eval %sh{
        not="$1"
        op="$2"
        ref="$3"
        eval set -- "$kak_selections"
        for number; do
            printf '%s\n' "$number"
        done | awk "BEGIN {
            ref=\"$ref\" + 0;
            op=\"$op\";
            not=\"$not\";
        }
        // {
            num=\$0 + 0;
            if (op == \"<\") {
                res = (num < ref);
            } else if (op == \"<=\") {
                res = (num <= ref);
            } else if (op == \">\") {
                res = (num > ref);
            } else if (op == \">=\") {
                res = (num >= ref);
            } else if (op == \"=\") {
                res = (num == ref);
            } else if (op == \"!=\") {
                res = (num != ref);
            } else {
                print(\"echo -debug 'failed: unhandled argument'\");
                next
            }
            if (not == \"!\") {
                res = !res;
            }
            if (!res) {
                sp = \" \";
                print(\"echo -debug 'failed: invalid comparison \" sp not sp \$0 sp op sp \"$ref\" \"'\");
            }
        }"
    }
}
