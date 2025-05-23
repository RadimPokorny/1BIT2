def digits_mersenne(limit, subt):
    for p in range(limit):
        yield len(str(2**p - subt))
dn = digits_mersenne(5,1)
print(2 in dn, 1 in dn)
print(list(digits_mersenne(5,1)))