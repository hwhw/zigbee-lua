#!/bin/sh
echo 'local ctx=...; ctx.zigbee:ctemp("'$1'",'$2')'|nc -w 0 localhost 16580
