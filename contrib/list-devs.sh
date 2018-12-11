#!/bin/sh
echo 'local ctx,o=...; ctx.interfaces.zigbee[1].devices:dump_list(function(w) o:write(w) end)' | nc -N localhost 16580
