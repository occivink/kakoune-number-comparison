source number-comparison.kak

define-command start-test %{
    edit -scratch *test-buffer*
    reg | %{
        for i in $(seq 100 -1 0); do
            echo '-%s' "$i"
            echo '-0%s' "$i"
            echo '-00000%s' "$i"
        done
        for i in $(seq 0 1 100); do
            echo '%s' "$i"
            echo '0%s' "$i"
            echo '00000%s' "$i"
        done
    }
    exec '|<ret>'
    exec '%<a-s>H'
    eval -itersel %{
        compare-number-to-rest < "lt" "%val{selection}"
        compare-number-to-rest <= "le" "%val{selection}"
        compare-number-to-rest > "gt" "%val{selection}"
        compare-number-to-rest >= "ge" "%val{selection}"
        compare-number-to-rest = "eq" "%val{selection}"
    }

    try %{
        buffer *debug*

        quit! 0
    }
}

define-command compare-number-to-rest -params 3 %{
    number-comparison "%arg{1}" "%arg{3}"
    eval -draft %{
        exec '%<a-s>H'
        try %{
            eval -draft %{
                exec '<a-k>ret'
                check-matches '' "%arg{2}" "%arg{3}"
            }
        }
        try %{
            eval -draft %{
                exec '<a-K>ret'
                check-matches '!' "%arg{2}" "%arg{3}"
            }
        }
    }
}

define-command check-matches -params 3 %{
    eval %sh{
        not="$1"
        op="$2"
        val="$3"
        eval set -- "$kak_selections"
        for number; do
            if [ $not "$number" "$op" "$val" ]; then
                :
            else
                printf 'echo -debug "comparison failed %s %s %s"\n' "$number" "$op" "$val";
            fi
        done
    }
}
