# Flutter Web 결제 콜백 미수신 이슈 해결

## 문제 현상

Flutter Web 환경에서 Bootpay 결제 완료 후 `onClose`, `onCancel`, `onDone` 등의 콜백이 호출되지 않는 문제가 발생했습니다.

- 결제 창은 정상적으로 열림
- 결제 프로세스 진행 가능
- 결제 완료/취소 후 콜백 함수가 호출되지 않음
- 모바일 WebView에서는 정상 동작

## 원인 분석

### 1. JavaScript Interop 방식 변경 (핵심 원인)

Dart 3.x에서 JavaScript 연동 방식이 변경되었습니다.

| 구분 | 기존 (동작함) | 변경 후 (동작 안함) |
|------|--------------|-------------------|
| 패키지 | `package:js/js.dart` | `dart:js_interop` |
| 콜백 등록 | `allowInterop(callback)` | `callback.toJS` |
| Dart SDK | `>=2.18.0 <4.0.0` | `^3.5.0` |

**`dart:js_interop`의 `.toJS` 확장 메서드가 Bootpay SDK와 호환되지 않았습니다.**

### 2. Bootpay SDK 버전

- 문제 버전: `bootpay-4.2.7.min.js`
- 정상 버전: `bootpay-4.3.1.min.js`

### 3. Web 전용 설정 누락

`extra.openType = 'iframe'` 설정이 일부 결제 화면에서 누락되어 있었습니다.

## 해결 방법

### 1. pubspec.yaml - SDK 버전 다운그레이드

```yaml
# 변경 전
environment:
  sdk: ^3.5.0
  flutter: ">=3.24.0"

dependencies:
  web: ^1.1.0

# 변경 후
environment:
  sdk: ">=2.18.0 <4.0.0"
  flutter: ">=3.3.0"

dependencies:
  js: ^0.7.1
```

### 2. bootpay_web.dart - JS Interop 방식 변경

```dart
// 변경 전 (동작 안함)
import 'dart:js_interop';

BootpayPlatform() {
  _BootpayClose = onClose.toJS;
  _BootpayCancel = onCancel.toJS;
  // ...
}

// 변경 후 (정상 동작)
import 'package:js/js.dart';

BootpayPlatform() {
  _BootpayClose = allowInterop(onClose);
  _BootpayCancel = allowInterop(onCancel);
  // ...
}
```

### 3. index.html - SDK 버전 업데이트

```html
<!-- 변경 전 -->
<script src="https://js.bootpay.co.kr/bootpay-4.2.7.min.js"></script>

<!-- 변경 후 -->
<script src="https://js.bootpay.co.kr/bootpay-4.3.1.min.js"></script>
```

### 4. 결제 화면 - openType 설정 추가

```dart
import 'package:flutter/foundation.dart';

Extra extra = Extra();
extra.appScheme = 'bootpayFlutterExampleV2';
if (kIsWeb) {
  extra.openType = 'iframe';  // Web 환경에서 필수
}
payload.extra = extra;
```

## 수정된 파일 목록

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | SDK 버전, js 패키지 |
| `example/pubspec.yaml` | SDK 버전 |
| `lib/shims/bootpay_web.dart` | `allowInterop()` 사용 |
| `example/web/index.html` | SDK 4.3.1 |
| `example/web/bootpay_api.js` | 간소화된 이벤트 리스너 |
| `example/lib/screens/payments/*.dart` | `openType = 'iframe'` 추가 |

## 핵심 교훈

1. **`dart:js_interop`와 `package:js/js.dart`는 호환되지 않습니다**
   - Dart 3.x의 새로운 `dart:js_interop`은 일부 JS 라이브러리와 호환 문제가 있음
   - 외부 JS SDK 연동 시 `package:js`와 `allowInterop()` 사용 권장

2. **SDK 버전 업그레이드 시 주의**
   - Dart SDK 버전 업그레이드 시 JS interop 관련 코드 검증 필요
   - 기존 동작하던 코드가 새 SDK에서 동작하지 않을 수 있음

3. **Web 플랫폼 특수 설정**
   - Flutter Web은 모바일과 다른 설정이 필요할 수 있음
   - `kIsWeb`으로 플랫폼 분기 처리 필수

## 관련 이슈

- Dart 3.x JavaScript Interop 변경: https://dart.dev/interop/js-interop
- Flutter Web iframe 이슈: Bootpay SDK에서 iframe 방식 사용 시 `openType` 설정 필요
