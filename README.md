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

### 자동결제
 
```dart
```


## Documentation

[부트페이 개발매뉴얼](https://developer.bootpay.co.kr/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

