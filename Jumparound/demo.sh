#!/bin/bash

echo -e "\033[1;31mLet's check file's format\033[0m"
file jumparound
sleep 2
echo -e "\033[1;31mWe could search for interesting ascii-encoded strings in binary with help of strings\033[0m"
sleep 2
strings jumparound | grep -v "^.*_.*" | grep -E "^Well.*$"
echo -e "\033[1;31mGet absolute loc\033[0m"
sleep 2
echo "python -c 'a="Well"; print a.encode("hex")'"
python -c 'a="Well"; print a.encode("hex")'
sleep 2
echo "od -A x -t x1 ./jumparound | grep '57 65 6c 6c' "
od -A x -t x1 ./jumparound | grep "57 65 6c 6c" 
