#!/bin/sh
echo 'require"interfaces.zigbee.any":new{id="'$1'"}:'$2 | nc -N localhost 16580
