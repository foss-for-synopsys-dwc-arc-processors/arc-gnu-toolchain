#!/bin/bash
set -x

DIRECTORIES="binutils-gdb newlib gcc glibc linux qemu"

for i in ${DIRECTORIES}; do
	if [[ ! -d ./$i ]]
	then
		echo "Skipping $i since directory does not exist."
		continue
	fi

	pushd $i
	ORIGIN_URL=$(git remote -v | grep push | cut -f2 | cut -d' ' -f1)
	HTTPS_REPO=$(echo ${ORIGIN_URL} | grep https | wc -l)
	if test "x${HTTPS_REPO}" = "x1"
	then
		GIT_URL=$(echo ${ORIGIN_URL} | sed "s/https:\/\//git@/g" | sed "s/\//:/")
		#echo $ORIGIN_URL
		#echo $GIT_URL
		git remote rename origin origin_old
		git remote add origin ${GIT_URL}
		git remote remove origin_old
		git fetch --unshallow
	else
		echo "$i has no https repo."
	fi
	popd
done
