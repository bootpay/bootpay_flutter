# bootpay 플러터 라이브러리 

부트페이에서 지원하는 공식 Flutter 라이브러리 입니다
* Android, iOS, Web 을 지원합니다.
* Android SDK 16, iOS OS 13 부터 사용 가능합니다.

## Bootpay 버전안내  
이 모듈의 4.0.0 이상 버전부터는 Bootpay V2 이며,
그 이하 버전은 Bootpay V1에 해당합니다.

Bootpay V1, V2에 대한 특이점은 [개발매뉴얼](https://docs.bootpay.co.kr/?front=android&backend=nodejs#migration-feature)을 참고해주세요.

## 기능
1. web/ios/android 지원 
2. 국내 주요 PG사 지원 
3. 주요 결제수단 지원 
4. 카드/계좌 자동결제 지원 
5. 위젯 지원  
6. 본인인증 지원 

## 설치하기 
``pubspec.yaml`` 파일에 아래 모듈을 추가해주세요
```yaml
...
dependencies:
 ...
 bootpay: last_version
...
```

## 설정하기 

### Android
따로 설정하실 것이 없습니다. 

### iOS
#### {your project root}/ios/Runner/Info.plist
``CFBundleURLName``과 ``CFBundleURLSchemes``의 값은 개발사에서 고유값으로 지정해주셔야 합니다. 외부앱(카드사앱)에서 다시 기존 앱으로 돌아올 때 필요한 스키마 값입니다. 
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    ...

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>kr.co.bootpaySample</string> 
            <key>CFBundleURLSchemes</key>
            <array>
                <string>bootpaySample</string> 
            </array>
        </dict>
    </array> 
</dict>
</plist>
```

### Web 
flutter web 빌드하면 web/index.html 파일이 생성됩니다. 해당 파일 header에 아래 script를 추가해주세요.
```html 
<!-- bootpay-최신버전-js 를 참조하여 추가합니다 -->
<script src="https://js.bootpay.co.kr/bootpay-5.0.0.min.js"></script> 
<script src="bootpay_api.js" defer></script>
```
[bootpay_api](https://github.com/bootpay/bootpay_flutter/blob/main/example/web/bootpay_api.js) 파일을 프로젝트에 추가합니다.

<img src="https://github.com/bootpay/git-open-resources/blob/main/flutter-web-config.png?raw=true" width="840px" height="525px" title="Github_Logo"/>
위 설정을 완료하면 flutter web에서도 동일한 문법으로 bootpay를 사용할 수 있습니다.

## 위젯 설정 
[부트페이 관리자](https://developers.bootpay.co.kr/pg/guides/widget)에서 위젯을 생성하셔야만 사용이 가능합니다. 

## 위젯 렌더링 
```dart  
Payload _payload = Payload();
BootpayWidgetController _controller = BootpayWidgetController();

@override
void initState() {
  // TODO: implement initState
  super.initState();
  
  _payload.orderName = '5월 수강료';
  _payload.orderId = DateTime
      .now()
      .millisecondsSinceEpoch
      .toString();
  _payload.webApplicationId = webApplicationId;
  _payload.androidApplicationId = androidApplicationId;
  _payload.iosApplicationId = iosApplicationId;
  _payload.price = 1000;
  _payload.taxFree = 0;
  _payload.widgetKey = 'default-widget';
  _payload.widgetSandbox = true;
  _payload.widgetUseTerms = true;
  // _payload.userToken = "6667b08b04ab6d03f274d32e";
  _payload.extra?.displaySuccessResult = true;
}

@override
Widget build(BuildContext context) {
  return Container(
    //하위로 위젯 정의  
      child: BootpayWidget(
        payload: _payload,
        controller: _controller,
      )
  );
}


```

## 위젯 이벤트 처리 
```dart
@override
void initState() {
  // TODO: implement initState
  super.initState();
  // BootpayWidgetController _controller = BootpayWidgetController();
  //위젯 사이즈 변경 이벤트 
  _controller.onWidgetResize = (height) {
    print('onWidgetResize : $height');
    //예제에서는 높이가 변경되면 스크롤을 내립니다.
    if(_widgetHeight == height) return;
    if(_widgetHeight < height) {
      scrollDown(height - _widgetHeight);
    }
    setState(() {
      _widgetHeight = height;
    });
  };
  //선택된 결제수단 변경 이벤트 
  _controller.onWidgetChangePayment = (widgetData) {
    print('onWidgetChangePayment22 : ${widgetData?.toJson()}');
    //예제에서는 widgetData 정보를 payload에 반영합니다. 반영된 payload는 추후 결제요청시 사용됩니다.
    setState(() {
      _payload?.mergeWidgetData(widgetData);
    });
  };
  //선택된 약관 변경 이벤트
  _controller.onWidgetChangeAgreeTerm = (widgetData) {
    print('onWidgetChangeAgreeTerm : ${widgetData?.toJson()}');
    //예제에서는 widgetData 정보를 payload에 반영합니다. 반영된 payload는 추후 결제요청시 사용됩니다.
    setState(() {
      _payload?.mergeWidgetData(widgetData);
    });
  };
  //위젯이 렌더링되면 호출되는 이벤트
  _controller.onWidgetReady = () {
    print('onWidgetReady');
  };
}
```

## 위젯으로 결제하기 
이 방법은 위젯을 사용하여 결제하는 방법입니다. 위젯을 사용하지 않고 결제를 요청하는 방법은 별도로 제공합니다. 
```dart
// BootpayWidgetController _controller = BootpayWidgetController();
_controller.requestPayment(
    context: context,
    payload: _payload,
    onCancel: (String data) {
        print('------- onCancel 2 : $data');
    },
    onError: (String data) {
        print('------- onError: $data');
    },
    onClose: () {
        print('------- onClose');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }
    },
    onConfirm: (String data)  {
        print('------- onConfirm: $data');
        return true; //결제를 승인합니다 
    },
    onIssued: (String data) {
        print('------- onIssued: $data');
    },
    onDone: (String data) {
        print('------- onDone: $data');
        // FlutterToast.showToast(msg: '결제가 완료되었습니다.');
    },
);
```

## 결제하기
이 방법은 위젯을 사용하지 않고 결제하는 방법입니다.
```dart 
//결제 정보를 초기화합니다.
void bootpayReqeustDataInit() {
  Item item1 = Item();
  item1.name = "미키 '마우스"; // 주문정보에 담길 상품명
  item1.qty = 1; // 해당 상품의 주문 수량
  item1.id = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
  item1.price = 500; // 상품의 가격

  Item item2 = Item();
  item2.name = "키보드"; // 주문정보에 담길 상품명
  item2.qty = 1; // 해당 상품의 주문 수량
  item2.id = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
  item2.price = 500; // 상품의 가격
  List<Item> itemList = [item1, item2];

  payload.webApplicationId = webApplicationId; // web application id
  payload.androidApplicationId = androidApplicationId; // android application id
  payload.iosApplicationId = iosApplicationId; // ios application id

  payload.pg = '다날';
  payload.method = '카드';
  // payload.methods = ['카드', '휴대폰', '가상계좌', '계좌이체', '카카오페이'];
  payload.orderName = "테스트 상품"; //결제할 상품명
  payload.price = 1000.0; //정기결제시 0 혹은 주석

  payload.orderId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함

  payload.metadata = {
    "callbackParam1" : "value12",
    "callbackParam2" : "value34",
    "callbackParam3" : "value56",
    "callbackParam4" : "value78",
  }; // 전달할 파라미터, 결제 후 되돌려 주는 값
  payload.items = itemList; // 상품정보 배열


  User user = User(); // 구매자 정보
  user.id = "12341234";
  user.username = "사용자 이름";
  user.email = "user1234@gmail.com";
  user.area = "서울";
  user.phone = "010-0000-0000";
  user.addr = 'null';

  Extra extra = Extra(); // 결제 옵션
  extra.appScheme = 'bootpayFlutter'; //결제 후 돌아갈 ios 앱 스키마를 설정합니다 
   
  payload.user = user;
  payload.items = itemList;
  payload.extra = extra; 
}

void goBootpayPayment(BuildContext context) {
  Bootpay().requestPayment(
    context: context,
    payload: payload,
    showCloseButton: false,

    // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
    onCancel: (String data) {
      print('------- onCancel 1 : $data');
    },
    onError: (String data) {
      print('------- onError: $data');
    },
    onClose: () {
      print('------- onClose');
      if (!kIsWeb) {
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
      }
    },
    onIssued: (String data) {
      print('------- onIssued: $data');
    },
    onConfirm: (String data)  { 
      // checkQtyFromServer(data);
      return true;
    },
    // onConfirmAsync: (String data) async {
    //   onConfirm 대신 사용하는 이벤트 처리 함수입니다. 내부에서 Future 문법을 사용할 수 있습니다.
    //   print('------- onConfirmAsync: $data');
    //   return true;
    // },
    onDone: (String data) {
      print('------- onDone: $data');
    },
  );
}
```

### Bootpay 승인 요청 
onConfirm, onConfirmAsync에서 승인 요청시 사용하는 함수입니다. 이 함수는 return false 로 리턴할 경우 사용합니다.  
```dart
Bootpay().transactionConfirm();
return false; 
```

### Bootpay 창 닫기 
onConfirm, onConfirmAsync등에서 진행중인 결제창을 닫을 때 사용하는 함수입니다. 서버인증으로 승인이 되었을 경우에, 클라이언트에서 창을 닫을 때 사용합니다.
```dart
Bootpay().dismiss(context);
return false; 
```

## 자동결제 - 빌링키 발급 요청하기 
 
```dart
void goBootpaySubscriptionUITest(BuildContext context) {
    payload.subscriptionId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    payload.pg = "키움페이";
    payload.method = "카드자동"; 
    // payload.price = 1000; 금액이 0 이상일 경우 빌링키 발급 후 결제가 진행됩니다.

    payload.metadata = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값

    Bootpay().requestSubscription(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel 3: $data');
      },
      onError: (String data) {
        print('------- onError 3: $data');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }
      },
      onClose: () {
        print('------- onClose');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }

        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onConfirm: (String data) { 
        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }
```

## 본인인증 

```dart
payload.pg = "다날";
payload.method = "본인인증";
payload.authenticationId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
payload.extra = Extra();
payload.extra?.openType = 'iframe';
payload.items = null;

Bootpay().requestAuthentication(
  context: context,
  payload: payload,
  showCloseButton: false,
  // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
  onCancel: (String data) {
    print('------- onCancel: $data');
  },
  onError: (String data) {
    print('------- onError: $data');
  },
  onClose: () {
    print('------- onClose');
    if (!kIsWeb) {
      Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
    }
  },
  onIssued: (String data) {
    print('------- onIssued: $data');
  },
  onConfirm: (String data) { 
    return true;
  },
  onDone: (String data) {
    print('------- onDone: $data');
  },
);
```

결제 진행 상태에 따라 LifeCycle 함수가 실행됩니다. 각 함수에 대한 상세 설명은 아래를 참고하세요.

### onError 함수
결제 진행 중 오류가 발생된 경우 호출되는 함수입니다. 진행중 에러가 발생되는 경우는 다음과 같습니다.

1. **부트페이 관리자에서 활성화 하지 않은 PG, 결제수단을 사용하고자 할 때**
2. **PG에서 보내온 결제 정보를 부트페이 관리자에 잘못 입력하거나 입력하지 않은 경우**
3. **결제 진행 도중 한도초과, 카드정지, 휴대폰소액결제 막힘, 계좌이체 불가 등의 사유로 결제가 안되는 경우**
4. **PG에서 리턴된 값이 다른 Client에 의해 변조된 경우**

에러가 난 경우 해당 함수를 통해 관련 에러 메세지를 사용자에게 보여줄 수 있습니다.

data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayError",
  message: "카드사 거절",
  receipt_id: "5fffab350c20b903e88a2cff"
}
```


### onCancel 함수
결제 진행 중 사용자가 PG 결제창에서 취소 혹은 닫기 버튼을 눌러 나온 경우 입니다. ****

data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayCancel",
  message: "사용자가 결제를 취소하였습니다.",
  receipt_id: "5fffab350c20b903e88a2cff"
}
```


### onIssued 함수
가상계좌 발급이 완료되면 호출되는 함수입니다(가상계좌를 위한 Done). 가상계좌는 다른 결제와 다르게 입금할 계좌 번호 발급 이후 입금 후에 Feedback URL을 통해 통지가 됩니다. 발급된 가상계좌 정보를 issued 함수를 통해 확인하실 수 있습니다.

data 포맷은 아래와 같습니다.

```text
{
  account: "T0309260001169"
  accounthodler: "한국사이버결제"
  action: "BootpayBankReady"
  bankcode: "BK03"
  bankname: "기업은행"
  expiredate: "2021-01-17 00:00:00"
  item_name: "테스트 아이템"
  method: "vbank"
  method_name: "가상계좌"
  order_id: "1610591554856"
  metadata: null
  payment_group: "vbank"
  payment_group_name: "가상계좌"
  payment_name: "가상계좌"
  pg: "kcp"
  pg_name: "KCP"
  price: 3000
  purchased_at: null
  ready_url: "https://dev-app.bootpay.co.kr/bank/7o044QyX7p"
  receipt_id: "5fffad430c20b903e88a2d17"
  requested_at: "2021-01-14 11:32:35"
  status: 2
  tax_free: 0
  url: "https://d-cdn.bootapi.com"
  username: "홍길동"
}
```


### onConfirm 함수
결제 승인이 되기 전 호출되는 함수입니다. 승인 이전 관련 로직을 서버 혹은 클라이언트에서 수행 후 결제를 승인해도 될 경우`BootPay.transactionConfirm(data); 또는 return true;`

코드를 실행해주시면 PG에서 결제 승인이 진행이 됩니다.

**\* 페이앱, 페이레터 PG는 이 함수가 실행되지 않고 바로 결제가 승인되는 PG 입니다. 참고해주시기 바랍니다.**

data 포맷은 아래와 같습니다.

```text
{
  receipt_id: "5fffc0460c20b903e88a2d2c",
  action: "BootpayConfirm"
}
```


### onDone 함수
PG에서 거래 승인 이후에 호출 되는 함수입니다. 결제 완료 후 다음 결제 결과를 호출 할 수 있는 함수 입니다.

이 함수가 호출 된 후 반드시 REST API를 통해 [결제검증](https://developers.bootpay.co.kr/pg/server/receipt)을 수행해증야합니다. data 포맷은 아래와 같습니다.

```text
{
  action: "BootpayDone"
  card_code: "CCKM",
  card_name: "KB국민카드",
  card_no: "0000120000000014",
  card_quota: "00",
  item_name: "테스트 아이템",
  method: "card",
  method_name: "카드결제",
  order_id: "1610596422328",
  payment_group: "card",
  payment_group_name: "신용카드",
  payment_name: "카드결제",
  pg: "kcp",
  pg_name: "KCP",
  price: 100,
  purchased_at: "2021-01-14 12:54:53",
  receipt_id: "5fffc0460c20b903e88a2d2c",
  receipt_url: "https://app.bootpay.co.kr/bill/UFMvZzJqSWNDNU9ERWh1YmUycU9hdnBkV29DVlJqdzUxRzZyNXRXbkNVZW81%0AQT09LS1XYlNJN1VoMDI4Q1hRdDh1LS10MEtZVmE4c1dyWHNHTXpZTVVLUk1R%0APT0%3D%0A",
  requested_at: "2021-01-14 12:53:42",
  status: 1,
  tax_free: 0,
  url: "https://d-cdn.bootapi.com"
}
```


## Documentation

[부트페이 개발매뉴얼](https://developer.bootpay.co.kr/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

