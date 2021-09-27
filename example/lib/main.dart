
import 'dart:io';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/bootpay_webview.dart';
import 'package:bootpay_webview_flutter/webview_flutter.dart';

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

    // _payload = Payload();
    // _payload.app
    payload.webApplicationId = '5b8f6a4d396fa665fdc2b5e7';
    payload.androidApplicationId = '5b8f6a4d396fa665fdc2b5e8';
    payload.iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';

    payload.pg = 'kcp';
    // payload.method = 'card';
    payload.methods = ['card', 'phone', 'vbank', 'bank'];
    payload.name = '테스트 상품';
    payload.price = 1000.0; //정기결제시 0 혹은 주석
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();
    payload.params = {
      "callbackParam1" : "value12",
      "callbackParam2" : "value34",
      "callbackParam3" : "value56",
      "callbackParam4" : "value78",
    };
    payload.items = itemList;

    User user = User();
    user.username = "사용자 이름";
    user.email = "user1234@gmail.com";
    user.area = "서울";
    user.phone = "010-4033-4678";
    user.addr = '서울시 동작구 상도로 222';

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterExample';
    extra.quotas = [0,2,3];
    extra.popup = 1;
    extra.quick_popup = 1;

    payload.user = user;
    payload.extra = extra;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(builder: (BuildContext context) {
          return Container(
            child: Center(
              child: TextButton(
                onPressed: () => Bootpay().request(
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
                    return true;
                  },
                  onDone: (String data) {
                    print('------- onDone: $data');
                  },
                ),
                child: Text('부트페이 결제테스트'),
              )
            ),
          );
        }),
      ),
    );
  }
}