#!/bin/bash
echo 'local ctx,o=...; local U=require"lib.util"; o:write(U.dump(require"interfaces.zigbee.any":new{id="'"$1"'"}:'"$2"'))' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
