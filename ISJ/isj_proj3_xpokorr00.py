#!/usr/bin/env python3

# ukol za 2 body
def halves_of_even_double_of_odd(numbers: list[int]) -> list[int]:
    """Re-arranges and re-calculates the given list of integers so that
       halves of even numbers will go first, followed by doubles of odd ones

    >>> halves_of_even_double_of_odd([2,4,2,5,6])
    [1, 2, 1, 3, 10]
    >>> halves_of_even_double_of_odd([3,2,0,5,4])
    [1, 0, 2, 6, 10]
    >>> halves_of_even_double_of_odd([2])
    [1]
    >>> halves_of_even_double_of_odd([])
    []
    >>> halves_of_even_double_of_odd([3])
    [6]
    """
    even_list = []
    odd_list = []

    for index in range(len(numbers)):
        if numbers[index] % 2 == 0:
            even_list.append(numbers[index] // 2)
        else:
            odd_list.append(numbers[index] * 2)


    return even_list + odd_list




# ukol za 3 body
def multichoice_scoring(answers: list[int],
                        scoring: list[tuple[int, float, float]]
                        ) -> float:
    """Scores and return the answers to a multi-choice test
       (with exactly one correct answer per question).
       The choices selected by a participant are listed in answers, 
       if there were 3 questions and the participant selected the 1st option 
       for the 1st question, did not answer the second, and took the 2nd option
       for the 3rd question, the input shall correspond to [0, None, 1]
       Parameter scoring corresponds to the list of triples consisting of:
       - identification (index) of the right answer;
       - number of points for the right answer to the question;
       - negative number of points to be counted, if the answer is incorrect.
       Zero points should be given for non-answered questions.
       The answers and scoring lists should have the same length
       (does not need to be tested) and share the ordering of the questions.

    >>> multichoice_scoring([], [])
    0
    >>> multichoice_scoring([3, 4, None, 0], [(2, 3.5, -1.5), (4, 3, -1.5), (2, 2, -1), (0, 2, -1)])
    3.5
    """
    score = 0

    for index in range(len(answers)):
        answer = 0
        if answers[index] == None:
            answer = -1
        else:
            answer = answers[index]

        current_tuple = scoring[index]

        if answer == current_tuple[0]:
            score += current_tuple[1]
        elif answer != -1:
            score += current_tuple[2]
    return score


if __name__ == "__main__":
    import doctest
    doctest.testmod()
