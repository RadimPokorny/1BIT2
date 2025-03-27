#!/usr/bin/env python3


import itertools

digit2chars = {0: '', 1: '', 2: 'abc', 3: 'def', 4: 'ghi', 5: 'jkl', 6: 'mno', 7: 'pqrs', 8: 'tuv', 9: 'wxyz'}

def strs_for_number(number: int, digit2chars: dict[int,str]) -> list[str]:
    """Returns the list of all letter combinations of a (phone) number given as
    input, transforming it accordingly to the digit2chars mapping.

    >>> strs_for_number(23, digit2chars) 
    ['ad', 'ae', 'af', 'bd', 'be', 'bf', 'cd', 'ce', 'cf']

    >>> strs_for_number(543, digit2chars) 
    ['jgd', 'jge', 'jgf', 'jhd', 'jhe', 'jhf', 'jid', 'jie', 'jif', 'kgd', 'kge', 'kgf', 'khd', 'khe', 'khf', 'kid', 'kie', 'kif', 'lgd', 'lge', 'lgf', 'lhd', 'lhe', 'lhf', 'lid', 'lie', 'lif']
    """

    str_components_to_product = [digit2chars[int(d)] for d in str(number) if digit2chars[int(d)]]

    if str_components_to_product == None:
        return []

    return [''.join(combo) for combo in itertools.product(*str_components_to_product)]



words = ['able', 'also', 'area', 'atom', 'back', 'ball', 'bank', 'bear', 'best', 'bird', 'boat', 'book', 'boot', 'both', 'busy', 'cake', 'cave', 'city', 'coat', 'come', 'cool', 'dark', 'dear', 'deer', 'desk', 'doom', 'door', 'down', 'duck', 'dusk', 'easy', 'echo', 'edit', 'ever', 'eyes', 'face', 'fact', 'fast', 'fear', 'fine', 'fire', 'fish', 'food', 'foot', 'frog', 'game', 'gaze', 'gift', 'give', 'gold', 'good', 'hail', 'hair', 'hand', 'harm', 'hate', 'head', 'help', 'hill', 'home', 'hope', 'horn', 'icon', 'idea', 'into', 'iron', 'jail', 'join', 'jump', 'jury', 'just', 'keep', 'kind', 'king', 'knot', 'lamp', 'life', 'like', 'lily', 'lion', 'loud', 'love', 'luck', 'many', 'mars', 'milk', 'mind', 'moon', 'more', 'much', 'name', 'near', 'need', 'nose', 'note', 'once', 'only', 'open', 'over', 'part', 'plan', 'play', 'poor', 'quad', 'quit', 'quiz', 'rain', 'read', 'rich', 'ring', 'road', 'rose', 'same', 'sand', 'self', 'ship', 'shoe', 'shop', 'sign', 'snow', 'sock', 'some', 'song', 'star', 'suit', 'sure', 'talk', 'tall', 'team', 'time', 'tree', 'true', 'undo', 'unit', 'upon', 'used', 'vast', 'very', 'view', 'vote', 'wall', 'wave', 'well', 'wild', 'wind', 'with', 'word', 'work', 'xbox', 'your', 'yard', 'year', 'yell', 'zero', 'zest', 'zone', 'zoom']


from collections import defaultdict


def words_with_same_number(words: list[str],
                           digit2chars: dict[int,str]
                          ) -> dict[int,list[str]]:
    """Returns the dictionary of numbers corresponding to the list of more than
    one word from input list words, according to the digit2chars mapping.

    >>> words_with_same_number(['adhd', 'aids', 'begd', ], digit2chars) 
    {2343: ['adhd', 'begd']}

    >>> words_with_same_number(['ahoj', 'hello'], digit2chars) 
    {}

    >>> words_with_same_number(words, digit2chars)
    {2253: ['able', 'cake'], 2628: ['boat', 'coat'], 2665: ['book', 'cool'], 3327: ['dear', 'fear'], 4263: ['game', 'hand'], 4663: ['good', 'home'], 5683: ['loud', 'love'], 6673: ['more', 'nose'], 7848: ['quit', 'suit'], 7263: ['same', 'sand'], 8255: ['talk', 'tall'], 8733: ['tree', 'used'], 9355: ['well', 'yell']}
    """
       

    # dictionary comprehension associating every possible letter with the
    # corresponding digit (representing as string)
    char2digit_as_str = {ch: str(dg) for dg, chars in digit2chars.items() for ch in chars}

    numb2words = defaultdict(list)
    for w in words:
        numb = int(''.join(char2digit_as_str[ch] for ch in w if ch in char2digit_as_str))
        numb2words[numb].append(w)
        pass     


    # return a new dictionary, formed by the keys of numb2words, transformed
    # from string of digits to integer, if there are more words in the 
    # associated list 
    return {k: alist for k, alist in numb2words.items() if len(alist) >= 2}



if __name__ == "__main__":
    import doctest
    doctest.testmod()
