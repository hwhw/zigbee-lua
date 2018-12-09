#!/bin/sh
echo 'local ctx=...; ctx.zigbee.devices:dump_list()'|nc -w 0 localhost 16580
