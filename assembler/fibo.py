#!/usr/bin/python

a, b, c = 0, 1, 0

print "a b c (fibo ->)"
print a, b, c

for i in range(12):
    c = a + b
    a = b 
    b = c 
    print a, b, c

print "a b c (<- ribo)"

for i in range(12):
    c = b - a
    b = a 
    a = c 
    print a, b, c

