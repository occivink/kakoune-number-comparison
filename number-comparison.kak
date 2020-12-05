declare-option -hidden str number_comparison_install_path %sh{dirname "$kak_source"}

define-command number-comparison -params 2.. -docstring "
number-comparison OP NUM
" %{
   set-register slash %sh{
       export KAK_NUMBER_COMPARISON_NOAUTOCOMPARE=
       . "$kak_opt_number_comparison_install_path"/number-comparison-regex.sh
       printf '(?<![0-9-])'
       compare "$1" "$2"
       printf '(?![0-9-])'
   }
}
