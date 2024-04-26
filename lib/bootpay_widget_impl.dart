
import 'package:bootpay/config/bootpay_config.dart';

import 'bootpay_widget_api.dart';
import 'model/stat_item.dart';
import 'shims/bootpay_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bootpay_api.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;

// https://webview.bootpay.co.kr/5.0.0-beta.30/widget.html

// document.addEventListener('bootpaywidgetresize', function (e) {
// console.log(e.detail)
// })

class BootpayWidgetImpl with BootpayWidgetApi {
  static final BootpayWidgetImpl _bootpayWidget = BootpayWidgetImpl._internal();
  factory BootpayWidgetImpl() {
    return _bootpayWidget;
  }
  BootpayWidgetImpl._internal() {
    _platform = BootpayPlatform();
  }

  late BootpayPlatform _platform;


  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return _platform.applicationId(webApplicationId, androidApplicationId, iosApplicationId);
  }

  @override
  void render({Key? key, BuildContext? context, Payload? payload}) {
    _platform.render(context: context, key: key, payload: payload);
  }

  @override
  void update({Key? key, BuildContext? context, Payload? payload}) {
    _platform.update(context: context, key: key, payload: payload);
  }
}
