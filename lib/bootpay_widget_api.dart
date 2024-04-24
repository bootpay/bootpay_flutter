
import 'package:bootpay/model/widget/widget_payload.dart';
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
        WidgetPayload? widgetPayload
      });

  void update(
      {
        Key? key,
        BuildContext? context,
        Payload? payload
      });
}