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
                printf '\A\z'
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

if [ $# -ne 2 ]; then
    echo Invalid arguments
    exit 1
fi

op="$1"
case "$op" in
  "<"*) ;;
  "<="*) ;;
  ">"*) ;;
  ">="*) ;;
  "="*) ;;
  *) echo Invalid operator ; exit 1 ;;
esac

tmp="$2"
case "$tmp" in
  "+"*) tmp=${tmp#+} ; positive=y ;;
  "-"*) tmp=${tmp#-} ; positive=n ;;
  *) positive=y ;;
esac
case "$tmp" in
   *[!0-9]*|'') echo not a number ; exit 1 ;;
   *) ;;
esac

while :; do
    num=${tmp#0}
    [ "$tmp" = "$num" ] && break
    tmp=$num
done
if [ "$num" = "" ]; then
    num=0;
fi

if [ "$op" = ">" ]; then
    gt "$num" y
elif [ "$op" = ">=" ]; then
    gt "$num" n
elif [ "$op" = "<" ]; then
    lt "$num" y
elif [ "$op" = "<=" ]; then
    lt "$num" n
elif [ "$op" = "=" ]; then
    printf '0*%s' "$num"
fi

#     gt               | lt
# +   gt N             | lt N || negative
# -   positive || gt N | lt N
