

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/bootpay_webview.dart';
import 'package:bootpay/bootpay_widget_api.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/browser_open_type.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:bootpay/model/user.dart';
import 'package:bootpay_flutter_example/webapp_payment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'deprecated/api_provider.dart';

import 'package:intl/intl.dart';

import 'widget_page.dart';

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
        child: TextButton(
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

class SecondRoute extends StatelessWidget {
  SecondRoute({super.key});

  Payload payload = Payload();
  //
  String webApplicationId = '5b8f6a4d396fa665fdc2b5e7';
  String androidApplicationId = '5b8f6a4d396fa665fdc2b5e8';
  String iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';

   
  // extra.browserOpenType = [];
  // String webApplicationId = '5b9f51264457636ab9a07cdb';
  // String androidApplicationId = '5b9f51264457636ab9a07cdc';
  // String iosApplicationId = '5b9f51264457636ab9a07cdd';




  String get applicationId {
    return Bootpay().applicationId(
      webApplicationId,
      androidApplicationId,
      iosApplicationId
    );
  }

  void init() {
    // TODO: implement initState
    bootpayAnalyticsUserTrace(); //통계용 함수 호출
    bootpayAnalyticsPageTrace(); //통계용 함수 호출
    bootpayReqeustDataInit(); //결제용 데이터 init
  }


  @override
  Widget build(BuildContext context) {

    init();

    return Scaffold(
      body: Container(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const TextField(),
                Center(
                  child: TextButton(
                    onPressed: () => goBootpayTest(context),
                    child: Text('일반결제 테스트'),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => goBootpaySubscriptionUITest(context),
                    child: Text('비인증 정기결제 테스트 (부트페이 UI)'),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => goBootpaySubscriptionTest(context),
                    child: Text('인증 정기결제 테스트 (PG사 UI)'),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: () => goBootpayAuthTest(context),
                    child: Text('본인인증 테스트'),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => goBootpayWebapp(context),
                    child: Text('웹앱 테스트'),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () => goWidgetTest(context),
                    child: Text('위젯 테스트'),
                  ),
                ),
                SizedBox(height: 10),
                // Center(
                //   child: TextButton(
                //     onPressed: () => goBootpayPassword(context),
                //     child: Text('비밀번호 결제테스트'),
                //   ),
                // ),
              ],
            ),
          ),
        )
      );
  }

  ApiProvider _provider = ApiProvider();

  //해당 기능은 혼동을 줄 수 있으므로 bio_password 사용을 대체, 그러므로 삭제
  // @deprecated
  // goBootpayPassword(BuildContext context) async {
  //   String userToken = await getUserToken(context);
  //   bootpayPasswordTest(context, userToken, generateUser());
  // }


  void bootpayPasswordTest(BuildContext context, String userToken, User user) {
    payload.userToken = userToken;
    if(kIsWeb) {
      //flutter web은 cors 이슈를 설정으로 먼저 해결해주어야 한다.
      payload.extra?.openType = 'iframe';
    }

    Bootpay().requestPassword(
      context: context,
      payload: payload,
      showCloseButton: false,

      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data)  {
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
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      // onConfirm: (String data) {
      //   /**
      //       1. 바로 승인하고자 할 때
      //       return true;
      //    **/
      //   /***
      //       2. 비동기 승인 하고자 할 때
      //       checkQtyFromServer(data);
      //       return false;
      //    ***/
      //   /***
      //       3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
      //       return false; 후에 서버에서 결제승인 수행
      //    */
      //   // checkQtyFromServer(data);
      //   // return true;
      //   return false;
      // },
      onConfirmAsync: (String data) async {

        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  Future<String> getUserToken(BuildContext context) async {
    String restApplicationId = "5b8f6a4d396fa665fdc2b5ea";
    String pk = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=";
    var res = await _provider.getRestToken(restApplicationId, pk);


    res = await _provider.getEasyPayUserToken(res.body['access_token'], generateUser());
    // bootpayTest(context, res.body["user_token"], user);
    return res.body["user_token"];
  }


  User generateUser() {
    var user = User();
    user.id = '123411aaaaaaaaaaaabd4ss11';
    user.gender = 1;
    user.email = 'test1234@gmail.com';
    user.phone = '01012345678';
    user.birth = '19880610';
    user.username = '홍길동';
    user.area = '서울';
    return user;
  }


  //통계용 함수
  bootpayAnalyticsUserTrace() async {

    await Bootpay().userTrace(
        id: 'user_1234',
        email: 'user1234@gmail.com',
        gender: -1,
        birth: '19941014',
        area: '서울',
        applicationId: applicationId
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
        items: items
    );
  }

  //결제용 데이터 init
  bootpayReqeustDataInit() {
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


    // payload.pg = '다날';
    // payload.method = '카드';
    // payload.method = '네이버페이';
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
    extra.appScheme = 'bootpayFlutter';
    extra.directCardCompany = "국민";
    extra.directCardQuota = '00'; //directCardCompany 일 경우 할부정보는 필수
    // extra.separatelyConfirmed = true;


    if(BootpayConfig.ENV == -1) {
      payload.extra?.redirectUrl = 'https://dev-api.bootpay.co.kr/v2';
    } else if(BootpayConfig.ENV == -2) {
      payload.extra?.redirectUrl = 'https://stage-api.bootpay.co.kr/v2';
    }  else {
      payload.extra?.redirectUrl = 'https://api.bootpay.co.kr/v2';
    }

    // extra.openType = 'popup';

    // extra.carrier = "SKT,KT,LGT"; //본인인증 시 고정할 통신사명
    // extra.ageLimit = 20; // 본인인증시 제한할 최소 나이 ex) 20 -> 20살 이상만 인증이 가능


    payload.user = user;
    payload.items = itemList;
    payload.extra = extra;
    // payload.extra?.openType = "iframe";
    
  }


  //버튼클릭시 부트페이 결제요청 실행
  void goBootpayTest(BuildContext context) {
    if(kIsWeb) {
      //flutter web은 cors 이슈를 설정으로 먼저 해결해주어야 한다.
      payload.extra?.openType = 'iframe';
    }
    payload.extra?.browserOpenType = [
      BrowserOpenType.fromJson({"browser": "naver", "open_type": 'popup'}),
    ];

    // print('popup');
    // payload.extra?.openType = 'popup';

    payload.pg = '페이앱';
    payload.method = "네이버페이";

    // BootpayConfig.IS_FORCE_WEB = true;
    // BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION = true;

    // payload.extra?.displayCashReceipt = false;
    // payload.extra?.exceptCardCompanies = ['하나', 'BC', '현대'];
    // payload.extra?.escrow = true;
    // payload.extra?.locale = 'en'; //app locale
    // Bootpay().setLocale('en'); //web locale

    // payload.extra?.depositExpiration = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now().add(const Duration(days: 7)));



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
      // onConfirm: (String data)  {
      //
      //   // checkQtyFromServer(data, context).then((value) => print(1243));
      //   // await check
      //
      //   print('------- onConfirm: $data');
      //
      //   // checkQtyFromServer(data);
      //   return true;
      // },
      onConfirmAsync: (String data) async {
        print('------- onConfirmAsync: $data');

        return true;
      },
      // onConfirmAsync: (String data) async {
      //   print('------- onConfirmAsync11: $data');
      //   /**
      //       1. 바로 승인하고자 할 때
      //       return true;
      //    **/
      //   /***
      //       2. 비동기 승인 하고자 할 때
      //       checkQtyFromServer(data);
      //       return false;
      //    ***/
      //   /***
      //       3. 서버승인을 하고자 하실 때 (클라이언트 승인 X)
      //       return false; 후에 서버에서 결제승인 수행
      //    */
      //
      //   await checkQtyFromServer(data);
      //   print('------- onConfirmAsync22: $data');
      //   // return true;
      //   // return true;
      //   return true;
      // },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  //버튼클릭시 부트페이 정기결제 요청 실행
  void goBootpaySubscriptionTest(BuildContext context) {
    payload.subscriptionId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    // payload.pg = "토스";
    // payload.method = "카드정기";
    // payload.extra?.subscribeTestPayment = false;


    Bootpay().requestSubscription(
      context: context,
      payload: payload,
      showCloseButton: false,
      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel 2: $data');
      },
      onError: (String data) {
        print('------- onError 2: $data');
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출

        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
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

  void goBootpaySubscriptionUITest(BuildContext context) {
    payload.subscriptionId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    // payload.pg = 'kakao';
    // payload.method = 'easy_rebill';

    payload.pg = "나이스페이";
    payload.method = "카드자동";
    // payload.extra?.subscribeTestPayment = false;


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
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
      },
      onClose: () {
        print('------- onClose');
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출

        //TODO - 원하시는 라우터로 페이지 이동
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
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

  void goBootpayWebapp(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => WebAppPayment()));

  }

  void goBootpayAuthTest(BuildContext context) {


    payload.pg = "다날";
    payload.method = "본인인증";
    payload.authenticationId = DateTime.now().millisecondsSinceEpoch.toString(); //주문번호, 개발사에서 고유값으로 지정해야함
    payload.extra = Extra();
    payload.extra?.openType = 'iframe';
    payload.extra?.showCloseButton = true;
    // payload.extra?.show
    // payload.extra?.ageLimit = 40;


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
        Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
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

        // Bootpay().dismiss(context);
        // return false;
        return true;
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

  void goWidgetTest(BuildContext context) {
    // BootpayWid
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WidgetPage()),
    );
  }



  Future<void> checkQtyFromServer(String data) async {
    //TODO 서버로부터 재고파악을 한다
    print('checkQtyFromServer start: $data');
    return Future.delayed(Duration(seconds: 1), () {
      print('checkQtyFromServer end: $data');

      Bootpay().transactionConfirm();
      return true;
    });
  }
}