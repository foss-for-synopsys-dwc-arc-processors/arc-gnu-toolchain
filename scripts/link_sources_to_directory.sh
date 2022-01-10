#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Should provide the directories with the proper sources."
fi

DIRECTORIES="binutils-gdb newlib gcc glibc linux qemu"

for i in ${DIRECTORIES}; do
	if [[ -d ./$i ]]
	then
		echo "Skipping $i since directory exists in $(pwd)"
	fi
	
	if [[ -d $1/$i ]]
	then
		ln -v -s $1/$i ./$i
	else
	      	echo "Destination directory $1/$i does not exist!"
	fi
done

