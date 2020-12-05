#!/bin/sh

print_range()
{
    if [ $1 = $2 ]; then
        printf '%s' "$1"
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

    printf '0*('
    printf '[1-9]\d'
    print_repeat "${#num}" ''

    digitsbefore=''
    digitsafter=''
    while [ -n "$num" ]; do
        digitsafter="${num#?}"
        digit="${num%"$digitsafter"}"

        if [ $digit -lt 9 ]; then
            printf '|%s' "$digitsbefore"
            print_range "$((digit + 1))" 9
            if [ -n "$digitsafter" ]; then
                printf '\d'
                print_repeat "${#digitsafter}"
            fi
        fi

        num="$digitsafter"
        digitsbefore="${digitsbefore}${digit}"
    done
    printf ')'
}

lt()
{
    num="$1"

    if [ "${num}" = '' ]; then
        printf '\A\z'
        return 0
    fi

    printf '0*'

    if [ ${#num} -eq 1 ]; then
        print_range 0 "$((num - 1))"
    else
        printf '('
        printf '\d'
        print_repeat '1' "$((${#num} -1))"

        digitsbefore=''
        digitsafter=''
        while [ -n "$num" ]; do
            digitsafter="${num#?}"
            digit="${num%"$digitsafter"}"

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

            num="$digitsafter"
            digitsbefore="${digitsbefore}${digit}"
        done
        printf ')'
    fi
}

tmp="$1"
case "$tmp" in
  "+"*) tmp=${tmp#+} ; positive=y ;;
  "-"*) tmp=${tmp#-} ; positive=n ;;
  *) positive=y ;;
esac
case "$tmp" in
   *[!0-9]*|'') echo not a number ; exit 1 ;;
   *)           ;;
esac

while :; do
    num=${tmp#0}
    [ "$tmp" = "$num" ] && break
    tmp=$num
done

echo $positive
echo $num


#     gt               | lt
# +   gt N             | lt N || negative
# -   positive || gt N | lt N
