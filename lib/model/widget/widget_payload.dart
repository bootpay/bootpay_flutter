import 'dart:io';
import 'dart:convert';

import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/widget/oopay.dart';

import '../extra.dart';
import '../item.dart';
import '../user.dart';
import '../../extension/json_query_string.dart';
import 'package:flutter/foundation.dart';

class WidgetPayload {
  String? webApplicationId = '';
  String? widgetKey = 'default-widget';
  String? androidApplicationId = '';
  String? iosApplicationId = '';

  double? price = 0;
  double? taxFree = 0;

  bool? use_terms = true;
  bool? sandbox = true;

  Oopay? oopay = Oopay();

  WidgetPayload({
      this.webApplicationId,
      this.androidApplicationId,
      this.iosApplicationId,
      this.widgetKey,
      this.price,
      this.taxFree,
      this.use_terms,
      this.sandbox,
      this.oopay}) {
    this.use_terms = true;
    this.sandbox = true;
    this.widgetKey = 'default-widget';
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     "application_id": applicationId,
  //     "price": price,
  //     "tax_free": taxFree,
  //     "use_terms": use_terms,
  //     "sandbox": sandbox,
  //     "oopay": oopay?.toJson()
  //   };
  // }

  String toString() {
    List<String> parts = [];

    void addPart(String key, dynamic value, {bool? isOriginal}) {
      if (value != null) {
        if(isOriginal == true) {
          parts.add("$key: $value");
        } else {
          // String formattedValue = value is String ? "'${value.replaceAll("'", "\\'")}'" : value.toString(
          String formattedValue = value is String ? "'${value.queryReplace()}'" : value.toString();
          parts.add("$key: $formattedValue");
        }
      }
    }

    addPart('application_id', applicationId);
    addPart('price', price);
    addPart('tax_free', taxFree);
    addPart('use_terms', use_terms);
    addPart('sandbox', sandbox);
    addPart('widget_key', widgetKey);
    addPart('oopay', oopay?.toJson());
    return "{${parts.join(", ")}}";
  }

  String get applicationId {
    if(kIsWeb || BootpayConfig.IS_FORCE_WEB) return this.webApplicationId ?? '';
    else if(Platform.isIOS) return this.iosApplicationId ?? '';
    else return this.androidApplicationId ?? '';
  }
}