# DP103 자동 시작과 기본 홈 유지

대상은 이 저장소에서 확인한 **DP103 / Android 6.0.1 / 기존 `su` 사용 가능 펌웨어**입니다. APK 설치와 별개의 시스템 설정입니다. Frameo 앱은 삭제하거나 비활성화하지 않습니다.

## 원인과 적용 범위

이 단말의 시스템 프레임워크를 로컬에서 분석하고 단말에서 비교 시험한 결과입니다.

- `ro.config.low_ram=true` 또는 `ro.mem_optimise.enable=true` 조건의 제조사 정책은 일반 앱의 브로드캐스트 기반 새 프로세스 시작을 차단합니다. 부팅 알림과, 프로세스가 종료된 뒤의 예약 알람 수신이 영향을 받습니다.
- 앱 전환 시 이전 앱을 `killAppAtUsersRequest` 경로로 종료하는 정책도 있습니다. 이전 앱이 Nova 홈 프로세스이면 기본 홈 설정을 지울 수 있습니다. 실제 Java 오류가 없어도 `user request after error` 종료 기록이 생깁니다.
- `sys.cts_gts.status=true`는 확인한 코드에서 이 제한을 건너뜁니다. Frameo 자체가 홈 설정을 지운다는 증거는 확인하지 않았습니다.

이 속성은 표준 Android 사용자 설정이 아닙니다. 앱 전체의 종료·캐시·오류 처리 정책에 영향을 주며 메모리 사용량이 늘 수 있습니다. 다른 보드나 펌웨어에서 같은 효과를 보장하지 않습니다. 루팅, 앱 권한 추가, Google 재설치를 수행하는 방법이 아닙니다.

## 1. 백업과 사전 확인

먼저 README 6단계의 단말 자체 백업과 복구 준비를 마칩니다. 이 작업은 기존 `/system/build.prop`를 변경하므로 부팅 실패 가능성을 배제할 수 없습니다. 아래 파일 백업만으로 ADB에 들어갈 수 없는 기기를 복원할 수 있는 것은 아닙니다. 부팅 불능 상태의 물리 버튼 Loader 진입과 이미지 복원 쓰기는 아직 검증하지 않았습니다.

PC에서는 README에서 설정한 `ADB`, `SERIAL`을 사용합니다. 매번 연결 목록에서 대상을 확인하며 다른 태블릿을 선택하지 않습니다.

macOS·Linux·Windows Git Bash:

```bash
"$ADB" -s "$SERIAL" shell getprop ro.product.model
"$ADB" -s "$SERIAL" shell getprop ro.build.version.release
"$ADB" -s "$SERIAL" shell su -c id
mkdir -p backups/app-policy
"$ADB" -s "$SERIAL" pull /system/build.prop backups/app-policy/build.prop.before
```

Windows PowerShell에서는 같은 준비를 다음처럼 실행합니다.

```powershell
& $ADB -s $SERIAL shell getprop ro.product.model
& $ADB -s $SERIAL shell getprop ro.build.version.release
& $ADB -s $SERIAL shell su -c id
New-Item -ItemType Directory -Force backups/app-policy | Out-Null
& $ADB -s $SERIAL pull /system/build.prop backups/app-policy/build.prop.before
```

기존 백업이 있다면 새 폴더 이름을 사용해 원본을 보존합니다. `DP103`, `6.0.1`, `uid=0`을 확인하지 못하면 중단합니다. 백업은 저장소의 `backups/`에서 Git에 제외되며 공개 업로드하지 않습니다.

## 2. 재부팅 없이 임시 확인

PC에서 ADB 셸에 들어갑니다. Bash는 `"$ADB" -s "$SERIAL" shell`, PowerShell은 `& $ADB -s $SERIAL shell`입니다. 이후 코드 블록은 **PC 셸이 아니라 액자 내부 셸**에 입력하므로 PC OS에 따른 문법 차이가 없습니다. 먼저 루트 셸에 들어갑니다.

```sh
su
id
getprop ro.config.low_ram
getprop ro.mem_optimise.enable
getprop sys.cts_gts.status
setprop sys.cts_gts.status true
getprop sys.cts_gts.status
```

마지막 출력이 `true`인지 확인합니다. 이 설정만으로는 다음 재부팅 때 유지되지 않습니다. Floating Home을 켜고 표시 권한을 허용한 뒤, Nova를 홈 앱으로 ‘항상’ 선택합니다. Fotoo와 Nova를 왕복해 홈 선택창이 반복되지 않는지 확인합니다. Fotoo에서 부팅 자동 실행과 원하는 일정을 설정합니다. APK에 있는 부팅 수신 권한만으로 앱 내 자동 실행 설정까지 켜지는 것은 아닙니다.

## 3. 영구 적용

위 임시 확인이 성공한 동일 단말에서만 진행합니다. **현재 루트 셸**에 아래 블록 전체를 입력합니다. 원본을 단말의 임시 디렉터리에도 보관하고, 원본 바이트를 복사한 수정본 끝에 속성 한 줄을 추가합니다. 새 파일의 권한·SELinux 문맥을 맞춘 후 이름을 바꿔 교체하며, 이 블록은 재부팅하지 않습니다.

기존 속성이나 이전 작업 백업이 있으면 덮어쓰지 않고 중단합니다. 오류가 나면 재부팅부터 하지 말고 현재 파일과 백업 상태를 확인합니다. 특히 재마운트가 실패하면 반복해서 덮어쓰지 않습니다.

```sh
(
  set -eu
  work=/data/local/tmp/dp103-app-policy
  if grep -q '^[[:space:]]*sys.cts_gts.status[[:space:]]*=' /system/build.prop; then
    echo 'Property already exists; inspect it before continuing.'
    exit 1
  fi
  mkdir -p "$work"
  if [ -e "$work/build.prop.before" ]; then
    echo 'Previous backup exists; preserve and inspect it.'
    exit 1
  fi
  cp /system/build.prop "$work/build.prop.before"
  cmp /system/build.prop "$work/build.prop.before"
  cp "$work/build.prop.before" "$work/build.prop.proposed"
  printf '\n# Allow normal application lifecycle on DP103\nsys.cts_gts.status=true\n' >> "$work/build.prop.proposed"
  mount -o remount,rw /system
  trap 'mount -o remount,ro /system' EXIT
  cp "$work/build.prop.proposed" /system/build.prop.fotoo-new
  chown 0:0 /system/build.prop.fotoo-new
  chmod 0644 /system/build.prop.fotoo-new
  restorecon /system/build.prop.fotoo-new
  cmp /system/build.prop.fotoo-new "$work/build.prop.proposed"
  cmp /system/build.prop "$work/build.prop.before"
  mv /system/build.prop.fotoo-new /system/build.prop
  sync
  cmp /system/build.prop "$work/build.prop.proposed"
  ls -lZ /system/build.prop
  mount -o remount,ro /system
  trap - EXIT
  echo 'APP_POLICY_FILE_VERIFIED'
)
```

`APP_POLICY_FILE_VERIFIED` 표식과 파일 권한 `-rw-r--r--`, 소유자 `root root`, 문맥 `u:object_r:system_file:s0`를 확인합니다. `cmp`는 같은 파일이면 아무것도 출력하지 않습니다. `mount | grep /system` 결과의 옵션이 `ro,`로 시작하는지도 확인합니다. 원본 `ro.config.low_ram` 값은 변경하지 않습니다.

루트 셸과 ADB 셸에서 각각 `exit`로 나온 뒤 단말 쪽 원본을 PC에 추가 보관할 수 있습니다. Bash:

```bash
"$ADB" -s "$SERIAL" pull /data/local/tmp/dp103-app-policy/build.prop.before backups/app-policy/build.prop.device-before
```

PowerShell:

```powershell
& $ADB -s $SERIAL pull /data/local/tmp/dp103-app-policy/build.prop.before backups/app-policy/build.prop.device-before
```

## 4. 재부팅 1회와 실제 자동 시작 확인

영구 적용 파일 검증에 성공한 뒤 PC에서 한 번 재부팅합니다. Bash:

```bash
"$ADB" -s "$SERIAL" reboot
```

PowerShell:

```powershell
& $ADB -s $SERIAL reboot
```

ADB가 복귀하면 앱을 수동으로 열기 전에 액자 셸에서 확인합니다.

```sh
getprop sys.boot_completed
getprop sys.cts_gts.status
ps | grep -E 'floatinghome|teslacoilsw|com.bo.fotoo'
logcat -d -s FloatingHome:I '*:S'
dumpsys package | grep -A 2 'mAlways=true'
dumpsys alarm | grep -A 3 'FTAlarmReceiver.ACTION_ALARM'
```

기대 결과는 부팅 완료 `1`, 속성 `true`, `local.frame.floatinghome:overlay`와 Fotoo 프로세스, 홈 버튼의 `Automatic start: android.intent.action.BOOT_COMPLETED` 로그, Nova의 `mAlways=true`, Fotoo의 기존 일정에 해당하는 알람입니다. 부팅 완료 속성이 먼저 나오고 부팅 브로드캐스트 처리가 늦게 끝날 수 있으므로 잠시 기다린 후 다시 조회합니다. 앱을 직접 실행한 결과를 자동 시작 성공으로 기록하지 않습니다.

홈 버튼으로 Nova에 돌아갔다가 Fotoo로 복귀하고, 이후 실제 예약 시간에 화면이 꺼졌다 다시 켜지는지도 확인합니다. 알람 등록 확인과 실제 깊은 절전에서의 화면 복귀는 별개의 검증입니다. 로그나 계정·사진·펌웨어를 외부에 업로드할 필요는 없습니다.

## 5. 되돌리기

아직 ADB·`su`로 접근할 수 있다면 **이 변경 직전에 만든 해당 단말 원본**으로 복원합니다. 아래 경로는 이 문서의 3단계가 만든 백업입니다. PC의 원본만 남았다면 먼저 ADB `push`로 같은 단말의 임시 경로에 준비하고 내용을 확인합니다. 다른 액자의 `build.prop`를 쓰지 않습니다.

액자의 루트 셸에서:

```sh
(
  set -eu
  original=/data/local/tmp/dp103-app-policy/build.prop.before
  test -s "$original"
  mount -o remount,rw /system
  trap 'mount -o remount,ro /system' EXIT
  cp "$original" /system/build.prop.fotoo-restore
  chown 0:0 /system/build.prop.fotoo-restore
  chmod 0644 /system/build.prop.fotoo-restore
  restorecon /system/build.prop.fotoo-restore
  cmp /system/build.prop.fotoo-restore "$original"
  mv /system/build.prop.fotoo-restore /system/build.prop
  sync
  cmp /system/build.prop "$original"
  mount -o remount,ro /system
  trap - EXIT
  setprop sys.cts_gts.status false
  echo 'APP_POLICY_ORIGINAL_RESTORED'
)
```

원본 복원과 읽기 전용 마운트를 확인한 후 정상 재부팅하면 원래 정책으로 돌아갑니다. 원본이 변경된 뒤 추가로 수정된 다른 설정이 있다면 파일 전체 복원이 그 수정도 되돌릴 수 있으므로 먼저 차이를 확인합니다. 부팅 불능으로 ADB가 없을 때의 복구는 이 셸 절차로 할 수 없습니다.

## 확인된 결과와 한계

2026-10-30, 이 DP103에서 기존 파일을 백업하고 위와 같은 속성 한 줄 추가를 적용한 뒤 실제 재부팅 **1회**를 수행했습니다. 수정 파일의 바이트 일치와 권한·문맥, 읽기 전용 재마운트를 확인했습니다.

- 재부팅 후에도 속성 `true`가 유지됐습니다.
- Floating Home과 Fotoo가 실제 부팅 알림으로 시작했습니다.
- 실제 홈 버튼으로 Nova에 진입했으며 ‘항상’ 선택이 유지됐습니다.
- 기존 01:00 끄기·07:00 켜기 `RTC_WAKEUP` 알람이 재등록됐습니다. 이 시간은 시험 단말의 일정이며 다른 단말에 강제할 값이 아닙니다.
- ‘켜기’ 예약 수신기를 직접 호출한 시험에서 전원 상태 `Asleep` → `Awake`와 Fotoo 화면 복귀를 확인했습니다. 이 시험은 영구 적용 전 임시 설정에서 수행했습니다.
- **실제 예약 시각의 깊은 절전·RTC 깨우기와 위 복원 절차의 실제 실행은 미검증입니다.**

저장소에는 단말 원본 `build.prop`, 전체 시스템 코드, 개인 로그 또는 단말 백업을 포함하지 않습니다.
