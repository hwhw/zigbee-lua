#!/bin/sh
echo 'local ctx=...; ctx.zigbee.devices:setname("'$1'","'$2'")'|nc -w 0 localhost 16580
