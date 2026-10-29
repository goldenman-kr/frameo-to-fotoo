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

macOS에서는 포함된 ADB를 사용합니다.

```bash
export ADB="$PWD/tools/macos/adb"
"$ADB" version
```

Linux·Windows에서는 해당 OS의 Android SDK Platform-Tools를 준비하고 `ADB`를 그 실행 파일 경로로 지정하세요. 제공된 `.command` 도우미는 Bash용입니다. Windows에서는 Git Bash를 사용하거나 아래 ADB 명령을 해당 셸에 맞춰 직접 실행합니다.

파일을 확인하려면 macOS에서 `shasum -a 256 -c SHA256SUMS.txt`, Linux에서 `sha256sum -c SHA256SUMS.txt`를 실행합니다.

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

Fotoo의 사진 소스 설정과 **Google Play 구매 계정으로 프리미엄을 복원하는 것**은 별개입니다. 이 단말에서 구매 계정을 사용하기 위해 Google 구성 4종을 시스템 앱으로 추가했습니다.

이후 단계는 `/system`을 변경하므로 **단말 자체의 검증된 백업과 복구 경로를 먼저 확보해야 합니다.** 기존 `su`와 충분한 시스템 여유 공간도 필요합니다. APK와 ARM 라이브러리의 합계는 약 173MiB입니다.

원래 단말에서는 시스템·부팅 관련 이미지 9개를 크기와 해시로 검증하여 별도 보관했습니다. **그 단말 전용 백업 이미지는 이 저장소에 포함하지 않았습니다.** 전체 eMMC나 사진·계정 백업도 아닙니다. 다른 단말의 이미지를 대신 사용하지 않습니다.

원래 단말에서 Loader 진입·읽기·Android 복귀는 확인했지만, 물리 버튼만으로 부팅 불능 상태에서 Loader에 진입하거나 이미지를 실제로 복원하는 쓰기 작업은 검증하지 않았습니다. 백업만으로 복구가 보장되지는 않습니다.

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
install-apps.command      일반 앱 설치 도우미
FILES.csv                 파일별 용도·크기·SHA-256
SHA256SUMS.txt            파일 무결성 검증
```

[상세 작업 안내](docs/installation-detail.txt) · [파일 목록](FILES.csv) · [확인된 구성](docs/verified-configuration.json) · [버튼 앱 소스](apps/floating-home/source)

단말 백업, 계정·사진·비밀번호·토큰, 로컬 서명 키는 업로드하지 않았습니다. 저장소에 포함된 Google 파일은 커스텀 ROM 전체나 범용 GApps 설치 패키지가 아닙니다.

Floating Home을 같은 서명으로 나중에 업데이트하려면 원래 빌드의 로컬 서명 키를 별도로 보존해야 합니다. 이 저장소에서 새 키로 재빌드한 APK는 기존 앱에 바로 덮어 업데이트할 수 없습니다.

타사 앱과 도구의 권리는 각 원저작자에게 있습니다. 여기 포함된 파일은 실제 확인한 설치 조합을 보존한 것이며, 타사 앱에 별도 라이선스를 부여하거나 프리미엄 권한을 제공하지 않습니다.
