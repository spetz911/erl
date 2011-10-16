#!/bin/bash

CONFIG='../XML/config.xml'
ADMIN_PORT=9999
LOG="erl.log"

nc -l $ADMIN_PORT < $CONFIG > nc.log &

erl -noshell -run manager start "127.0.0.1" $ADMIN_PORT -s manager stop # > $LOG &

