
import 'package:bootpay/config/bootpay_config.dart';

import 'bootpay_widget_api.dart';
import 'model/stat_item.dart';
import 'shims/bootpay_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bootpay_api.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;



class BootpayWidget extends BootpayWidgetApi {
  static final BootpayWidget _bootpayWidget = BootpayWidget._internal();
  factory BootpayWidget() {
    return _bootpayWidget;
  }
  BootpayWidget._internal() {
    _platform = BootpayPlatform();
  }

  late BootpayPlatform _platform;


  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return _platform.applicationId(webApplicationId, androidApplicationId, iosApplicationId);
  }

  @override
  void render({Key? key, BuildContext? context, String? divId, Payload? payload}) {
    // TODO: implement render
  }

  @override
  void update({Key? key, BuildContext? context, Payload? payload, bool? showCloseButton}) {
    // TODO: implement update
  }
}
