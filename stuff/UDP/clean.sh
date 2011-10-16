#!/bin/bash
ps -A | grep beam.smp| awk '{print $1 }' | xargs echo | xargs -r kill

