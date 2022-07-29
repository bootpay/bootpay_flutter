# bootpay 플러터 라이브러리 

부트페이에서 지원하는 공식 Flutter 라이브러리 입니다. (클라이언트 용)
* PG 결제창 연동은 클라이언트 라이브러리에서 수행됩니다. (Javascript, Android, iOS, React Native, Flutter 등)
* 결제 검증 및 취소, 빌링키 발급, 본인인증 등의 수행은 서버사이드에서 진행됩니다. (Java, PHP, Python, Ruby, Node.js, Go, ASP.NET 등)

## Bootpay 버전안내 
이 모듈은 web, android, ios를 지원합니다.
android os 16, ios os 9 부터 사용 가능합니다. 

이 모듈의 4.0.0 이상 버전부터는 Bootpay V2 이며,
그 이하 버전은 Bootpay V1에 해당합니다.

Bootpay V1, V2에 대한 특이점은 [개발매뉴얼](https://docs.bootpay.co.kr/?front=android&backend=nodejs#migration-feature)을 참고해주세요.

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

### Web 
flutter web 빌드하면 web/index.html 파일이 생성됩니다. 해당 파일 header에 아래 script를 추가해주세요.
```html 
<!-- bootpay-최신버전-js 를 참조하여 추가합니다 -->
<script src="https://js.bootpay.co.kr/bootpay-4.2.0.min.js"></script> 
<script src="bootpay_api.js" defer></script>
```
[bootpay_api](https://github.com/bootpay/bootpay_flutter/blob/main/example/web/bootpay_api.js) 파일을 프로젝트에 추가합니다.

<img src="https://github.com/bootpay/git-open-resources/blob/main/flutter-web-config.png?raw=true" width="840px" height="525px" title="Github_Logo"/>
위 설정을 완료하면 flutter web에서도 동일한 문법으로 bootpay를 사용할 수 있습니다.


## 결제하기  
```dart 

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
  // runApp(FirstRoute());
}

class FirstRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Route'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('결제 route로 이동'),
          onPressed: () {
            // 눌렀을 때 두 번째 route로 이동합니다.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}

class SecondRoute extends StatefulWidget {

  _SecondRouteState createState() => _SecondRouteState();
}

class _SecondRouteState extends State<SecondRoute> {

// class _MyAppState extends State<MyApp> {
  Payload payload = Payload();
  String _data = ""; // 서버승인을 위해 사용되기 위한 변수

  String get applicationId {
    return Bootpay().applicationId(
        '5b8f6a4d396fa665fdc2b5e7',
        '5b8f6a4d396fa665fdc2b5e8',
        '5b8f6a4d396fa665fdc2b5e9'
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bootpayAnalyticsUserTrace(); //통계용 함수 호출
    bootpayAnalyticsPageTrace(); //통계용 함수 호출
    bootpayReqeustDataInit(); //결제용 데이터 init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      );
  }


  //통계용 함수
  bootpayAnalyticsUserTrace() async {
    String? ver;
    if(kIsWeb) ver = '1.0'; //web 일 경우 버전 지정, 웹이 아닌 android, ios일 경우 package_info 통해 자동으로 생성


    await Bootpay().userTrace(
        id: 'user_1234',
        email: 'user1234@gmail.com',
        gender: -1,
        birth: '19941014',
        area: '서울',
        applicationId: applicationId,
        ver: ver
    );
  }

  //통계용 함수
  bootpayAnalyticsPageTrace() async {
    
    StatItem item1 = StatItem();
    item1.itemName = "미키 마우스"; // 주문정보에 담길 상품명
    item1.unique = "ITEM_CODE_MOUSE"; // 해당 상품의 고유 키
    item1.price = 500; // 상품의 가격
    item1.cat1 = '컴퓨터';
    item1.cat2 = '주변기기';

    StatItem item2 = StatItem();
    item2.itemName = "키보드"; // 주문정보에 담길 상품명
    item2.unique = "ITEM_CODE_KEYBOARD"; // 해당 상품의 고유 키
    item2.price = 500; // 상품의 가격
    item2.cat1 = '컴퓨터';
    item2.cat2 = '주변기기';

    List<StatItem> items = [item1, item2];

    await Bootpay().pageTrace(
        url: 'main_1234',
        pageType: 'sub_page_1234',
        applicationId: applicationId,
        userId: 'user_1234',
        items: items,
        ver: ver
    );
  }

  //결제용 데이터 init
  bootpayReqeustDataInit() {
    Item item1 = Item();
    item1.itemName = "미키 '마우스"; // 주문정보에 담길 상품명
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

    payload.pg = 'danal';
    payload.method = 'card';
    // payload.methods = ['card', 'phone', 'vbank', 'bank', 'kakao'];
    payload.name = "테스트 상품"; //결제할 상품명
    payload.price = 50000.0; //정기결제시 0 혹은 주석


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
    // extra.quotas = [0,2,3];
    extra.quota = '0,2,3';
    extra.popup = 1;
    extra.quickPopup = 1;

    // extra.clo

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능

    payload.user = user;
    payload.extra = extra;
  }


  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    Bootpay().request(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
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
      onReady: (String data) {
        print('------- onReady: $data');
      },
      onConfirm: (String data) {
        /**
        1. 바로 승인하고자 할 때
        return true;
        **/
        /***
        2. 비동기 승인 하고자 할 때
        checkQtyFromServer(data);
        return false;
        ***/
        /***
        3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
        return false; 후에 서버에서 결제승인 수행
         */
        checkQtyFromServer(data);
        return false;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  Future<void> checkQtyFromServer(String data) async {
    //TODO 서버로부터 재고파악을 한다
    print('checkQtyFromServer http call');

    //재고파악 후 결제를 승인한다. 아래 함수를 호출하지 않으면 결제를 승인하지 않게된다.
    Bootpay().transactionConfirm(data);
  }
}
```

## Documentation

[부트페이 개발매뉴얼](https://docs.bootpay.co.kr/)을 참조해주세요

## 기술문의

[채팅](https://bootpay.channel.io/)으로 문의

## License

[MIT License](https://opensource.org/licenses/MIT).

