#!/bin/sh

is_operator()
{
    case "$1" in
      "<") ;;
      "<=") ;;
      ">") ;;
      ">=") ;;
      "=") ;;
      "==") ;;
      "!=") ;;
      *) return 1 ;;
    esac
}

is_number()
{
    num="$1"
    case "$num" in
      "+"*) num=${num#+} ;;
      "-"*) num=${num#-} ;;
      *) ;;
    esac
    case "$num" in
       *[!0-9]*|'') return 1 ;;
       *) ;;
    esac
}

print_range()
{
    if [ $1 = $2 ]; then
        printf '%s' "$1"
    elif [ $1 = 0 ] && [ $2 = 9 ]; then
        printf '\d'
    else
        printf "[%s-%s]" "$1" "$2"
    fi
}

print_repeat()
{
    if [ $# -eq 1 ]; then
        if [ "$1" != 1 ]; then
            printf '{%s}' "$1"
        fi
    elif [ "$2" = "" ]; then
        if [ "$1" = 0 ]; then
            printf '*'
        elif [ "$1" = 1 ]; then
            printf '+'
        else
            printf '{%s,}' "$1"
        fi
    elif [ "$1" = "$2" ]; then
        if [ "$1" != 1 ]; then
            printf '{%s}' "$1"
        fi
    else
        printf '{%s,%s}' "$1" "$2"
    fi
}

gt()
{
    num="$1"
    strict="$2"

    printf '0*('
    printf '[1-9]\d'
    print_repeat "${#num}" ''

    digitsbefore=''
    digitsafter=''
    tmp="$num"
    while [ -n "$tmp" ]; do
        digitsafter="${tmp#?}"
        digit="${tmp%"$digitsafter"}"

        if [ $digit -lt 9 ]; then
            printf '|%s' "$digitsbefore"
            print_range "$((digit + 1))" 9
            if [ -n "$digitsafter" ]; then
                printf '\d'
                print_repeat "${#digitsafter}"
            fi
        fi

        tmp="$digitsafter"
        digitsbefore="${digitsbefore}${digit}"
    done
    if [ $strict = "n" ]; then
        printf '|%s' "$num"
    fi
    printf ')'
}

lt()
{
    num="$1"
    strict="$2"

    if [ ${#num} -eq 1 ]; then
        if [ $strict = "n" ]; then
            printf '0*'
            print_range 0 "$num"
        else
            if [ "$num" = '0' ]; then
                # should not reach here
                exit 1
            else
                printf '0*'
                print_range 0 "$((num - 1))"
            fi
        fi
    else
        printf '0*(\d'
        print_repeat '1' "$((${#num} -1))"

        digitsbefore=''
        digitsafter=''
        tmp="$num"
        while [ -n "$tmp" ]; do
            digitsafter="${tmp#?}"
            digit="${tmp%"$digitsafter"}"

            if [ $digit -eq 1 ] && [ -n "$digitsbefore"  ] || [ $digit -gt 1 ]; then
                printf '|%s' "$digitsbefore"
                if [ -n "$digitsbefore" ]; then
                    print_range 0 "$((digit - 1))"
                else
                    print_range 1 "$((digit - 1))"
                fi
                if [ -n "$digitsafter" ]; then
                    printf '\d'
                    print_repeat ${#digitsafter}
                fi
            fi

            tmp="$digitsafter"
            digitsbefore="${digitsbefore}${digit}"
        done
        if [ $strict = "n" ]; then
            printf '|%s' "$num"
        fi
        printf ')'
    fi
}

compare()
{
    op="$1"
    [ "$op" = '==' ] && op='='

    tmp="$2"
    sign=''
    case "$tmp" in
      "+"*) tmp=${tmp#+} ; sign='+' ;;
      "-"*) tmp=${tmp#-} ; sign='-' ;;
      *) sign="+" ;;
    esac

    while :; do
        num=${tmp#0}
        [ "$tmp" = "$num" ] && break
        tmp=$num
    done
    if [ "$num" = '' ]; then
        num='0';
        if [ "$sign" = "-" ]; then
            sign='+'
        fi
    fi

    if [ "$op" = '>' ] || [ "$op" = '>=' ]; then
        [ "$op" = '>' ] && strict='y' || strict='n'
        if [ "$op" = ">=" ] && [ "$num" = '0' ]; then
            printf -- '(-0+|\d+)'
        elif [ "$sign" = '+' ]; then
            gt "$num" "$strict"
        else
            printf -- '(-'
            lt "$num" "$strict"
            printf -- '|\d+)'
        fi
    elif [ "$op" = "<" ] || [ "$op" = "<=" ]; then
        [ "$op" = '<' ] && strict='y' || strict='n'
        # special case for <0
        if [ "$op" = '<' ] && [ "$num" = '0' ]; then
            printf -- '-0*[1-9]\d*'
        elif [ "$sign" = '+' ]; then
            printf -- '('
            lt "$num" "$strict"
            printf -- '|-\d+)'
        else
            printf -- '-'
            gt "$num" "$strict"
        fi
    elif [ "$op" = "=" ]; then
        if [ "$num" = 0 ]; then
            printf -- '-?0+'
        elif [ "$sign" = '+' ]; then
            printf -- '0*%s' "$num"
        else
            printf -- '-0*%s' "$num"
        fi
    elif [ "$op" = "!=" ]; then
        strict='y'
        # special case for 0... again
        if [ $num = '0' ]; then
            printf -- '-?\d*[1-9]\d*'
        elif [ "$sign" = '+' ]; then
            printf '('
            gt "$num" "$strict"
            printf -- '|'
            lt "$num" "$strict"
            printf -- '|-\d+)'
        else
            printf '(-'
            gt "$num" "$strict"
            printf -- '|-'
            lt "$num" "$strict"
            printf -- '|\d+)'
        fi

    fi
}

# silly mechanism to disable the auto-comparison when sourcing the script
if [ -n "${NOAUTOCOMPARE+a}" ]; then
    :
else
    if [ $# -ne 2 ]; then
        echo Missing arguments
        exit 1
    fi
    if ! is_operator "$1"; then
        echo "$1" is not a valid operator
        exit 1
    fi
    if ! is_number "$2"; then
        echo "$2" is not a valid number
        exit 1
    fi
    compare "$1" "$2"
    if [ $? -eq 0 ]; then
        printf '\n'
    else
        exit 1
    fi
fi
