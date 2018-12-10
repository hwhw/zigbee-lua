#!/bin/sh
echo 'local ctx=...; ctx.interfaces.zigbee[1]:identify"'$1'"'|nc -w 0 localhost 16580
