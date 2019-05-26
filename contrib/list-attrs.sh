#!/bin/bash
exec $(dirname "$0")/cmd.sh "$1" 'get_attribute_list('"$2"')'
