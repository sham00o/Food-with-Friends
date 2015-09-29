#!/usr/bin/python

import math

for i in range(100,1,-1):
    i = 1
    a = i + 1 + 3 + 4
    while a < 20:
        a = 4 + 1*math.ceil(a/4) + i*math.ceil(a/6) + 3*math.ceil(a/10)
        print a
    print i
