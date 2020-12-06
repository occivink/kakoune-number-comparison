declare-option -hidden str number_comparison_install_path %sh{dirname "$kak_source"}

define-command number-comparison -params .. -docstring "
number-comparison [-register REG] [-no-bounds-check] OP NUM
" %{
    eval %sh{
        NOAUTOCOMPARE=''
        . "$kak_opt_number_comparison_install_path"/number-comparison-regex.sh

        arg_num=0
        register='/'
        op=''
        number=''
        boundaries='y'
        while [ $# -ne 0 ]; do
            arg_num=$((arg_num + 1))
            arg=$1
            shift
            if [ "$arg" = '-register' ]; then
                if [ $# -eq 0 ]; then
                    echo 'fail "Missing argument to -register"'
                    exit 1
                fi
                # the set-register will later check that it's a valid one
                arg_num=$((arg_num + 1))
                register=$1
                shift
            elif [ "$arg" = '-no-bounds-check' ]; then
                boundaries='n'
            elif [ -z "$op" ]; then
                if ! is_operator "$arg"; then
                    printf "fail \"Invalid operator '%%arg{%s}'\"" "$arg_num"
                    exit 1
                fi
                op=$arg
            elif [ -z "$number" ]; then
                if ! is_number "$arg"; then
                    printf "fail \"Invalid number '%%arg{%s}'\"" "$arg_num"
                    exit 1
                fi
                number="$arg"
            else
                printf "fail \"Unrecognized extra parameter '%%arg{%s}'\"" "$arg_num"
                exit 1
            fi
        done
        if [ -z "$op" ]; then
            echo 'fail "Missing operator"'
            exit 1
        elif [ -z "$number" ]; then
            echo 'fail "Missing number"'
            exit 1
        fi
        # the generated regex shouldn't contain any ' ... I think
        printf "set-register %s '" "$register"
        [ "$boundaries" = y ] && printf '(?<![0-9-])'
        compare "$op" "$number"
        [ "$boundaries" = y ] && printf '(?![0-9-])'
        printf "'\n"
        printf "echo -markup \"{Information}{\}register '%s' set to '%%reg{%s}'\"\n" "$register" "$register"
    }
}
