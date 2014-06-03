#! /usr/bin/gawk --re-interval -F, -v target="${1}" 

## table ##
## model,characters,length,scope,hash
function GetSalt(definitions)
{
    if (definitions[1] == "model")
    {
        result = gensub(definitions[2], definitions[3], "1", target)
    }
    else if (definitions[1] == "field")
    {
        result = gensub(definitions[3], definitions[4], "1", $definitions[2])
    }
    else if (definitions[1] == "date")
    {
        result = strftime(definitions[2])
    }
    else if (definitions[1] == "constant")
    {
        result = definitions[2]
    }
    else if (definitions[1] == "system")
    {
        cmd = definitions[2] " " target " " gensub(",", " ", "g", $0)
        cmd |& getline result
        close(cmd)
        gsub("[[:space:]].*$", "", result)
        ## string ## first word only
    }
    else
    {
        result = $salt
    }
    return(result)
}

BEGIN {
    separator = "!"

    i = 0
    record = i; ++i
    template = i; ++i
    characters = i; ++i
    nb = i; ++i
    salt = i; ++i
    hash = i; ++i

    alls = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
}

$record ~ "^[[:space:]]*#" {
    next
}

target ~ "^" $template "$" {
    subset = gensub("[^[:" $characters ":]]*", "", "g", alls)
    split($salt, SaltDef, separator)
    printf("%s %s %s %s %s\n", gensub(":.*$", "", 1, target), subset, $nb + 0, GetSalt(SaltDef), gensub(" .*$", "", 1, $hash))
    exit
}
