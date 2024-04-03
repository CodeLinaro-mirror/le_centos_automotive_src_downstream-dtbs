#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-2.0+

kernel_version=$(uname -r)
kernel_src=/lib/modules/$kernel_version/build/include

build()
{
	find . -type f -name '*.dts' -print0 | while read -d '' src; do
	        tmp=${src%.dts}.tmp.dts
	        dst=${src%.dts}.dtb
	        cpp -nostdinc -I . -I $kernel_src -undef -x assembler-with-cpp $src > $tmp
	        if test -f $tmp; then
        	        dtc -q -O dtb -b 0 -o $dst $tmp
	        fi
        	rm $tmp
	done
}

clean(){
	find . -type f -name "*.dtb" -delete
	find . -type f -name "*.tmp.dts*" -delete
}

while getopts "bc" option; do
	case ${option} in
		b)
			build
			;;
		c)
			clean
			;;
	esac
done
