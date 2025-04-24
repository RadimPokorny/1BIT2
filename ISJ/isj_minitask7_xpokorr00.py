class Point:
    def __init__(self, x=0, y=0):
        self.x = x
        self.y = y

    def __sub__(self, other):
        return Point(self.x - other.x, self.y - other.y)

    def __repr__(self): 
        return f"Point({self.x},{self.y})"

p0 = Point()
print(p0) # should be: Point(0,0)
p1 = Point(3, 4)
result = p0-p1
print(result) # should be: Point(-3,-4)
