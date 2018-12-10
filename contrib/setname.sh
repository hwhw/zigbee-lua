#!/bin/sh
echo 'local ctx=...; ctx.interfaces.zigbee[1].devices:setname("'$1'","'$2'")'|nc -w 0 localhost 16580
