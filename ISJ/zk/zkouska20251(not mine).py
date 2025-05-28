import re
from collections import Counter
from time import sleep
from time import time
from multiprocessing import Process as Pr
import threading
import asyncio

#3
def upd_counts(sentence,word_counts,to_upper = False):
    if to_upper:
        sentence = sentence.upper()
    
    for word in word_counts:
        if word != word.upper():
            raise ValueError(f"word '{word}' is not upper case")
        
    count = Counter(sentence.split(" "))
    for word in count:
        if word in word_counts:
            word_counts[word] += count[word]
        else:
            word_counts[word] = count[word]

    return word_counts
#4
class TimeSeriesDB(dict):
    def __setitem__(self, key, pair):
        timestamp, value = pair
        if key not in self:
            super().__setitem__(key, [])
        super().__getitem__(key).append((timestamp, value))

    def __getitem__(self, key):
        if not isinstance(key, tuple) or len(key) != 2:
            raise KeyError("Key must be a tuple of (name, timestamp)")

        real_key, target_ts = key
        data = super().get(real_key, [])
        if not data:
            return None

        # binární vyhledávání nejlepší hodnoty (největší timestamp <= target_ts)
        left, right = 0, len(data) - 1
        best_val = None
        while left <= right:
            mid = (left + right) // 2
            ts, val = data[mid]
            if ts <= target_ts:
                best_val = val  # uchováme kandidáta
                left = mid + 1  # hledáme větší
            else:
                right = mid - 1  # zmenšujeme rozsah

        return best_val

#5
def work_sleep():
    for i in range(10000): sleep(0)

def work_i_square():
    lst = [i*i for i in range(1000000)]

async def a_work_sleep():
    for i in range(10000): sleep(0)

async def a_work_i_square():
    lst = [i*i for i in range(1000000)]

def use_multiprocessing(w):
    tasks =[Pr(target=w) for _ in range(100)]
    for task in tasks: task.start()
    for task in tasks: task.join()

async def use_asyncio(w):
    tasks = [asyncio.create_task(w()) for _ in range(100)]
    await asyncio.gather(*tasks)

#6
class A:
    def __init__(self):
        print('init A')

    def tst(self):
        print('in A')
        super().tst()
        print('out A')

class B:
    def tst(self):
        print('in B')
        super().tst()
        print('out B')

class C(A):
    def __init__(self):
        print('init C')
        super().__init__()

    def tst(self):
        print('in C')
        super().tst()
        print('out C')

class D(A):
    def tst(self):
        print('in D')
        super().tst()
        print('out D')

class E(D):
    def tst(self):
        print('in E')
        super().tst()
        print('out E')

class F(D):
    def tst(self):
        print('in F')
        super().tst()
        print('out F')

class G(B):
    def tst(self):
        print('in G')
        super().tst()
        print('out G')

class H(B):
    def tst(self):
        print('no super in H')

class I(B):
    def tst(self):
        print('in I')
        super().tst()
        print('out I')

class J(C, E, F, G, H, I):
    pass

#8
def first_with_given_func(iterable, func= lambda x: x):
    seen = []
    for item in iterable:
        k = func(item)
        if k not in seen:
            seen.append(k)
            yield item

#9
def any_append(boolval,inp=[]):
    inp.append(boolval)
    return any(inp)

#10
def digits_mersenne(limit,subt):
    for p in range(limit):
        yield len(str(2**p -subt))

#11
class Z5(int):
    def __new__(cls,value):
        return super().__new__(cls,value % 5) 
def main():
    print(f"#1 Prvni priklad:")
    
    text = '12 -5 345 -18 9 4mm 25' # $12 -5 $345 -18 $9 4mm $25
    pat = r'(?<![-\w])(?=\d+\b)'  
    print(re.sub(pat, '$', text))

    print(f"\n\n#2 Druhy priklad:")

    m = {'My':2,'iP':12,'No':34,'no':56,'Ip':7,'NO':8,'my':9}
    freq = {k: sum(v for x, v in m.items() if x.upper() == k) for k in sorted({k.upper() for k in m}, key=lambda k: sum(v for x, v in m.items() if x.upper() == k))}
    print(freq)

    print(f"\n\n#3 Treti priklad:")
    #trida je deklarovana nahore
    sentence = "My iP No no Ip NO my"
    word_counts = {'MY': 2, 'IP': 12, 'NO': 34}
    print(upd_counts(sentence, word_counts, to_upper=True))
    #print(upd_counts(sentence, word_counts, to_upper=False)) funguje i pro mala pismena?????? asi to tak ma byt

    print(f"\n\n#4 Ctvrty priklad:")
    #trida je deklarovana nahore
    db = TimeSeriesDB()
    db["temp"] = (1, 100)
    db["temp"] = (5, 200)
    db["temp"] = (3, 300)

    print(db["temp", 0])  # None
    print(db["temp", 1])  # 100
    print(db["temp", 4])  # 100
    print(db["temp", 5])  # 300

    print(f"\n\n#5 Paty priklad:")
    # cas = time()
    # for a_w in (a_work_sleep, a_work_i_square):
    #     asyncio.run(use_asyncio(a_w))
    # print(f"Asyncio cas: {time() - cas:.2f} sec")
    
    print(f"\n\n#6 Sesty priklad:")
    j = J()
    j.tst()

    print(f"\n\n#7 Sedmy priklad:")
    tests = ['He Li Be Ne Na Mg','He Li Be Mg']
    for test in tests:
        print(re.search(r'^.*\b(Li|He|Na)\b.*$', test).group(1))

    print("\n\n#8 Osmy priklad:")
    #trida je deklarovana nahore
    print(tuple(first_with_given_func([[1],[2,3],[4],[5,6,7],[8,9]], len)))
    print(tuple(first_with_given_func([[1],[2,3],[4]])))

    print("\n\n#9 Devaty priklad:")
    #trida je deklarovana nahore
    print(any_append(True))
    print(any_append('',[0,False]))
    print(any_append(False))
    print(any_append(set(['']),[0]))

    print("\n\n#10 Desaty priklad:")
    #trida je deklarovana nahore
    dn = digits_mersenne(5,1)
    print(2 in dn, 1 in dn)
    print(list(digits_mersenne(5,1)))

    print("\n\n#11 Jedenacty priklad:")
    #trida je deklarovana nahore
    print(Z5(7))
if __name__ == "__main__":
    main()