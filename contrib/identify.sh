#!/bin/sh
echo 'local ctx=...; ctx.zigbee:identify"'$1'"'|nc -w 0 localhost 16580
