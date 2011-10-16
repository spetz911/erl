import sys

F = open("py.log",'a')


if len(sys.argv) != 2:
	print("hello!", file = F)
else:
	print("hello!", sys.argv[1], file = F)

