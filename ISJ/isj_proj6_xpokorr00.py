#!/usr/bin/env python3

import collections
from collections import Counter

class ValidationError(Exception):
    pass

def upd_word_counts(sentence: str, word_counts: collections.Counter = None, *, to_upper: bool = False) -> collections.Counter:

    if word_counts is None:
        word_counts = collections.Counter()
    
    # Variable to store the copy of the collection
    result = collections.Counter(word_counts)
    
    if to_upper:
        # If Upper then checking if the values are valid
        for word in word_counts:
            if not word.isupper():
                raise ValidationError("Invalid combination of Uppercase and Lowercase!")
        
        # Split a string to the array
        words = sentence.upper().split()
    else:
        words = sentence.split()
    
    # Update the counter
    result.update(words)
    
    return result
