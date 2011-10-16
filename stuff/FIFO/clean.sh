#!/bin/bash
[ ! -p rdr ] && mkfifo rdr
[ ! -p ber ] && mkfifo ber
[[ $1 == "all" ]] && rm -f *.beam *.log
rm -f *.dump

ps -A | grep beam.smp | awk '{print $1 }' | xargs echo | xargs -r kill
ps -A | grep beam.smp # if not killed proc

