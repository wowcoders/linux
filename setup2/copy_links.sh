#!/bin/bash

main () {
	src_path=`realpath $1`

	cd $2

	echo "copying links(with target $3) from $src_path ... to $2"

	for i in $(find -L $src_path -samefile $3); do
		lname=${i/${src_path}\//}
		ln -sf -T /bin/busybox $lname
	done
}

usage() {
	echo 'copy_link <src> <dst> <tgt-file>'
}

if [ "$#" -ne 3 ]; then
    usage
    exit 2
fi

main "$@"
