#!/bin/sh
echo 'local ctx=...; ctx.zigbee:switch("'$1'","'$2'")'|nc -w 0 localhost 16580
