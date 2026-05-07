# Bootpay Flutter SDK

`bootpay` (pub.dev).

## 배포 시 버전 동기화 체크리스트 (CRITICAL)

패키지 버전과 **런타임 VERSION 상수**가 어긋나면 webview/analytics 에 옛 버전이 보고된다. 한 곳만 올리면 안 된다.

| 파일 | 상수 | 비고 |
|------|------|------|
| `pubspec.yaml` | `version` | pub.dev 배포 버전 |
| `lib/config/bootpay_config.dart` | `BootpayConfig.VERSION` | webview `setVersion()` 으로 송신되는 런타임 값 |
| `CHANGELOG.md` | — | 새 버전 항목 추가 |

CDN URL 변경 시 추가:
- `lib/bootpay_webview.dart` → `INAPP_URL`
- `lib/widget/bootpay_widget_webview.dart` → `INAPP_URL`

## 배포 절차

```bash
flutter pub publish --dry-run    # validation 체크
flutter pub publish              # 실제 publish (credentials 캐시되어 있으면 비대화형)
git tag v<version> && git push origin v<version>
```

## 환경 기본값

`BootpayConfig.ENV` 기본값은 `ENV_PROMOTION` (= production). `Bootpay.setEnvironmentMode('development' | 'stage' | 'production')` 으로 런타임 토글.
