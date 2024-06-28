#!/bin/bash

set -e

for file in \(echo*; do
    mv "$file" "$(echo "$file" | sed 's/(echo //g' | sed 's/#)//g')"
done

echo "all file prefix removed"
