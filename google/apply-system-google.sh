#!/system/bin/sh
set -e
[ "$(id -u)" = 0 ] || exit 10
stage=/data/local/tmp/dp103-google-system-stage
[ ! -e /system/priv-app/GoogleServicesFramework ] || exit 11
[ -s "$stage/GoogleServicesFramework/GoogleServicesFramework.apk" ] || exit 12
[ ! -e /system/priv-app/GoogleLoginService ] || exit 11
[ -s "$stage/GoogleLoginService/GoogleLoginService.apk" ] || exit 12
[ ! -e /system/priv-app/PrebuiltGmsCore ] || exit 11
[ -s "$stage/PrebuiltGmsCore/PrebuiltGmsCore.apk" ] || exit 12
[ ! -e /system/priv-app/Phonesky ] || exit 11
[ -s "$stage/Phonesky/Phonesky.apk" ] || exit 12
with_rw() {
  tries=0
  while [ "$tries" -lt 5 ]; do
    /system/bin/mount -o remount,rw /system || return 1
    if "$@"; then return 0; fi
    tries=$((tries + 1))
    /system/bin/sleep 1
  done
  return 1
}
ok=0
cleanup() {
  if [ "$ok" != 1 ]; then
    with_rw rm -rf /system/priv-app/GoogleServicesFramework || true
    with_rw rm -rf /system/priv-app/GoogleLoginService || true
    with_rw rm -rf /system/priv-app/PrebuiltGmsCore || true
    with_rw rm -rf /system/priv-app/Phonesky || true
  fi
  /system/bin/mount -o remount,ro /system
}
trap cleanup 0
trap 'exit 130' 1 2 15
with_rw mkdir -p /system/priv-app/GoogleServicesFramework
with_rw chmod 755 /system/priv-app/GoogleServicesFramework
with_rw mkdir -p /system/priv-app/GoogleLoginService
with_rw chmod 755 /system/priv-app/GoogleLoginService
with_rw mkdir -p /system/priv-app/PrebuiltGmsCore
with_rw chmod 755 /system/priv-app/PrebuiltGmsCore
with_rw mkdir -p /system/priv-app/Phonesky
with_rw chmod 755 /system/priv-app/Phonesky
with_rw mkdir -p /system/priv-app/GoogleLoginService
with_rw chmod 755 /system/priv-app/GoogleLoginService
with_rw mkdir -p /system/priv-app/GoogleServicesFramework
with_rw chmod 755 /system/priv-app/GoogleServicesFramework
with_rw mkdir -p /system/priv-app/Phonesky
with_rw chmod 755 /system/priv-app/Phonesky
with_rw mkdir -p /system/priv-app/Phonesky/lib
with_rw chmod 755 /system/priv-app/Phonesky/lib
with_rw mkdir -p /system/priv-app/Phonesky/lib/arm
with_rw chmod 755 /system/priv-app/Phonesky/lib/arm
with_rw mkdir -p /system/priv-app/PrebuiltGmsCore
with_rw chmod 755 /system/priv-app/PrebuiltGmsCore
with_rw mkdir -p /system/priv-app/PrebuiltGmsCore/lib
with_rw chmod 755 /system/priv-app/PrebuiltGmsCore/lib
with_rw mkdir -p /system/priv-app/PrebuiltGmsCore/lib/arm
with_rw chmod 755 /system/priv-app/PrebuiltGmsCore/lib/arm
with_rw cp /data/local/tmp/dp103-google-system-stage/GoogleLoginService/GoogleLoginService.apk /system/priv-app/GoogleLoginService/GoogleLoginService.apk
with_rw chmod 644 /system/priv-app/GoogleLoginService/GoogleLoginService.apk
with_rw chown 0:0 /system/priv-app/GoogleLoginService/GoogleLoginService.apk
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/Phonesky.apk /system/priv-app/Phonesky/Phonesky.apk
with_rw chmod 644 /system/priv-app/Phonesky/Phonesky.apk
with_rw chown 0:0 /system/priv-app/Phonesky/Phonesky.apk
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libphonesky_data_loader.so /system/priv-app/Phonesky/lib/arm/libphonesky_data_loader.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libphonesky_data_loader.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libphonesky_data_loader.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libmappedcountercacheversionjni.so /system/priv-app/Phonesky/lib/arm/libmappedcountercacheversionjni.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libmappedcountercacheversionjni.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libmappedcountercacheversionjni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libempty_armeabi-v7a.so /system/priv-app/Phonesky/lib/arm/libempty_armeabi-v7a.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libempty_armeabi-v7a.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libempty_armeabi-v7a.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libcronet.98.0.4758.34.so /system/priv-app/Phonesky/lib/arm/libcronet.98.0.4758.34.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libcronet.98.0.4758.34.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libcronet.98.0.4758.34.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libgame_sdk_device_info_jni.so /system/priv-app/Phonesky/lib/arm/libgame_sdk_device_info_jni.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libgame_sdk_device_info_jni.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libgame_sdk_device_info_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libconscrypt_jni.so /system/priv-app/Phonesky/lib/arm/libconscrypt_jni.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libconscrypt_jni.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libconscrypt_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libnnapi_device_enumeration_minimal.so /system/priv-app/Phonesky/lib/arm/libnnapi_device_enumeration_minimal.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libnnapi_device_enumeration_minimal.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libnnapi_device_enumeration_minimal.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libbrotli.so /system/priv-app/Phonesky/lib/arm/libbrotli.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libbrotli.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libbrotli.so
with_rw cp /data/local/tmp/dp103-google-system-stage/Phonesky/lib/arm/libtensorflowlite_jni.so /system/priv-app/Phonesky/lib/arm/libtensorflowlite_jni.so
with_rw chmod 644 /system/priv-app/Phonesky/lib/arm/libtensorflowlite_jni.so
with_rw chown 0:0 /system/priv-app/Phonesky/lib/arm/libtensorflowlite_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/GoogleServicesFramework/GoogleServicesFramework.apk /system/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
with_rw chmod 644 /system/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
with_rw chown 0:0 /system/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/PrebuiltGmsCore.apk /system/priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libvcdiffjni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libvcdiffjni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libvcdiffjni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libvcdiffjni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libgmscore.so /system/priv-app/PrebuiltGmsCore/lib/arm/libgmscore.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libgmscore.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libgmscore.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libconscrypt_gmscore_jni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libconscrypt_gmscore_jni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libconscrypt_gmscore_jni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libconscrypt_gmscore_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libgcastv2_support.so /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_support.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_support.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_support.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libbrotli_native.so /system/priv-app/PrebuiltGmsCore/lib/arm/libbrotli_native.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libbrotli_native.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libbrotli_native.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libsemanticlocation_inference_jni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libsemanticlocation_inference_jni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libsemanticlocation_inference_jni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libsemanticlocation_inference_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libgoogle-ocrclient-v3.so /system/priv-app/PrebuiltGmsCore/lib/arm/libgoogle-ocrclient-v3.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libgoogle-ocrclient-v3.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libgoogle-ocrclient-v3.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libjgcastservice.so /system/priv-app/PrebuiltGmsCore/lib/arm/libjgcastservice.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libjgcastservice.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libjgcastservice.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libleveldbjni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libleveldbjni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libleveldbjni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libleveldbjni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libwearable-selector.so /system/priv-app/PrebuiltGmsCore/lib/arm/libwearable-selector.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libwearable-selector.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libwearable-selector.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libsslwrapper_jni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libsslwrapper_jni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libsslwrapper_jni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libsslwrapper_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libWhisper.so /system/priv-app/PrebuiltGmsCore/lib/arm/libWhisper.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libWhisper.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libWhisper.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libtensorflowlite_jni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libtensorflowlite_jni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libtensorflowlite_jni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libtensorflowlite_jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libinertial-anchor-jni.so /system/priv-app/PrebuiltGmsCore/lib/arm/libinertial-anchor-jni.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libinertial-anchor-jni.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libinertial-anchor-jni.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libjingle_peerconnection_so.so /system/priv-app/PrebuiltGmsCore/lib/arm/libjingle_peerconnection_so.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libjingle_peerconnection_so.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libjingle_peerconnection_so.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libgcastv2_base.so /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_base.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_base.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_base.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libAppDataSearch.so /system/priv-app/PrebuiltGmsCore/lib/arm/libAppDataSearch.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libAppDataSearch.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libAppDataSearch.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libgeller_jni_lite_lib.so /system/priv-app/PrebuiltGmsCore/lib/arm/libgeller_jni_lite_lib.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libgeller_jni_lite_lib.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libgeller_jni_lite_lib.so
with_rw cp /data/local/tmp/dp103-google-system-stage/PrebuiltGmsCore/lib/arm/libmatching.so /system/priv-app/PrebuiltGmsCore/lib/arm/libmatching.so
with_rw chmod 644 /system/priv-app/PrebuiltGmsCore/lib/arm/libmatching.so
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore/lib/arm/libmatching.so
with_rw chown 0:0 /system/priv-app/GoogleServicesFramework
with_rw /system/bin/restorecon -R /system/priv-app/GoogleServicesFramework
with_rw chown 0:0 /system/priv-app/GoogleLoginService
with_rw /system/bin/restorecon -R /system/priv-app/GoogleLoginService
with_rw chown 0:0 /system/priv-app/PrebuiltGmsCore
with_rw /system/bin/restorecon -R /system/priv-app/PrebuiltGmsCore
with_rw chown 0:0 /system/priv-app/Phonesky
with_rw /system/bin/restorecon -R /system/priv-app/Phonesky
/system/bin/mount -o remount,ro /system
actual=$(/system/bin/sha1sum /system/priv-app/GoogleLoginService/GoogleLoginService.apk)
set -- $actual
[ "$1" = 3b283da8de3107280cd4c61bfb8d1be205d2dee7 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/Phonesky.apk)
set -- $actual
[ "$1" = d7dca864d569a374f84af54eb71f7a56c6fdcf38 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libphonesky_data_loader.so)
set -- $actual
[ "$1" = 6a900e25f51c4d154835d01b1db20b1c7c2ffd33 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libmappedcountercacheversionjni.so)
set -- $actual
[ "$1" = 43ba85682ffdf23bbe4a5badb2094f69a0854c84 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libempty_armeabi-v7a.so)
set -- $actual
[ "$1" = d7e76bd981fdc1af598019b174a76d9cfd8df58c ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libcronet.98.0.4758.34.so)
set -- $actual
[ "$1" = a24752e613ad8c8ab7a284b02e213a5c61b06c56 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libgame_sdk_device_info_jni.so)
set -- $actual
[ "$1" = 5281aeabe7ae387d672ab835dfd1776f97d98d6d ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libconscrypt_jni.so)
set -- $actual
[ "$1" = bd12db4bf2754e25b91504fc5c101daeda212823 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libnnapi_device_enumeration_minimal.so)
set -- $actual
[ "$1" = 9b1abd049c5ff182f2d422bedaff80dca5cd18fe ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libbrotli.so)
set -- $actual
[ "$1" = a49530971250cfcd31ab90ef200d8a96f36a6550 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/Phonesky/lib/arm/libtensorflowlite_jni.so)
set -- $actual
[ "$1" = fe471fcd102b1574a6bddc9f43952171515296d4 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/GoogleServicesFramework/GoogleServicesFramework.apk)
set -- $actual
[ "$1" = 7978fba72554f4d451673b3d1c369aca1f273fbc ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/PrebuiltGmsCore.apk)
set -- $actual
[ "$1" = 3795207eff12da1c32b03d33c1e0259eacca2f7b ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libvcdiffjni.so)
set -- $actual
[ "$1" = f6dfee9ed5d648671c840cbfdba27a396732ae5c ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libgmscore.so)
set -- $actual
[ "$1" = a9558885260cce3e4bf1a938663b4c2cad06503f ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libconscrypt_gmscore_jni.so)
set -- $actual
[ "$1" = 8761b0e8ea9a6176ad15e17482905d39f98e7651 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_support.so)
set -- $actual
[ "$1" = e774be8cd8678ffd7423cc13c47e2523bab38239 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libbrotli_native.so)
set -- $actual
[ "$1" = 72340d880e2f0f66ec05e65dbd6bea19ff3a074d ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libsemanticlocation_inference_jni.so)
set -- $actual
[ "$1" = 1d5ca1a4619a6b29ffe382e9b58697d8543cb53a ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libgoogle-ocrclient-v3.so)
set -- $actual
[ "$1" = 548eb8f242715969fcf939141ff020e29a6114fb ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libjgcastservice.so)
set -- $actual
[ "$1" = 211228d3713ab75e1caf7b4ccf932b1edcaf2874 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libleveldbjni.so)
set -- $actual
[ "$1" = c5bbc15d0ab216ad75881b3ebc26663712815f03 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libwearable-selector.so)
set -- $actual
[ "$1" = a665a80a3f4b242215fdd05b4324fbdb7e259a4c ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libsslwrapper_jni.so)
set -- $actual
[ "$1" = 4961697f89186d7e20373a47fb0c2ff4fa7bc1cb ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libWhisper.so)
set -- $actual
[ "$1" = a0bad6f3f0efc1c91b1dd2f5e86065bdc389daa1 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libtensorflowlite_jni.so)
set -- $actual
[ "$1" = 4001779c48d46a7a96ce5127555d8b8bf14a856f ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libinertial-anchor-jni.so)
set -- $actual
[ "$1" = 87043f94d2e23b55606aad6a02a4ee9c39d1ed73 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libjingle_peerconnection_so.so)
set -- $actual
[ "$1" = a824d2cb5e2a23d9adf0c52640a330905f76142e ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libgcastv2_base.so)
set -- $actual
[ "$1" = e69c458909349d03d46a8dc1cc89606ce044de8f ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libAppDataSearch.so)
set -- $actual
[ "$1" = f40c6dd15816618f494b2b3c6e9d13574324e3f1 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libgeller_jni_lite_lib.so)
set -- $actual
[ "$1" = ea54cd50a47a63d04a7cf3b081f6e080234243f0 ] || exit 15
actual=$(/system/bin/sha1sum /system/priv-app/PrebuiltGmsCore/lib/arm/libmatching.so)
set -- $actual
[ "$1" = 923accf7dbb04b803df2ed2646ea0bc3086b486c ] || exit 15
ok=1
echo SYSTEM_GOOGLE_FILES_VERIFIED_32
