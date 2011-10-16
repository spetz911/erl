#!/bin/bash

TEXT='qwerty u iopas'
#TODO take a split

[ "$1" == "clean" ] && rm -f *.beam *.dump *.log && exit
[ "$1" != "" ] && TEXT="$1"

erlc udp.erl

erl -noshell -s udp client_udp > client.log &
erl -noshell -run udp send_udp "$TEXT" -s erlang halt
erl -noshell -run udp send_udp "Exit" -s erlang halt
ps -A | grep 'smp'

exit

ERL_KEY="-noshell -detached -sname node$1"
ERL_HALT= #"-s erlang halt"

erlc 'test.erl'
erl $ERL_KEY -s test run $ERL_HALT > "/home/oleg/project/$1.txt"
# echo -e -n "\n" >> 1.txt
echo >> "$1.txt"
echo "COMPLETE"
# ps -A | grep 'beam'



