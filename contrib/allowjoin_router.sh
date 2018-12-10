#!/bin/sh
echo 'local ctx=...; ctx.interfaces.zigbee[1].dongle:allow_join{include={0xFFFC},exclude={0}}'|nc -w 0 localhost 16580
