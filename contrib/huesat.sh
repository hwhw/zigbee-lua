#!/bin/sh
echo 'local ctx=...; ctx.interfaces.zigbee[1]:hue_sat("'$1'",'$2','$3')'|nc -w 0 localhost 16580
