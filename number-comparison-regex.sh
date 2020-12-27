#!/bin/sh

op=''
strict=''
sign=''
num=''
int=''
dec=''

parse_operator()
{
    case "$1" in
      "<") strict='y' ;;
      "<=") strict='n' ;;
      ">") strict='y' ;;
      ">=") strict='n' ;;
      "=") strict='y' ;;
      "==") strict='y' ;;
      "!=") strict='y' ;;
      *) return 1 ;;
    esac
    op="$1"
    [ "$op" = '==' ] && op='='
    return 0
}

parse_number()
{
    [ "$1" = '' ] && return 1;

    # parse sign
    num="$1"
    case "$num" in
      "+"*) num=${num#+} ; sign='+' ;;
      "-"*) num=${num#-} ; sign='-' ;;
      *) sign="+" ;;
    esac

    # parse integral and decimal part
    int=${num%.*}
    dec=${num#*.}
    [ "$dec" = "$num" ] && dec=''
    if [ "$int" = '' ] && [ "$dec" = '' ]; then
        return 1
    fi

    # remove leading zeroes of integral part
    tmp="$int"
    while :; do
        int=${tmp#0}
        [ "$tmp" = "$int" ] && break
        tmp=$int
    done
    [ "$int" = '' ] && int='0'

    # validate integral part
    case "$int" in
       *[!0-9]*|'') return 1 ;;
       *) ;;
    esac

    # remove trailing zeroes of decimal part
    tmp="$dec"
    while :; do
        dec=${tmp%0}
        [ "$tmp" = "$dec" ] && break
        tmp=$dec
    done
    [ "$dec" = "" ] && dec='0'

    # validate decimal part
    case "$dec" in
       *[!0-9]*|'') return 1 ;;
       *) ;;
    esac

    # turn -0 into +0
    if [ "$int" = '0' ] && [ "$dec" = '0' ] && [ "$sign" = "-" ]; then
        sign='+'
    fi

    # debug code
    #printf '%s%s.%s\n' $sign $int $dec
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
    printf '0*('
    printf '[1-9]\d'
    print_repeat "${#int}" ''

    digitsbefore=''
    digitsafter=''
    tmp="$int"
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
        printf '|%s' "$int"
    fi
    printf ')'
}

lt()
{
    if [ ${#int} -eq 1 ]; then
        if [ $strict = "n" ]; then
            printf '0*'
            print_range 0 "$int"
        else
            if [ "$int" = '0' ]; then
                # should not reach here
                exit 1
            else
                printf '0*'
                print_range 0 "$((int - 1))"
            fi
        fi
    else
        printf '0*(\d'
        print_repeat '1' "$((${#int} -1))"

        digitsbefore=''
        digitsafter=''
        tmp="$int"
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
        if [ "$strict" = "n" ]; then
            printf '|%s' "$int"
        fi
        printf ')'
    fi
}

compare()
{

    if [ "$op" = '' ] || [ "$strict" = '' ]; then
        exit 1
    fi
    if [ "$sign" = '' ] || [ "$num" = '' ] || [ "$int" = '' ] || [ "$dec" = '' ]; then
        exit 1
    fi

    if [ "$op" = '>' ] || [ "$op" = '>=' ]; then
        if [ "$op" = ">=" ] && [ "$int" = '0' ]; then
            printf -- '(-0+|\d+)'
        elif [ "$sign" = '+' ]; then
            gt
        else
            printf -- '(-'
            lt
            printf -- '|\d+)'
        fi
    elif [ "$op" = "<" ] || [ "$op" = "<=" ]; then
        # special case for <0
        if [ "$op" = '<' ] && [ "$int" = '0' ]; then
            printf -- '-0*[1-9]\d*'
        elif [ "$sign" = '+' ]; then
            printf -- '('
            lt
            printf -- '|-\d+)'
        else
            printf -- '-'
            gt
        fi
    elif [ "$op" = "=" ]; then
        [ "$sign" = '-' ] && prefix='-' || prefix=''
        if [ "$int" = 0 ] && [ "$dec" = 0 ]; then
            printf -- '-?(0+(\.0*)?|\.0+)'
        elif [ $int = 0 ]; then
            printf -- '%s0*\.%s0*' "$prefix" "$dec"
        elif [ $dec = 0 ]; then
            printf -- '%s0*%s(\.0*)?' "$prefix" "$int"
        else
            printf -- '%s0*%s\.%s0*' "$prefix" "$int" "$dec"
        fi
    elif [ "$op" = "!=" ]; then
        # special case for 0... again
        if [ "$int" = '0' ]; then
            printf -- '-?\d*[1-9]\d*'
        elif [ "$sign" = '+' ]; then
            printf '('
            gt
            printf -- '|'
            lt
            printf -- '|-\d+)'
        else
            printf '(-'
            gt
            printf -- '|-'
            lt
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
    if ! parse_operator "$1"; then
        echo "$1" is not a valid operator
        exit 1
    fi
    if ! parse_number "$2"; then
        echo "$2" is not a valid number
        exit 1
    fi
    compare
    if [ $? -eq 0 ]; then
        printf '\n'
    else
        exit 1
    fi
fi

#123.123
#
#1-9\d\d\d
#1[3-9]\d
#12[4-9]
#123.[2-9]\d*
#123.1[3-9]\d*
#123.12[4-9]\d*
