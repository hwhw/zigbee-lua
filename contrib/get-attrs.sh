#!/bin/bash
exec $(dirname "$0")/cmd.sh "$1" 'get_attributes('"$2"','"$3"')'
