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

if [ $variant == "chl" ]; then
	# chl variant uses prebuilt ril blobs
	rm -f /system/bin/rild
	rm -f /system/lib/libril.so
	NFCFILES="app/NfcNci lib/libnfc-nci.so lib/libnfc_nci_jni.so lib/libnfc_ndef.so lib/hw/nfc_nci.pn54x.default.so etc/libnfc-nxp.conf permissions/com.cyanogenmod.nfc.enhanced.xml etc/permissions/com.android.nfc_extras.xml etc/permissions/android.hardware.nfc.xml etc/libnfc-brcm.conf etc/nfcee_access.xml framework/com.android.nfc_extras.jar priv-app/Tag vendor/firmware/libpn547_fw.so"

	for i in $NFCFILES; do
		rm -rf /system/$i
	done
	variant="gsm"
fi

basedir="/system/blobs/$variant/"
cd $basedir
chmod 755 bin/*
find . -type f | while read file; do ln -s $basedir$file /system/$file ; done

# Create modem firmware links based on the currently installed modem
mkdir -p /firmware/radio
busybox mount -o shortname=lower -t vfat /dev/block/platform/msm_sdcc.1/by-name/radio /firmware/radio

if ls /firmware/radio/a7b*.mdt 1> /dev/null 2>&1; then
  base=`ls /firmware/radio/a91*.mdt | sort -r | head -1 | sed "s|.mdt||g"`
elif [ -f "/firmware/radio/mba.mdt" ]; then
  base="/firmware/radio/mba"
fi

ln -s $base.mdt /system/vendor/firmware/mba.mdt
ln -s $base.b00 /system/vendor/firmware/mba.b00

if [ ! -f "/system/vendor/firmware/mba.mdt" ]; then
  exit 1
fi
