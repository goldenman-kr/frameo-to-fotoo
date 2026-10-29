#!/bin/bash
# Installs only the three final user apps. No root/system/reboot operations.
set -eu
cd "$(dirname "$0")"
ADB="${ADB:-$PWD/tools/macos/adb}"
SERIAL="${SERIAL:?기기 serial을 먼저 지정하세요. 예: export SERIAL=YOUR_DEVICE_SERIAL}"
if [ "$("$ADB" -s "$SERIAL" get-state)" != "device" ]; then
    echo "대상 기기가 ADB device 상태가 아닙니다."
    exit 1
fi
release=$("$ADB" -s "$SERIAL" shell getprop ro.build.version.release | tr -d '\r')
abi=$("$ADB" -s "$SERIAL" shell getprop ro.product.cpu.abi | tr -d '\r')
model=$("$ADB" -s "$SERIAL" shell getprop ro.product.model | tr -d '\r')
if [ "$release" != '6.0.1' ] || [ "$abi" != 'armeabi-v7a' ] || [ "$model" != 'DP103' ]; then
    echo '이 묶음의 검증 대상 DP103 / Android 6.0.1 / ARMv7과 다릅니다. 설치하지 않았습니다.'
    exit 1
fi
"$ADB" -s "$SERIAL" install -r apps/nova/Nova-6.2.19.apk
"$ADB" -s "$SERIAL" install -r apps/floating-home/FloatingHome-1.4.apk
"$ADB" -s "$SERIAL" install-multiple -r \
    apps/fotoo-2.6.5-armv7/com.bo.fotoo.apk \
    apps/fotoo-2.6.5-armv7/config.armeabi_v7a.apk \
    apps/fotoo-2.6.5-armv7/config.en.apk \
    apps/fotoo-2.6.5-armv7/config.ko.apk \
    apps/fotoo-2.6.5-armv7/config.xxhdpi.apk
printf '\nAPK 설치 완료. 단말에서 표시 권한, Nova 기본 홈, Google 로그인과 Fotoo 구매 복원을 설정하세요.\n'
