#!/bin/bash
echo 'local ctx,o=...; ctx.interfaces.zigbee[1].devices:dump_list(function(w) o:write(w) end)' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
