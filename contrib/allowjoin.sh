#!/bin/sh
echo 'local ctx=...; ctx.dongle:allow_join{include={0,0xFFFC}}'|nc -w 0 localhost 16580
