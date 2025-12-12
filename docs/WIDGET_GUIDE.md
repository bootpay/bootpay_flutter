# Bootpay Flutter Widget 연동 가이드

## 개요

Bootpay Widget은 앱 화면 내에 삽입 가능한 결제 컴포넌트입니다. 사용자가 결제수단을 선택하고 약관에 동의한 후, 결제하기 버튼을 눌러 결제를 진행할 수 있습니다.

## 아키텍처

Flutter 위젯 모듈은 네이티브 SDK (iOS/Android)와 동일한 구조로 설계되었습니다.

```
lib/widget/
├── bootpay_widget.dart           # 위젯 UI (BootpayWidget, BootpayWidgetController)
└── bootpay_widget_webview.dart   # 위젯 전용 웹뷰 (BootpayWidgetWebView)
```

### 분리된 위젯 전용 웹뷰

기존에는 결제와 위젯이 동일한 `BootpayWebView`를 공유했지만, 이제 위젯 전용 `BootpayWidgetWebView`를 사용합니다.

**장점:**
- 위젯과 결제 로직의 명확한 분리
- 네이티브 SDK와 동일한 구조로 유지보수 용이
- 위젯 전용 이벤트 처리 최적화

## 기본 구성요소

### 1. BootpayWidget
결제 위젯을 표시하는 StatefulWidget입니다. 화면에 삽입하여 사용합니다.

### 2. BootpayWidgetController
위젯의 상태를 관리하고 이벤트 콜백을 처리하는 컨트롤러입니다.

### 3. BootpayWidgetWebView (내부)
위젯 전용 웹뷰입니다. BootpayWidget 내부에서 사용되며, 직접 사용할 필요는 없습니다.

### 4. Payload
결제 정보를 담는 데이터 클래스입니다.

## 연동 방법

### Step 1. 의존성 추가

```yaml
dependencies:
  bootpay: ^5.0.0  # 최신 버전
```

### Step 2. Import

```dart
import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:bootpay/widget/bootpay_widget.dart';
```

### Step 3. 프로퍼티 선언

```dart
class WidgetPageState extends State<WidgetPage> {
  Payload _payload = Payload();
  BootpayWidgetController _controller = BootpayWidgetController();
  double _widgetHeight = 516.0; // 기본 위젯 높이
}
```

### Step 4. Payload 설정

```dart
void _initPayload() {
  _payload = Payload();
  _payload.webApplicationId = 'YOUR_WEB_APPLICATION_ID';
  _payload.androidApplicationId = 'YOUR_ANDROID_APPLICATION_ID';
  _payload.iosApplicationId = 'YOUR_IOS_APPLICATION_ID';

  _payload.price = 1000;  // 결제 금액
  _payload.orderName = '테스트 상품';  // 주문명
  _payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();  // 주문 고유 ID

  // Widget 필수 설정
  _payload.widgetKey = 'default-widget';  // 위젯 키
  _payload.widgetSandbox = true;  // 샌드박스 모드 (테스트: true, 운영: false)
  _payload.widgetUseTerms = true;  // 약관동의 UI 사용 여부

  // User 설정 (선택)
  _payload.user = User();
  _payload.user?.id = 'user_id';
  _payload.user?.username = '홍길동';
  _payload.user?.email = 'test@example.com';
  _payload.user?.phone = '01012341234';

  // Extra 설정 (선택)
  _payload.extra = Extra();
  _payload.extra?.appScheme = 'yourAppScheme';  // 앱 스킴 (앱투앱 결제 복귀용)
  // _payload.extra?.displaySuccessResult = true;  // 결제 성공 결과 화면 표시 여부
  // _payload.extra?.displayErrorResult = true;    // 결제 에러 결과 화면 표시 여부
}
```

### Step 5. WidgetController 설정

```dart
void _initController() {
  // 위젯 준비 완료
  _controller.onWidgetReady = () {
    debugPrint('[Widget] Ready');
  };

  // 위젯 높이 변경
  _controller.onWidgetResize = (height) {
    setState(() {
      _widgetHeight = height;
    });
  };

  // 결제수단 변경
  _controller.onWidgetChangePayment = (widgetData) {
    _payload.mergeWidgetData(widgetData);
    setState(() {});  // 버튼 상태 업데이트
  };

  // 약관동의 변경
  _controller.onWidgetChangeAgreeTerm = (widgetData) {
    _payload.mergeWidgetData(widgetData);
    setState(() {});  // 버튼 상태 업데이트
  };
}
```

### Step 6. UI 구성

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 상품 정보 영역
                _buildProductWidget(),

                // 위젯 영역
                SizedBox(
                  height: _widgetHeight,
                  child: BootpayWidget(
                    payload: _payload,
                    controller: _controller,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 결제 버튼
        _buildPayButton(),
      ],
    ),
  );
}

Widget _buildPayButton() {
  final isCompleted = _payload.widgetIsCompleted;

  return ElevatedButton(
    onPressed: isCompleted ? _goPayment : null,
    style: ElevatedButton.styleFrom(
      backgroundColor: isCompleted ? Colors.blue : Colors.grey,
    ),
    child: Text('결제하기'),
  );
}
```

### Step 7. 결제 요청

```dart
void _goPayment() {
  if (!_payload.widgetIsCompleted) {
    // 결제수단 선택과 약관동의 미완료
    return;
  }

  _controller.requestPayment(
    context: context,
    payload: _payload,
    onCancel: (String data) {
      debugPrint('[Widget] Cancel: $data');
    },
    onError: (String data) {
      debugPrint('[Widget] Error: $data');
    },
    onClose: () {
      debugPrint('[Widget] Close');
      Bootpay().dismiss(context);
    },
    onConfirm: (String data) {
      // 서버에서 결제 정보 검증 후 true/false 반환
      return true;
    },
    onIssued: (String data) {
      debugPrint('[Widget] Issued: $data');
    },
    onDone: (String data) {
      debugPrint('[Widget] Done: $data');
      // 결과 페이지로 이동 또는 처리
    },
  );
}
```

## displaySuccessResult / displayErrorResult 옵션

결제 완료 또는 에러 발생 시 웹뷰에서 결과 화면을 표시할지 여부를 설정합니다.

### 옵션별 동작

| 옵션 | 값 | 동작 |
|------|-----|------|
| `displaySuccessResult` | `true` | 결제 성공 시 웹뷰에서 결과 화면 표시 → 사용자가 닫기 버튼 클릭 → `onClose` 호출 |
| `displaySuccessResult` | `false` (기본값) | 결제 성공 시 즉시 `onDone` 호출 → 앱에서 결과 화면 처리 |
| `displayErrorResult` | `true` | 결제 에러 시 웹뷰에서 에러 화면 표시 → 사용자가 닫기 버튼 클릭 → `onClose` 호출 |
| `displayErrorResult` | `false` (기본값) | 결제 에러 시 즉시 `onError` 호출 → 위젯 재로드 가능 |

### 권장 사용 패턴

#### 패턴 1: 앱 네이티브 결과 화면 사용 (권장)

가맹점에서 직접 결제 결과 페이지를 구현하여 브랜드 일관성과 사용자 경험을 최적화할 수 있습니다.

```dart
// Payload 설정
_payload.extra = Extra();
_payload.extra?.displaySuccessResult = false;  // 기본값, 권장
_payload.extra?.displayErrorResult = false;    // 기본값, 권장

// Controller 설정
_controller.requestPayment(
  context: context,
  payload: _payload,
  onDone: (String data) {
    // 가맹점 결제 결과 페이지로 이동
    // data에서 receipt_id, order_id 등을 추출하여 서버에서 결제 정보 조회 후 표시
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PaymentResultPage(data: data)),
    );
  },
  onError: (String data) {
    // 에러 후 위젯 재로드 (재시도 가능)
    Future.delayed(Duration(milliseconds: 500), () {
      _controller.reloadWidget();
    });
  },
  onCancel: (String data) {
    // 취소 시 이전 화면으로
    Navigator.pop(context);
  },
  onClose: () {
    Bootpay().dismiss(context);
  },
);
```

**결제 결과 페이지 구현 가이드:**

`onDone` 콜백에서 받은 데이터를 활용하여 결제 결과 페이지를 구현합니다.

```dart
// onDone 콜백에서 받는 주요 데이터 (JSON 파싱 필요)
// {
//   "receipt_id": "영수증 ID (서버 검증용)",
//   "order_id": "주문 ID",
//   "price": 1000,
//   "order_name": "주문명",
//   "method": "결제수단",
//   "pg": "PG사",
//   "purchased_at": "결제일시",
//   "status": 1  // 결제 상태 (1: 성공)
// }

// 서버에서 receipt_id로 결제 정보 검증 후 결과 페이지 표시 권장
```

#### 패턴 2: 웹뷰 결과 화면 사용

빠른 연동이 필요한 경우 부트페이에서 제공하는 웹뷰 결과 화면을 사용할 수 있습니다.

```dart
// Payload 설정
_payload.extra = Extra();
_payload.extra?.displaySuccessResult = true;
_payload.extra?.displayErrorResult = true;

// Controller 설정
_controller.requestPayment(
  context: context,
  payload: _payload,
  onDone: (String data) {
    debugPrint('결제 완료 - 웹뷰에서 결과 화면 표시 중');
    // 별도 처리 불필요, 사용자가 닫기 버튼 클릭 시 onClose 호출
  },
  onError: (String data) {
    debugPrint('결제 에러 - 웹뷰에서 에러 화면 표시 중');
    // 별도 처리 불필요, 사용자가 닫기 버튼 클릭 시 onClose 호출
  },
  onClose: () {
    Navigator.pop(context);
  },
);
```

## 위젯 재로드

에러 또는 취소 후 위젯을 재로드하여 사용자가 재시도할 수 있습니다.

```dart
// 위젯 재로드
_controller.reloadWidget();
```

## 이벤트 콜백 정리

| 콜백 | 설명 | 파라미터 |
|------|------|----------|
| `onWidgetReady` | 위젯 준비 완료 | 없음 |
| `onWidgetResize` | 위젯 높이 변경 | `height: double` |
| `onWidgetChangePayment` | 결제수단 변경 | `data: WidgetData` |
| `onWidgetChangeAgreeTerm` | 약관동의 변경 | `data: WidgetData` |
| `onDone` | 결제 완료 | `data: String (JSON)` |
| `onError` | 결제 에러 | `data: String (JSON)` |
| `onCancel` | 결제 취소 | `data: String (JSON)` |
| `onConfirm` | 결제 확인 (검증) | `data: String (JSON)` → `bool` 반환 |
| `onIssued` | 가상계좌 발급 | `data: String (JSON)` |
| `onClose` | 위젯 닫기 | 없음 |

## WidgetData 구조

```dart
class WidgetData {
  String? pg;                  // PG사 코드
  String? method;              // 결제수단
  String? walletId;            // 지갑 ID
  List<WidgetTerm>? selectTerms;  // 선택된 약관 목록
  String? currency;            // 통화 (KRW, USD)
  bool? termPassed;            // 약관동의 완료 여부
  bool? completed;             // 결제 준비 완료 여부 (결제수단 + 약관동의)
  WidgetExtra? extra;          // 추가 정보
  String? methodOriginSymbol;  // 결제수단 원본 심볼
  String? methodSymbol;        // 결제수단 심볼
  String? easyPay;             // 간편결제 종류
  String? cardQuota;           // 할부 개월
}
```

## 전체 예제 코드

```dart
import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:bootpay/widget/bootpay_widget.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WidgetPage extends StatefulWidget {
  @override
  State<WidgetPage> createState() => WidgetPageState();
}

class WidgetPageState extends State<WidgetPage> {
  Payload _payload = Payload();
  BootpayWidgetController _controller = BootpayWidgetController();
  final ScrollController _scrollController = ScrollController();

  // Application IDs - 부트페이 관리자에서 확인
  String webApplicationId = 'YOUR_WEB_APPLICATION_ID';
  String androidApplicationId = 'YOUR_ANDROID_APPLICATION_ID';
  String iosApplicationId = 'YOUR_IOS_APPLICATION_ID';

  // 결제 정보
  static const String ORDER_NAME = '테스트 상품';
  static const double PRICE = 1000.0;

  double _widgetHeight = 516.0;

  @override
  void initState() {
    super.initState();
    _initPayload();
    _initController();
  }

  void _initPayload() {
    _payload = Payload();
    _payload.webApplicationId = webApplicationId;
    _payload.androidApplicationId = androidApplicationId;
    _payload.iosApplicationId = iosApplicationId;

    _payload.price = PRICE;
    _payload.orderName = ORDER_NAME;
    _payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Widget 필수 설정
    _payload.widgetKey = 'default-widget';
    _payload.widgetSandbox = true;
    _payload.widgetUseTerms = true;

    // User 설정 (선택)
    _payload.user = User();
    _payload.user?.id = 'test_user_1234';
    _payload.user?.username = '홍길동';
    _payload.user?.email = 'test@example.com';
    _payload.user?.phone = '01012341234';

    // Extra 설정 (선택)
    _payload.extra = Extra();
    _payload.extra?.appScheme = 'bootpayFlutterExample';
  }

  void _initController() {
    _controller.onWidgetReady = () {
      debugPrint('[Widget] Ready');
    };

    _controller.onWidgetResize = (height) {
      if (_widgetHeight == height) return;
      setState(() {
        _widgetHeight = height;
      });
    };

    _controller.onWidgetChangePayment = (widgetData) {
      setState(() {
        _payload.mergeWidgetData(widgetData);
      });
    };

    _controller.onWidgetChangeAgreeTerm = (widgetData) {
      setState(() {
        _payload.mergeWidgetData(widgetData);
      });
    };
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(price.toInt())}원';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('결제하기'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    _buildProductWidget(),
                    SizedBox(height: 10),
                    SizedBox(
                      height: _widgetHeight,
                      child: BootpayWidget(
                        payload: _payload,
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('주문상품', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ORDER_NAME, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                SizedBox(height: 8),
                Text(_formatPrice(PRICE), style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    final isCompleted = _payload.widgetIsCompleted;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: isCompleted ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: isCompleted ? _goPayment : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 56,
            child: Center(
              child: Text(
                '${_formatPrice(PRICE)} 결제하기',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goPayment() {
    if (!_payload.widgetIsCompleted) return;

    _controller.requestPayment(
      context: context,
      payload: _payload,
      onCancel: (String data) {
        debugPrint('[Widget] Cancel: $data');
        Future.delayed(Duration(milliseconds: 500), () {
          _controller.reloadWidget();
        });
      },
      onError: (String data) {
        debugPrint('[Widget] Error: $data');
        Future.delayed(Duration(milliseconds: 500), () {
          _controller.reloadWidget();
        });
      },
      onClose: () {
        debugPrint('[Widget] Close');
        if (!kIsWeb) {
          Bootpay().dismiss(context);
        }
      },
      onConfirm: (String data) {
        debugPrint('[Widget] Confirm: $data');
        return true;
      },
      onIssued: (String data) {
        debugPrint('[Widget] Issued: $data');
      },
      onDone: (String data) {
        debugPrint('[Widget] Done: $data');
        // 결제 완료 처리
      },
    );
  }
}
```

## 주의사항

1. **위젯 높이**: 위젯 내용에 따라 높이가 동적으로 변경됩니다. `onWidgetResize` 콜백에서 높이를 업데이트해야 합니다.

2. **결제 버튼 활성화**: `payload.widgetIsCompleted`가 `true`일 때만 결제 버튼을 활성화하세요.

3. **앱 스킴 설정**: 앱투앱 결제(카드사 앱, 은행 앱 등) 후 복귀를 위해 `payload.extra?.appScheme`을 설정해야 합니다.

4. **샌드박스 모드**: 테스트 시 `payload.widgetSandbox = true`로 설정하고, 운영 환경에서는 `false`로 변경하세요.

5. **서버 검증**: `onConfirm` 콜백에서 서버로 결제 정보를 전송하여 검증한 후 결제를 진행하는 것을 권장합니다.

6. **ScrollView 사용**: 위젯 높이가 동적으로 변경되므로 `SingleChildScrollView`를 사용하여 스크롤 가능하게 구성하는 것을 권장합니다.

7. **dismiss 호출**: `onClose` 콜백에서 `Bootpay().dismiss(context)`를 명시적으로 호출하여 결제창을 닫아야 합니다.

## Android 추가 설정

앱투앱 결제 복귀를 위해 `AndroidManifest.xml`에 앱 스킴을 등록해야 합니다.

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="bootpayFlutterExample" />
    </intent-filter>
</activity>
```

## iOS 추가 설정

앱투앱 결제 복귀를 위해 `Info.plist`에 앱 스킴을 등록해야 합니다.

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bootpayFlutterExample</string>
        </array>
    </dict>
</array>
```
