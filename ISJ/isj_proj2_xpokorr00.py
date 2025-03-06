#!/usr/bin/env python3

#ukol za 2 body
def secret_translator(input: str) -> str:
    """Reverses the input string and tanslates it using the translate function

    >>> secret_translator('jbf znxkbbl eja uby znxjcm ehc cbn mx mxhT')
    'This is not the string you are looking for'
    """

    key_in = 'bzxjcm'
    key_out = 'ogirts'
    transf = str.maketrans(key_in, key_out)

    reversed_in = input[::-1]         # reverse the input string
    out = reversed_in.translate(transf)      # translate it using the transf key

    return out

#ukol za 3 body
def string_scrambler(input: str) -> str:
    """Removes the (optional) comments begining after the first #,
        splits the string into words,
        takes every second word starting from the third and ending 2 words
        from the end and joins them into a string using '; ' as a separator


        >>> string_scrambler('Lorem ipsum dolor sit amet consectetur adipiscing elit Donec quis purus vitae est vestibulum euismod eget rutrum nibh Mauris eu ullamcorper nisl Nulla eget nulla a lacus faucibus mollis et efficitur libero#TODO #write something original')
        'sit; consectetur; elit; quis; vitae; vestibulum; eget; nibh; eu; nisl; eget; a; faucibus; et'

        >>> string_scrambler('Curabitur sit amet nisi enim Donec in pulvinar sapien id tempus ligula Donec pellentesque elit in lorem interdum sodales Donec aliquam augue a orci bibendum luctus Sed tempor nunc aliquet rhoncus scelerisque Sed sagittis leo bibendum tortor malesuada maximus Proin vehicula mauris at facilisis dapibus justo sem finibus nisl dapibus venenatis erat lorem a tellus') 
        'nisi; Donec; pulvinar; id; ligula; pellentesque; in; interdum; Donec; augue; orci; luctus; tempor; aliquet; scelerisque; sagittis; bibendum; malesuada; Proin; mauris; facilisis; justo; finibus; dapibus; erat'
    """

    target_str = input.split("#")[0]             # take only the part before the comment
    str_list = target_str.split(' ')          # split on space
    skipped = str_list[3:-2:2]              # take every second, starting with the 3rd, to the last but two
    out = "; ".join(skipped)                  # join everything from the list using '; '
    return out

if __name__ == "__main__":
    import doctest
    doctest.testmod()
