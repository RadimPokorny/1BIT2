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

    pat = re.compile(r'''
                            ^             # from the begining of the string 
                            ...   # there are only small ASCII letters till the end
                            ...    # and they match non-vowels characters
                            $             # to the end of the string 
                     ''', re.VERBOSE)
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
    pat = re.compile(r'''
                      ...  # it is either the non-captured form
                                       # preceded and followed by ++
                      |                # or
                      ...         # it is the captured expression
                      ''', re.X)
    return [g1 for g1 in pat.findall(expr_string) if g1]


if __name__ == "__main__":
    import doctest
    doctest.testmod()
