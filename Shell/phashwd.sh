#! /bin/bash -f

## range ##
## 0x21 -> !
## 0x30 -> 0
## 0x39 -> 9
## 0x40 -> @
## 0x41 -> A
## 0x5a -> Z
## 0x61 -> a
## 0x7a -> z
## 0x7e -> ~

TARGETS="${HOME}/.targets"

function hash2ascii()
{
    hash=$1
    size=$2
    characters=$3
    # $1: hash $2: size $3: character set
    local length group distribute index code result
    declare -i length group distribute index code

    length="${#hash}"
    group="length/${size}"
    distribute="length%${size}"
    index=0
    result=""

    while [ "${index}" -lt "${length}" ]
    do
        let one="0+(distribute > 0 ? 1 : 0)"
        nb="group+one"
        distribute="distribute-one"

        code="0x${hash:${index}:${nb}}%${#characters}"
        result="${result}${characters:${code}:1}"
        index="index+nb"
    done
    echo "${result}"
}

function phashwd()
{
    if [ ! -e "${TARGETS}" ]
    then
        echo "Your targets file (${TARGETS}) does not exist. Please create it (format: template,characters,length,salt,hash)".
        echo "usage: ${FUNCNAME[0]} <model>."
        return 1
    fi

    local parser
    parser=$(readlink -fn "${BASH_SOURCE[0]}")
    parser="${parser%.*}.awk"
    if [ ! -e "${parser}" ]
    then
        echo "Helper program (${parser} ${FUNCNAME[0]}.awk) not found. Check your installation."
        return 1
    fi

    if [ "$#" -ne "1" ]
    then
        models=$(gawk -F, -v ORS=' ' '$0 !~ /^[[:space:]]*#/ {print $1}' ${TARGETS})
        models=${models// /|}
        echo "usage: phashwd ${models:0:${#models}-1}."
        return 1
    fi

    local length period salt password hash
    declare -i length

    targets=($(gawk --re-interval -F, -v target="${1}"  -f "${parser}" ${TARGETS}))
    hashing="/usr/bin/${targets[4]%% *}"

    if [ "${#targets[@]}" -ne 5 ]
    then
        echo "phashwd: incorrect target configuration <${targets[@]}>."
        false
    elif [ ! -x "${hashing}" ]
    then
        echo "phashwd: not existing hashing function <${hashing}>."
    else
        ## table ##
        ## template,characters,length,salt,hash
        read -p "secret: " -s password
        echo
        hash="$(echo -n ${targets[0]}${password}${targets[3]} | ${hashing})"

        unset password targets[0] targets[3]
        hash=${hash%% *}

        echo "password: $(hash2ascii "${hash}" "${targets[2]}" "${targets[1]}")"
    fi
}
