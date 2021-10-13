# bootpay - bootpay flutter library 

부트페이에서 지원하는 공식 Flutter 라이브러리 입니다. (클라이언트 용)
* PG 결제창 연동은 클라이언트 라이브러리에서 수행됩니다. (Javascript, Android, iOS, React Native, Flutter 등)
* 결제 검증 및 취소, 빌링키 발급, 본인인증 등의 수행은 서버사이드에서 진행됩니다. (Java, PHP, Python, Ruby, Node.js, Go, ASP.NET 등)

## 기능 

1. web/ios/android 지원 
2. 국내 주요 PG사 지원 
3. 신용카드/계좌이체/가상계좌/휴대폰소액결제
4. 부트페이 통합결제 / 정기결제 / 생체인증 결제 지원
5. 본인인증 지원 

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
** {your project root}/ios/Runner/Info.plist **
``CFBundleURLName``과 ``CFBundleURLSchemes``의 값은 개발사에서 고유값으로 지정해주셔야 합니다. 외부앱(카드사앱)에서 다시 기존 앱으로 앱투앱 호출시 필요한 스키마 값입니다. 
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

    ...
    <key>NSFaceIDUsageDescription</key>
    <string>생체인증 결제 진행시 권한이 필요합니다</string>
</dict>
</plist>
```

## 결제하기  
```dart 
import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Payload payload = Payload();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Item item1 = Item();
    item1.itemName = "미키 마우스"; // 주문정보에 담길 상품명
    item1.qty = 1; // 해당 상품의 주문 수량
    item1.unique = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격

    Item item2 = Item();
    item2.itemName = "키보드"; // 주문정보에 담길 상품명
    item2.qty = 1; // 해당 상품의 주문 수량
    item2.unique = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    List<Item> itemList = [item1, item2];

    payload.webApplicationId = '5b8f6a4d396fa665fdc2b5e7'; // web application id
    payload.androidApplicationId = '5b8f6a4d396fa665fdc2b5e8'; // android application id
    payload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9'; // ios application id


    payload.pg = 'nicepay';
    payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    payload.name = '테스트 상품'; //결제할 상품명
    payload.price = 1000.0; //정기결제시 0 혹은 주석
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    payload.params = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    }; // 전달할 파라미터, 결제 후 되돌려 주는 값
    payload.items = itemList; // 상품정보 배열

    User user = User(); // 구매자 정보
    user.username = "사용자 이름";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-4033-4678";
    user.addr = '서울시 동작구 상도로 222';

    Extra extra = Extra(); // 결제 옵션
    extra.appScheme = 'bootpayFlutterExample';
    extra.quotas = [0,2,3];
    extra.popup = 1;
    extra.quick_popup = 1;

    payload.user = user;
    payload.extra = extra;
  }

  String _data = "";
  void goBootpayTest(BuildContext context) {
    Bootpay().request(
      context: context,
      payload: payload,
      showCloseButton: false,
      closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel: $data');
      },
      onError: (String data) {
        print('------- onCancel: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        //TODO - 원하시는 라우터로 페이지 이동
      },
      onCloseHardware: () {
        print('------- onCloseHardware');
      },
      onReady: (String data) {
        print('------- onReady: $data');
      },
      onConfirm: (String data) {
        print('------- onConfirm: $data');
        _data = data;

        // Future.delayed(const Duration(milliseconds: 100), () {
        //   Bootpay().transactionConfirm(_data); // 서버승인 이용시 해당 함수 호출
        // });
        // return false;
        return true; //결제를 최종 승인하고자 할때 return true
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Container(
            child: Center(
              child: TextButton(
                onPressed: () => goBootpayTest(context),
                child: Text('부트페이 결제테스트'),
              )
            ),
          );
        }),
      ),
    );
  }
}
```

## Documentation

[부트페이 개발매뉴얼](https://bootpay.gitbook.io/docs/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

