# Frameo → Fotoo (DP103)

Frameo 액자를 **기존 Android 그대로 Fotoo + Nova Launcher + Floating Home으로 사용하는 방법**입니다. 다른 PC에서도 이 저장소를 받아 같은 구성을 설치할 수 있도록 실제 사용한 APK, Google 구성 파일, macOS ADB와 설치 스크립트를 포함했습니다. 별도 Release 다운로드는 필요하지 않습니다.

OS 교체나 펌웨어 플래싱은 하지 않습니다. 기존 Frameo는 보존하고 Nova를 기본 홈으로 사용합니다.

## 확인된 환경

| 항목 | 구성 |
| --- | --- |
| 액자 | DP103 / Rockchip RK3126C |
| OS / ABI | Android 6.0.1 (API 23) / ARM 32비트 `armeabi-v7a` |
| 액자 앱 | Fotoo 2.6.5, ARMv7 분할 APK |
| 기본 홈 | Nova Launcher 6.2.19 |
| 조작 버튼 | Floating Home 1.4, 이 작업에서 제작 |
| Google 계정 / Fotoo 프리미엄 | 실제 로그인·구매 복원 사용자 확인 완료 (2026-10-29) |
| 기존 루트 권한 | 이 단말의 `su` 사용 가능; 새 루팅은 수행하지 않음 |

Google 시스템 통합 후 정상 재부팅을 확인했습니다. Floating Home 1.4의 자동 시작은 앱에 지정한 부팅 완료 신호로 확인했으며, **최신 버튼 앱 설치 후 실제 재부팅 시험은 하지 않았습니다.**

이 구성은 위 단말에서 확인한 버전 조합입니다. 다른 Android·보드에 Google 시스템 파일을 그대로 적용하지 마세요.

## 1. 순정 Frameo에서 ADB 액세스 켜기

**PC 작업보다 먼저 액자 화면에서 진행합니다.**

1. Frameo 앱이 표시된 화면을 터치합니다.
2. 화면을 터치하면 보이는 **설정**을 누릅니다.
3. **소개**로 들어갑니다.
4. **ADB 액세스**를 켭니다.

> Frameo 앱 → 화면 터치 → 설정 → 소개 → ADB 액세스 **켜기**

이 절차를 완료하면 USB 케이블을 통해 PC에서 ADB로 접근하여 이후 설치 작업을 수행할 수 있습니다.

## 2. 다른 PC에 저장소 준비

```bash
git clone https://github.com/goldenman-kr/frameo-to-fotoo.git
cd frameo-to-fotoo
```

APK와 라이브러리는 저장소에 일반 파일로 들어 있습니다. Git LFS나 별도 Release는 필요하지 않습니다.

### ADB가 없는 경우

ADB는 [공식 Android SDK Platform-Tools 다운로드 페이지](https://developer.android.com/tools/releases/platform-tools)에서 해당 OS의 ZIP을 받아 압축 해제하면 사용할 수 있습니다. Android Studio 전체를 설치할 필요는 없습니다. `platform-tools` 폴더 전체를 유지하세요. Windows에서는 `adb.exe`와 함께 제공되는 DLL도 필요합니다. 아래처럼 실행 파일 경로를 지정하면 PATH 등록은 생략할 수 있습니다.

Git이 없다면 저장소의 **Code → Download ZIP**으로 받아 압축을 풀고, 터미널의 현재 위치를 저장소 폴더로 옮겨도 됩니다.

### OS와 셸 선택

아래 본문의 `bash` 코드 블록은 **macOS 터미널·Linux Bash·Windows Git Bash** 기준입니다. 변수 설정과 이후 명령은 같은 터미널에서 실행합니다.

| PC 환경 | 준비 및 차이 |
| --- | --- |
| macOS | 저장소에 포함된 `tools/macos/adb`를 바로 사용하거나 공식 macOS Platform-Tools를 사용합니다. |
| Linux | 공식 Linux Platform-Tools를 받습니다. USB 접근 권한 오류가 나면 배포판의 Android/udev 설정을 확인합니다. |
| Windows + Git Bash | 공식 Windows Platform-Tools를 받습니다. 아래 경로 예시와 `MSYS_NO_PATHCONV` 설정 후 본문의 Bash 명령과 설치 도우미를 사용할 수 있습니다. |
| Windows + PowerShell | 공식 Windows Platform-Tools를 받습니다. 아래 PowerShell 예시와 명령 변환 표를 사용합니다. `.command` 도우미는 직접 실행하지 않고 ADB 설치 명령을 수행합니다. |

Windows에서 USB 장치가 ADB로 잡히지 않으면 장치 관리자의 드라이버 상태를 확인합니다. 필요한 경우 기기에 맞는 제조사 ADB 드라이버를 사용합니다. [Google USB Driver는 Google 기기용](https://developer.android.com/studio/run/win-usb)이므로 이 Rockchip 액자와 호환된다고 가정하지 않습니다. macOS·Linux에는 Windows USB 드라이버를 설치하지 않습니다.

macOS:

```bash
export ADB="$PWD/tools/macos/adb"
"$ADB" version
```

Linux — 압축을 푼 실제 경로로 변경:

```bash
export ADB="$HOME/Android/platform-tools/adb"
"$ADB" version
```

Windows Git Bash — 예시는 `C:\Android\platform-tools`에 압축을 푼 경우:

```bash
export ADB='/c/Android/platform-tools/adb.exe'
export MSYS_NO_PATHCONV=1
"$ADB" version
```

`MSYS_NO_PATHCONV=1`은 Git Bash가 액자 내부의 `/data/local/tmp/...` 같은 경로를 Windows 경로로 자동 변환하는 것을 방지합니다.

Windows PowerShell — 같은 위치에 압축을 푼 경우:

```powershell
$ADB = 'C:\Android\platform-tools\adb.exe'
& $ADB version
& $ADB devices -l
$SERIAL = 'YOUR_DEVICE_SERIAL' # 목록에서 확인한 실제 serial
& $ADB -s $SERIAL get-state
```

PowerShell에서 본문의 Bash 명령을 옮길 때는 다음 차이를 적용합니다.

| Bash 표기 | PowerShell 표기 |
| --- | --- |
| `export SERIAL=YOUR_DEVICE_SERIAL` | `$SERIAL = 'YOUR_DEVICE_SERIAL'` |
| `"$ADB" -s "$SERIAL" ...` | `& $ADB -s $SERIAL ...` |
| 여러 줄 명령의 줄 끝 `\` | `\`를 제거하고 한 줄로 합쳐 실행 |
| `bash install-apps.command` | 4~5단계 ADB 설치 명령을 직접 실행하거나 Git Bash 이용 |

예를 들어 PowerShell에서는 `& $ADB -s $SERIAL install -r apps/nova/Nova-6.2.19.apk`처럼 실행합니다. Fotoo의 `install-multiple`도 5개 APK 경로를 한 명령에 모두 넣습니다. PC의 OS가 바뀌어도 액자에 설치하는 APK와 Google 파일은 같습니다. `google/apply-system-google.sh`는 **PC가 아니라 액자의 Android 셸에서** 실행합니다.

저장소의 `.gitattributes`는 Windows에서 복제해도 Android 셸 스크립트의 LF 줄바꿈과 파일 해시가 유지되도록 설정합니다. Google 스크립트를 편집한다면 LF 형식으로 저장하세요.

파일 무결성은 macOS에서 `shasum -a 256 -c SHA256SUMS.txt`, Linux에서 `sha256sum -c SHA256SUMS.txt`로 확인합니다. Windows PowerShell에서는 `Get-FileHash 파일경로 -Algorithm SHA256` 결과를 `FILES.csv` 또는 `SHA256SUMS.txt`와 비교할 수 있습니다.

## 3. 전원·USB 연결과 대상 확인

정격·극성이 맞는 정상 외부 어댑터로 전원을 공급하고, 데이터 전송 가능한 USB 케이블을 연결합니다. 이 단말은 안정적인 외부 전원을 공급한 뒤 정상 부팅했습니다. USB만으로 전원이 충분하다고 가정하지 않습니다.

```bash
"$ADB" devices -l
export SERIAL=YOUR_DEVICE_SERIAL  # 위 목록에서 확인한 실제 serial로 변경
"$ADB" -s "$SERIAL" get-state
"$ADB" -s "$SERIAL" shell getprop ro.product.model
"$ADB" -s "$SERIAL" shell getprop ro.build.version.release
"$ADB" -s "$SERIAL" shell getprop ro.product.cpu.abi
```

대상이 `device` 상태이고 `DP103 / 6.0.1 / armeabi-v7a`인지 확인합니다. 연결 승인 창이 표시되면 액자에서 승인합니다. 이후 모든 명령은 `-s "$SERIAL"`로 대상을 지정합니다.

## 4. Nova와 Floating Home으로 조작 통로 확보

```bash
"$ADB" -s "$SERIAL" install -r apps/nova/Nova-6.2.19.apk
"$ADB" -s "$SERIAL" install -r apps/floating-home/FloatingHome-1.4.apk
"$ADB" -s "$SERIAL" shell am start -n local.frame.floatinghome/.MainActivity
```

Floating Home에서 **홈 버튼 켜기 / 표시 권한 허용**을 누르고 다른 앱 위에 표시를 허용합니다. 홈 버튼을 누르면 뜨는 홈 선택창에서 **Nova Launcher → 항상**을 선택합니다. 선택창이 없으면 Android 설정에서 기본 홈을 Nova로 지정합니다.

- 알약 왼쪽 절반은 **홈**, 오른쪽 절반은 **뒤로가기**입니다.
- 각각 56×56dp의 터치 영역이며 전체는 112×56dp입니다.
- 배경색 `#334658`, 불투명도 25%, 외부 테두리 없음.
- 어느 쪽이든 끌어 놓으면 해당 사분면의 모서리에 붙습니다. 회전 후에도 같은 모서리를 유지합니다.
- 켜 둔 상태에서는 부팅 완료 후 자동 시작하도록 구성했습니다. 앱에서 끄면 자동 시작도 꺼집니다.
- 홈은 일반 Android 홈 동작을 사용하고, 뒤로가기는 기존 `su`로 `input keyevent 4`를 실행합니다. **뒤로가기는 이 단말의 루트 권한이 필요합니다.**

Nova의 앱 목록에서 Android 설정으로 들어갈 수 있는지 확인합니다. 이후에는 PC 없이 Fotoo와 설정 사이를 이동할 수 있습니다.

## 5. Fotoo 분할 APK 설치

Fotoo 본체만 설치하지 말고 아래 **5개 APK를 함께** 설치합니다.

```bash
"$ADB" -s "$SERIAL" install-multiple -r \
  apps/fotoo-2.6.5-armv7/com.bo.fotoo.apk \
  apps/fotoo-2.6.5-armv7/config.armeabi_v7a.apk \
  apps/fotoo-2.6.5-armv7/config.en.apk \
  apps/fotoo-2.6.5-armv7/config.ko.apk \
  apps/fotoo-2.6.5-armv7/config.xxhdpi.apk
```

Nova에서 Fotoo를 실행하고 필요한 사진·저장소 권한을 허용합니다. PC에서 첫 실행이 필요하면:

```bash
"$ADB" -s "$SERIAL" shell am start -n \
  com.bo.fotoo/com.bo.fotoo.ui.splash.FTSplashActivity
```

4~5단계의 **APK 설치만 한 번에** 하려면 다음 도우미를 대신 사용할 수 있습니다.

```bash
bash install-apps.command
```

도우미는 모델·OS·ABI를 확인하고 일반 앱 3종만 설치합니다. 기본 홈 지정과 표시 권한은 단말에서 설정합니다. 도우미는 시스템 변경·Google 설치·재부팅·앱 삭제를 수행하지 않습니다.

## 6. Google 추가 전 자체 백업·복구 경로 확보

이후 Google 통합은 `/system`을 변경하므로 **이 단말 자체의 백업과 복구 경로를 먼저 확보합니다.** 아래는 기존 `su`가 가능한 DP103에서 시스템·부팅 관련 이미지 **9개**를 수동으로 백업하는 방법입니다. 새로 루팅하거나 펌웨어를 쓰는 절차는 아닙니다.

백업은 **실행 시점의 상태**입니다. 이미 Google을 추가한 뒤 실행하면 Google 추가 전 상태나 공장 순정 이미지가 되지 않습니다. 전체 eMMC 백업이 아니며 `userdata`, 사진·계정, `cache`, `metadata`, `kpanic`, `misc`는 포함하지 않습니다. 기존 단말 전용 백업 이미지는 저장소에 올리지 않았습니다.

### 6-1. 전제 조건과 PC 준비

전원과 USB를 안정적으로 유지하고, 앱 설치·업데이트·시스템 변경을 멈춥니다. `ADB`와 `SERIAL`은 2~3단계에서 지정한 값을 사용합니다. 액자의 `/data`와 PC에 각각 **최소 2GiB의 여유 공간**을 확보합니다. 이미 같은 이름의 임시 폴더나 백업 파일이 있다면 덮어쓰지 말고 먼저 기존 사본을 별도 보관합니다.

백업용 [시스템 스냅샷 스크립트](scripts/dp103-system-snapshot.sh)를 PC에서 액자로 전송합니다. **이 명령은 전송만 하며 실행하지 않습니다.**

macOS·Linux·Windows Git Bash:

```bash
mkdir -p backups/dp103-before-google
"$ADB" -s "$SERIAL" push scripts/dp103-system-snapshot.sh /data/local/tmp/dp103-system-snapshot.sh
"$ADB" -s "$SERIAL" shell
```

Windows PowerShell:

```powershell
New-Item -ItemType Directory -Force backups/dp103-before-google | Out-Null
& $ADB -s $SERIAL push scripts/dp103-system-snapshot.sh /data/local/tmp/dp103-system-snapshot.sh
& $ADB -s $SERIAL shell
```

### 6-2. Android 루트 셸에서 파티션 확인

이제부터 6-4단계까지의 `sh` 코드는 **PC 셸이 아니라 방금 연 Android 셸에 입력**합니다. PC OS와 관계없이 같습니다.

```sh
su
id
getprop ro.product.model
getprop ro.build.version.release
df /data
ls -l /dev/block/platform/1021c000.rksdmmc/by-name
cat /proc/mounts | grep ' /system '
cat /sys/class/block/mmcblk0p11/start
cat /sys/class/block/mmcblk0p11/size
```

`id`가 `uid=0`이어야 합니다. 모델·OS가 `DP103 / 6.0.1`이고, **`system`이 `mmcblk0p11`로 연결되며 실제 `/system` 마운트 장치와 일치하는지** 확인합니다. 확인했던 `system` 시작 sector는 `630784`, 크기는 `2097152` sector입니다. sector는 512바이트입니다. 다른 값이면 아래 고정 경로를 사용하지 않습니다.

이 단말에서 확인한 이미지 크기는 다음과 같습니다. 다른 단말에 이 주소·크기를 그대로 적용하지 않습니다.

| 이미지 | 읽을 대상 | Linux 시작 sector | 파일 크기(bytes) |
| --- | --- | ---: | ---: |
| `reserved-prefix.img` | `mmcblk0` 앞 8MiB | 0 | 8388608 |
| `uboot.img` | by-name/uboot | 16384 | 4194304 |
| `resource.img` | by-name/resource | 32768 | 16777216 |
| `kernel.img` | by-name/kernel | 65536 | 12582912 |
| `boot.img` | by-name/boot | 90112 | 16777216 |
| `recovery.img` | by-name/recovery | 122880 | 37748736 |
| `backup.img` | by-name/backup | 196608 | 67108864 |
| `radical_update.img` | by-name/radical_update | 2727936 | 67108864 |
| `system.img` | `mmcblk0p11` | 630784 | 1073741824 |

### 6-3. 부팅 관련 이미지 8개와 파티션 정보 저장

**Android 루트 셸에서** 아래 블록을 실행합니다. 입력은 블록 장치, 출력은 `/data/local/tmp`의 일반 파일입니다. `if=`와 `of=`를 바꾸지 않습니다. 새 임시 폴더 생성이 실패하거나 마지막에 `BOOT_IMAGES_READY`가 나오지 않으면 중단합니다.

```sh
(
    set -e
    BASE=/dev/block/platform/1021c000.rksdmmc/by-name
    OUT=/data/local/tmp/dp103-backup-before-google
    mkdir "$OUT"
    chmod 755 "$OUT"
    cat /proc/partitions > "$OUT/proc-partitions.txt"
    ls -l "$BASE" > "$OUT/by-name.txt"
    for block in /sys/class/block/mmcblk0p*; do
        echo "${block##*/} start=$(cat "$block/start") sectors=$(cat "$block/size")"
    done > "$OUT/partition-layout.txt"

    dd if=/dev/block/mmcblk0 of="$OUT/reserved-prefix.img" bs=512 count=16384
    [ "$(wc -c < "$OUT/reserved-prefix.img")" -eq 8388608 ]
    source_hash=$(dd if=/dev/block/mmcblk0 bs=512 count=16384 2>/dev/null | md5sum)
    copy_hash=$(md5sum "$OUT/reserved-prefix.img")
    [ "${source_hash%% *}" = "${copy_hash%% *}" ]

    for name in uboot resource kernel boot recovery backup radical_update; do
        cat "$BASE/$name" > "$OUT/$name.img"
        source_hash=$(md5sum "$BASE/$name")
        copy_hash=$(md5sum "$OUT/$name.img")
        [ "${source_hash%% *}" = "${copy_hash%% *}" ]
    done
    echo BOOT_IMAGES_READY
)
```

이 단계의 파일은 각 원본과 MD5를 비교합니다. 백업 중 펌웨어 업데이트나 다른 시스템 작업을 하지 않습니다. `/system`은 실행 중 변경될 수 있으므로 위 반복문에 넣지 않고 다음 단계에서 별도로 읽습니다.

### 6-4. 일관된 system 이미지 생성과 해시 목록 저장

**Android 루트 셸에서** 실행합니다.

```sh
sh /data/local/tmp/dp103-system-snapshot.sh
```

스크립트는 `/system`을 `toybox fsfreeze -f`로 잠시 동결하고, `/dev/block/mmcblk0p11`을 임시 폴더의 `system.img`로 복사한 뒤 `fsfreeze -u`로 해제합니다. `/data`는 동결하지 않습니다. 파일시스템 동결은 [새 쓰기를 잠시 대기시켜 일관된 이미지를 읽기 위한 동작](https://github.com/util-linux/util-linux/blob/master/sys-utils/fsfreeze.8.adoc)이며, 그동안 일부 앱이 잠시 멈출 수 있습니다.

원래 단말에서는 약 29초에 스냅샷을 확보했습니다. 제공 스크립트에는 종료 시 해제와 90초 감시 해제가 있습니다. **`SNAPSHOT_READY`와 이미지 MD5가 출력되어야 성공**입니다. `SNAPSHOT_TIMEOUT`이나 오류가 있으면 그 이미지를 유효한 백업으로 사용하지 않습니다. 제공 파일은 기존에 검증한 방법에 모델·크기·덮어쓰기 방지 검사를 추가한 것으로, 추가 검사 버전 자체를 실제 단말에서 재실행하지는 않았습니다. 정상 완료·복사 실패·시간 초과·다른 모델·기존 이미지 보호는 모의 검사로 확인했습니다. macOS·Linux에서 Python 3가 있으면 `python3 tests/test_snapshot_control_flow.py`로 이 모의 검사만 실행할 수 있으며, 실제 기기에는 접근하지 않습니다.

동결 이후 비정상 종료되어 앱이 멈춘 상태라면, 다른 PC 터미널에서 ADB 루트 셸로 들어가 아래 **해제만** 시도할 수 있습니다. 전원 차단이나 재부팅을 먼저 시도하지 않습니다.

```sh
# 별도로 연 Android 루트 셸에서만 실행
/system/bin/toybox fsfreeze -u /system
```

정상 완료 후 기존 Android 루트 셸에서 파일 목록과 전송용 해시를 만듭니다.

```sh
(
    set -e
    cd /data/local/tmp/dp103-backup-before-google
    [ -s system.img ]
    md5sum reserved-prefix.img uboot.img resource.img kernel.img boot.img recovery.img backup.img radical_update.img system.img > MD5SUMS.txt
    chmod 644 ./*.img ./*.txt
    echo BACKUP_FILES_READY
)
exit
exit
```

마지막 `exit` 두 번은 각각 `su`와 ADB 셸을 종료하여 PC 터미널로 돌아오는 것입니다. `BACKUP_FILES_READY`가 없으면 PC 전송 단계로 넘어가지 않습니다. `system.img`는 동결 중 만든 사본을 검증 기준으로 사용하며, 계속 실행 중인 원본 파티션을 나중에 다시 읽은 해시와 비교하지 않습니다.

### 6-5. PC로 가져오고 9개 크기·해시 확인

셸의 `>`로 이미지 바이너리를 PC에 리다이렉션하지 않고, [ADB의 `pull`](https://developer.android.com/tools/adb#copyfiles)로 파일을 가져옵니다. 이 방식은 Windows PowerShell을 포함해 동일한 바이너리 파일을 전송합니다.

macOS·Linux·Windows Git Bash:

```bash
"$ADB" -s "$SERIAL" pull /data/local/tmp/dp103-backup-before-google/. backups/dp103-before-google/
ls -l backups/dp103-before-google/*.img
```

Windows PowerShell:

```powershell
& $ADB -s $SERIAL pull /data/local/tmp/dp103-backup-before-google/. backups/dp103-before-google/
Get-ChildItem backups/dp103-before-google/*.img | Select-Object Name, Length
```

**이미지 파일이 정확히 9개이고 모든 크기가 6-2 표와 일치하는지 확인합니다.** 이어서 액자에서 생성한 MD5 목록과 PC 사본을 비교합니다.

macOS:

```bash
(
    set -e
    cd backups/dp103-before-google
    [ "$(wc -l < MD5SUMS.txt)" -eq 9 ]
    set -- ./*.img
    [ "$#" -eq 9 ]
    while read -r expected name; do
        actual=$(md5 -q "$name")
        [ "$actual" = "$expected" ] || { echo "HASH_MISMATCH: $name"; exit 1; }
    done < MD5SUMS.txt
    shasum -a 256 ./*.img > SHA256SUMS.txt
    echo ALL_9_IMAGE_HASHES_VERIFIED
)
```

Linux — Git Bash에 `md5sum`이 있는 경우에도 같은 명령 사용:

```bash
(cd backups/dp103-before-google && [ "$(wc -l < MD5SUMS.txt)" -eq 9 ] && md5sum -c MD5SUMS.txt && sha256sum ./*.img > SHA256SUMS.txt)
```

Windows PowerShell:

```powershell
$Backup = 'backups/dp103-before-google'
if (@(Get-ChildItem "$Backup/*.img").Count -ne 9) { throw 'EXPECTED_9_IMAGES' }
if (@(Get-Content "$Backup/MD5SUMS.txt").Count -ne 9) { throw 'EXPECTED_9_HASHES' }
Get-Content "$Backup/MD5SUMS.txt" | ForEach-Object {
    $expected, $name = $_ -split '\s+', 2
    $actual = (Get-FileHash -LiteralPath (Join-Path $Backup $name) -Algorithm MD5).Hash
    if ($actual -ine $expected) { throw "HASH_MISMATCH: $name" }
}
Get-ChildItem "$Backup/*.img" | Get-FileHash -Algorithm SHA256 |
    Export-Csv "$Backup/SHA256SUMS.csv" -NoTypeInformation -Encoding UTF8
```

크기와 **MD5 9개가 모두 일치해야** 백업을 완료로 판단합니다. SHA-256은 PC 보관 사본의 이후 무결성 검사용입니다. 이미지와 `MD5SUMS.txt`, SHA-256 목록, `partition-layout.txt`, `by-name.txt`, `proc-partitions.txt`를 함께 외장 디스크 등 다른 위치에도 보관합니다. `backups/`와 `*.img`는 Git에서 제외되어 있습니다. 백업 이미지는 GitHub에 업로드하지 않습니다.

### 복구 경로 확인 범위

백업이 있어도 실제 복구 경로가 확보된 것과 같지는 않습니다. 원래 단말에서 Rockchip Loader(USB `2207:310d`) 진입·읽기·정상 Android 복귀는 확인했지만, 물리 버튼만으로 부팅 불능 상태에서 진입하는 방법과 이미지 복원 쓰기는 검증하지 않았습니다. 이 단말의 Loader LBA는 Linux 물리 sector에서 8192를 뺀 값이며, **다른 단말의 복원 주소로 사용하지 않습니다.**

이 문서의 백업 절차는 재부팅·모드 전환·복원 쓰기를 실행하지 않습니다. Loader 시험과 실제 복원은 별도로 계획해야 합니다. 실행 중인 마운트된 `/system` 위에 `system.img`를 덮어쓰지 않습니다.

## 7. Google 시스템 구성 추가

**이미 Google 구성이 정상 동작하는 기기에서는 이 단계를 반복하지 않습니다.** 아래는 백업·복구 준비가 끝난 동일 구성 단말을 위한 별도 시스템 작업입니다.

| 구성 | 버전 | 파일 |
| --- | --- | --- |
| Google Services Framework | 6.0.1 | `GoogleServicesFramework/GoogleServicesFramework.apk` |
| Google Account Manager | 6.0.1 | `GoogleLoginService/GoogleLoginService.apk` |
| Google Play services | 21.48.57 (040300-424705839) | `PrebuiltGmsCore/PrebuiltGmsCore.apk` 및 `lib/arm/` |
| Google Play Store | 29.2.15-21 [0] [PR] 426536134 | `Phonesky/Phonesky.apk` 및 `lib/arm/` |

위 파일은 `google/system-stage/` 아래에 있습니다. APK만 골라 일반 앱으로 설치하지 말고 필요한 네이티브 라이브러리와 디렉터리 구조를 유지합니다.

```bash
"$ADB" -s "$SERIAL" shell su -c id
# uid=0 및 백업·시스템 여유 공간을 확인한 뒤 진행
"$ADB" -s "$SERIAL" shell mkdir -p /data/local/tmp/dp103-google-system-stage
"$ADB" -s "$SERIAL" push google/system-stage/. /data/local/tmp/dp103-google-system-stage/
"$ADB" -s "$SERIAL" push google/apply-system-google.sh /data/local/tmp/dp103-add-google-system.sh
"$ADB" -s "$SERIAL" shell "su -c 'sh /data/local/tmp/dp103-add-google-system.sh'"
```

완료 표식은 `SYSTEM_GOOGLE_FILES_VERIFIED_32`입니다. 스크립트는:

- 추가 대상 Google 디렉터리가 기존에 없는 경우만 진행합니다.
- `/system/priv-app` 아래에 4개 폴더와 총 32개 파일을 추가합니다.
- 디렉터리 0755, 파일 0644, 소유자 root:root와 SELinux 라벨을 맞춥니다.
- 원본과 파일 해시를 대조하고 `/system`을 읽기 전용으로 되돌립니다.
- 기존 시스템 파일·커널·부트로더를 덮어쓰거나 기기를 재부팅하지 않습니다.

시스템 변경은 부팅 실패 가능성이 있으므로 6단계가 선행되어야 합니다. 성공 확인 후 사용자가 통제하는 정상 재부팅으로 적용하고, 정상 부팅과 ADB 복귀를 확인합니다.

## 8. Google Play 로그인

다음 4개 패키지가 활성화되어 있는지 확인합니다.

```text
com.google.android.gsf
com.google.android.gsf.login
com.google.android.gms
com.android.vending
```

이전에 비활성화한 패키지만 `pm enable`로 활성화합니다. Google Services Framework가 privileged 시스템 앱으로 인식되고 `MANAGE_USERS` 권한이 부여되어야 합니다.

Nova에서 Play 스토어를 열고, **Fotoo 프리미엄을 구매한 Google 계정으로 사용자가 직접 로그인**합니다. 비밀번호·토큰을 PC로 추출하거나 저장소에 기록하지 않습니다.

## 9. Fotoo 프리미엄 복원과 사용 설정

Fotoo의 구매 복원 기능으로 프리미엄 인식을 확인합니다. 이 단말에서는 Google Play 계정 로그인과 Fotoo 프리미엄 복구를 사용자가 확인했습니다.

사진 소스·전환 간격·방향을 설정하고, Nova에 Fotoo와 Android 설정 아이콘을 배치합니다. 홈 버튼으로 Nova에 나가 설정을 바꾸고 Fotoo로 돌아옵니다. Fotoo를 기본 홈으로 강제 지정하지 않습니다. Fotoo 자동 실행과 절전 설정은 앱에서 별도 확인합니다.

## 10. 최종 확인

- 안정적인 전원에서 부팅·화면·터치가 정상인지 확인합니다.
- 홈으로 Nova에 돌아가 Android 설정과 Fotoo를 실행할 수 있어야 합니다.
- Fotoo 위에서 홈·뒤로가기와 네 모서리 이동을 확인합니다.
- Play 스토어의 구매 계정과 Fotoo 프리미엄을 확인합니다.
- 다음 정상 재부팅 때 Floating Home 자동 표시도 확인합니다.

## 파일 구성과 보관

```text
apps/fotoo-2.6.5-armv7/   Fotoo 본체와 ARMv7·언어·밀도 분할 APK
apps/nova/                Nova 6.2.19
apps/floating-home/       Floating Home 1.4 APK 및 소스
google/                  Google 시스템 APK·ARM 라이브러리·적용 스크립트
tools/macos/             macOS ADB, 도구 고지와 버전
docs/                    상세 절차와 확인된 구성 정보
scripts/                 수동 백업용 시스템 스냅샷 도우미
install-apps.command      일반 앱 설치 도우미
FILES.csv                 파일별 용도·크기·SHA-256
SHA256SUMS.txt            파일 무결성 검증
```

[상세 작업 안내](docs/installation-detail.txt) · [파일 목록](FILES.csv) · [확인된 구성](docs/verified-configuration.json) · [버튼 앱 소스](apps/floating-home/source)

단말 백업, 계정·사진·비밀번호·토큰, 로컬 서명 키는 업로드하지 않았습니다. 저장소에 포함된 Google 파일은 커스텀 ROM 전체나 범용 GApps 설치 패키지가 아닙니다.

Floating Home을 같은 서명으로 나중에 업데이트하려면 원래 빌드의 로컬 서명 키를 별도로 보존해야 합니다. 이 저장소에서 새 키로 재빌드한 APK는 기존 앱에 바로 덮어 업데이트할 수 없습니다.

타사 앱과 도구의 권리는 각 원저작자에게 있습니다. 여기 포함된 파일은 실제 확인한 설치 조합을 보존한 것이며, 타사 앱에 별도 라이선스를 부여하거나 프리미엄 권한을 제공하지 않습니다.
