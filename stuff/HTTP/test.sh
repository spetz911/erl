#!/bin/bash
erlc -Wall scripts.erl

erl -noshell -config test -s inets

