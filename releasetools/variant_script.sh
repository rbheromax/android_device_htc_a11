#!/sbin/sh

set -e

modelid=`getprop ro.boot.mid`

case $modelid in
	0PCV10000|0PCV20000)		variant="chl" ;;
	*)				variant="gsm" ;;
esac

if [ $variant == "gsm" ]; then		
	# remove prebuilt ril blobs		
	rm -rf /system/blobs/gsm/lib		
	rm -f /system/blobs/gsm/bin/rild		
fi

basedir="/system/blobs/$variant/"
cd $basedir
chmod 755 bin/*
find . -type f | while read file; do ln -s $basedir$file /system/$file ; done
