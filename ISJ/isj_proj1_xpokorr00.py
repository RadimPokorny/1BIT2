#!/usr/bin/env python3

import re

# ukol za 2 body
def only_consonants(input: chr) -> bool:
    """Checks whether the input string is formed only by ASCII lower consonants 

    >>> only_consonants('vlk')
    True
    >>> only_consonants('scvrnkls')
    True
    >>> only_consonants('kolo')
    False
    >>> only_consonants('k_l')
    False
    >>> only_consonants('k l')
    False
    >>> only_consonants('k@l')
    False
    >>> only_consonants('vlk!')
    False
    """
    # negative lookahed to exclude non consonants and the second part is 
    # only allowing lowercase letters from alphabet and end of the string
    pat = re.compile(r'^(?!.*[aeiou])[a-z]+$', re.VERBOSE) 
    return bool(pat.search(input))


# ukol za 3 body
def filter_not_markup_plusplus(expr_string: str) -> str:
    """Filters strings (followed by ;) not being preceded and followed by ++
       at the same time

    >>> filter_not_markup_plusplus('++var;i++;++Def title++;C++;++macro++;++j;')
    ['++var', 'i++', 'C++', '++j']
    """

    # a name that is either preceded by [Pp]rof./[Dd]oc. and followed by Ph.D.
    # or other name with potential titles
    
    # Captures all expressions before the semicolon (non greedy). Also looks for any match where there are "++", 
    # but a condition is added that if ++ is on the other side, the expression evaluates as false
    pat = re.compile(r'(?<!\+\+)[^;]+(?=\s*[^+])[^;]*\+\+(?!\+\+)(?=;)|([^;]+)(?=;)', re.X)

    return [g1 for g1 in pat.findall(expr_string) if g1]

if __name__ == "__main__":
    import doctest
    doctest.testmod()
