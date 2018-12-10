#!/bin/sh
echo 'local ctx=...; ctx.interfaces.zigbee[1].devices:dump_list()'|nc -w 0 localhost 16580
