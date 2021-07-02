import 'dart:io';
import 'dart:convert';

import 'package:bootpay_flutter/model/extra.dart';
import 'package:bootpay_flutter/model/item.dart';
import 'package:bootpay_flutter/model/user.dart';
import 'package:flutter/foundation.dart';

class Payload {
  String applicationId = '';
  String androidApplicationId = '';
  String iosApplicationId = '';

  String pg = '';
  String method = '';
  List<String> methods = [];
  String name = '';

  double price = 0;
  double taxFree = 0;

  String orderId = '';
  int useOrderId = 0;

  Map<String, dynamic> params = {};

  String accountExpireAt = '';
  bool showAgreeWindow = false;
  String userToken = '';

  Extra extra = Extra();
  User user = User();
  List<Item> items = [];

  Payload();

  Payload.fromJson(Map<String, dynamic> json) {
    androidApplicationId = json["android_application_id"];
    iosApplicationId = json["ios_application_id"];

    pg = json["pg"];
    method = json["method"];
    methods = json["methods"];
    name = json["name"];

    price = json["price"];
    taxFree = json["tax_free"];

    orderId = json["order_id"];
    useOrderId = json["use_order_id"];

    params = json["params"];

    accountExpireAt = json["account_expire_at"];
    showAgreeWindow = json["show_agree_window"];
  }


  Map<String, dynamic> toJson() =>
      {
        'application_id': getApplicationId(),
        'pg': pg,
        'method': method,
        'methods': methods,
        'name': name,
        'price': price,
        'tax_free': taxFree,
        'order_id': orderId,
        'use_order_id': useOrderId,
        'params': params,
        'account_expire_at': accountExpireAt,
        'show_agree_window': showAgreeWindow
      };

  getApplicationId() {
    if(kIsWeb) return this.applicationId;
    if(Platform.isIOS) return this.iosApplicationId;
    else return this.androidApplicationId;
  }

  String toString() {
    return "{application_id: '${getApplicationId()}', pg: '$pg', method: '$method', methods: ${getMethodList()}, name: '$name', price: $price, tax_free: $taxFree, order_id: '$orderId', use_order_id: $useOrderId, params: ${getParamsStringAndroid()}, account_expire_at: '$accountExpireAt', show_agree_window: $showAgreeWindow, user_token: '$userToken', extra: ${extra.toString()}, user_info: ${user.toString()}, items: ${getItems()}}";
  }

  String getMethodList() {
    return "[${methods.join("'")}]";
  }

  String getItems() {
    List<String> result = [];
    for(Item item in this.items) {
      result.add(item.toString());
    }
    return "[${result.join(",")}]";
  }

  String getParamsStringAndroid() {
    return reVal(json.encode(params));
    // return '{}';
  }

  String getParamsString() {
    if (params == null) return "{}";
    return reVal(params.toString());
  }

  dynamic reVal(dynamic value) {
    if (value is String) {
      if (value.isEmpty) {
        return '';
      }
      return value.replaceAll("\"", "'");
    } else {
      return value;
    }
  }

  String getMethods() {
    if (methods.isEmpty) return '';
    String result = '';
    for (String method in methods) {
      if (result.length > 0) result += ',';
      result += method;
    }
    return result;
  }
}
