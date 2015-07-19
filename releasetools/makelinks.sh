#!/sbin/sh

set -e

modelid=`getprop ro.boot.mid`

case $modelid in
	OPCV1000|OPCV2000)		variant="chl" ;;
	*)				variant="gsm" ;;
esac

if [ $variant == "gsm" ]; then
	# remove prebuilt ril blobs
	rm -rf /system/blobs/gsm/lib
	rm -f /system/blobs/gsm/bin/rild
fi

if [ $variant == "chl" ]; then
	# I think we should remove nothing for now and call it good. :)

	for i in $NFCFILES; do
		rm -rf /system/$i
	done
	variant="gsm"
fi

basedir="/system/blobs/$variant/"
cd $basedir
chmod 755 bin/*
find . -type f | while read file; do ln -s $basedir$file /system/$file ; done
