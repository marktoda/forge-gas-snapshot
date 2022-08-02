#!/bin/sh

# ffi command syntax doesn't support pipe or redirect shell syntax
# so we have to use this script to write to file

file=$1
data=$2
name=$3
mkdir -p "$(dirname $file)"
echo -n "$data" > "$file"
