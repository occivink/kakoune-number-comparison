declare-option -hidden str number_comparison_install_path %sh{dirname "$kak_source"}

define-command number-comparison -params 2.. -docstring "
number-comparison OP NUM
" %{
    eval %sh{
        export KAK_NUMBER_COMPARISON_NOAUTOCOMPARE=
        . "$kak_opt_number_comparison_install_path"/number-comparison-regex.sh
        if ! is_operator "$1"; then
            echo 'fail "%arg{1}" is not a valid operator'
            exit 1
        fi
        if ! is_number "$2"; then
            echo 'fail "%arg{2}" is not a valid number'
            exit 1
        fi
        # the generated regex shouldn't contain any ' ... I think
        printf "set-register slash '"
        printf '(?<![0-9-])'
        compare "$1" "$2"
        printf '(?![0-9-])'
        printf "'"
    }
}
