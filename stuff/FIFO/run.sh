#!/bin/bash

erlc fifo.erl  # [ f1 -ot f2 ]   файл f1 более старый, чем f2

./clean.sh
cat rdr &
cat ber &

erl -noshell -sname rdr -s fifo send2io >> rdr &
erl -noshell -sname ber -s fifo send2io >> ber &
sleep 1
erl -detached -sname kuku -run fifo server 'fifo_d.log' -s erlang halt 

# ./clean.sh
# ps -A | grep 'smp'


