#!/system/bin/sh
set -e
# DP103 layout only. Read /system; write only a regular staging image in /data.
[ "$(id -u)" = 0 ] || { echo ROOT_REQUIRED; exit 10; }
[ "$(getprop ro.product.model)" = DP103 ] || { echo WRONG_MODEL; exit 11; }
[ "$(cat /sys/class/block/mmcblk0p11/size)" = 2097152 ] || { echo WRONG_SYSTEM_SIZE; exit 12; }
[ -d /data/local/tmp/dp103-backup-before-google ] || { echo STAGING_DIR_REQUIRED; exit 13; }
[ ! -e /data/local/tmp/dp103-backup-before-google/system.img ] || { echo SNAPSHOT_ALREADY_EXISTS; exit 14; }
snapshot=/data/local/tmp/dp103-backup-before-google/system.img
timeoutflag=/data/local/tmp/dp103-backup-timeout
frozen=0
wd=
cleanup() {
    if [ "$frozen" = 1 ]; then /system/bin/toybox fsfreeze -u /system || true; fi
    if [ -n "$wd" ]; then kill "$wd" 2>/dev/null || true; fi
}
trap cleanup 0 1 2 15
rm -f "$timeoutflag"
/system/bin/toybox fsfreeze -f /system
frozen=1
echo SYSTEM_FROZEN
(
    /system/bin/sleep 90
    echo timeout > "$timeoutflag"
    /system/bin/toybox fsfreeze -u /system
) &
wd=$!
/system/bin/dd if=/dev/block/mmcblk0p11 of="$snapshot" bs=1048576
/system/bin/toybox fsfreeze -u /system
frozen=0
kill "$wd" 2>/dev/null || true
wd=
if [ -e "$timeoutflag" ]; then echo SNAPSHOT_TIMEOUT; exit 1; fi
chmod 600 "$snapshot"
echo SNAPSHOT_READY
/system/bin/md5sum "$snapshot"
