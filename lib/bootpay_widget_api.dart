
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;

import 'model/stat_item.dart';

mixin BootpayWidgetApi {

  // void setEnvironmentMode(String locale);

  void render(
      {
        Key? key,
        BuildContext? context,
        Payload? payload
      });

  void update(
      {
        Key? key,
        BuildContext? context,
        Payload? payload
      });
}