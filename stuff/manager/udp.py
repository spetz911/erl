#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       udp.py
#       
#       Copyright 2011 Victoria Alexandrovna <oleg@debian>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

import sys
from socket import *

F = open("py.log",'a')

if len(sys.argv) != 2:
	print("hello!", file = F)
else:
	print("hello!", sys.argv[1], file = F)

def main():
	if len(sys.argv) == 1:
		print("not enough args")
		exit(1)
	port = int(sys.argv[1])
	s = socket(AF_INET,SOCK_DGRAM)
	s.bind(("",port))
	while True:
		data, address = s.recvfrom(256)
		print("OK: %s"%str(address), file = F)
		s.sendto(b"ok", address)
	return 0

if __name__ == '__main__':
	main()
