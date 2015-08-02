#!/system/bin/sh

# Workaround for conn_init not copying the updated firmware
# This script was actually taken from mako, which uses the same wifi chip.
rm /data/misc/wifi/WCNSS_qcom_cfg.ini
rm /data/misc/wifi/WCNSS_qcom_wlan_nv.bin

/system/bin/conn_init

echo 1 > /dev/wcnss_wlan
