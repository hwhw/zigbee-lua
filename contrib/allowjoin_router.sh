#!/bin/sh
echo 'local ctx=...; ctx.dongle:allow_join{include={0xFFFC},exclude={0}}'|nc -w 0 localhost 16580
