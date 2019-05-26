#!/bin/bash
echo 'local ctx,o=...; local U=require"lib.util"; o:write(U.dump(ctx.interfaces.zigbee[1].devices:find("'"$1"'").zcl:'"$2"'))' | nc -N ${ZIGBEELUA:-127.0.0.1} 16580
echo
