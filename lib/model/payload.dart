import 'dart:io';
import 'dart:convert';

import 'extra.dart';
import 'item.dart';
import 'user.dart';
import 'package:flutter/foundation.dart';

class Payload {
  String? webApplicationId = '';
  String? androidApplicationId = '';
  String? iosApplicationId = '';

  String? pg = '';
  String? method = '';
  List<String>? methods = [];
  String? name = '';

  double? price = 0;
  double? taxFree = 0;

  String? orderId = '';
  int? useOrderId = 0;

  Map<String, dynamic>? params = {};

  String? accountExpireAt = '';
  bool showAgreeWindow = false;
  String? userToken = '';

  Extra? extra = Extra();
  User? user = User();
  List<Item>? items = [];

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


  //실제 사용되지 않음
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'application_id': getApplicationId(),
      'pg': pg,
      'name': name,
      'price': price,
      'tax_free': taxFree,
      'order_id': orderId,
      'use_order_id': useOrderId,
      'params': params,
      'account_expire_at': accountExpireAt,
      'show_agree_window': showAgreeWindow,
      'user_token': userToken
    };
    if(this.methods != null && this.methods!.length > 0) {
      if(kIsWeb) result['methods'] = this.methods;
      else result['methods'] = methodListString();
    } else if(this.method != null && this.method!.length > 0) {
      result['method'] = this.method;
    }
    if(extra != null) {
      result['extra'] = extra!.toJson();
    }
    if(user != null) {
      result['user_info'] = user!.toJson();
    }
    if(items!.length > 0) {
      result['items'] = items!.map((e) => e.toJson()).toList();
    }

    return result;
  }


  getApplicationId() {
    if(kIsWeb) return this.webApplicationId;
    if(Platform.isIOS) return this.iosApplicationId;
    else return this.androidApplicationId;
  }

  //toJson 대신에 이 함수가 사용됨
  String toString() {
    return "{application_id: '${getApplicationId()}', pg: '$pg', method: '$method', methods: ${methodListString()}, name: '$name', price: $price, tax_free: $taxFree, order_id: '$orderId', use_order_id: $useOrderId, params: ${getParamsStringAndroid()}, account_expire_at: '$accountExpireAt', show_agree_window: $showAgreeWindow, user_token: '$userToken', extra: ${extra.toString()}, user_info: ${user.toString()}, items: ${getItems()}}";
  }

  String methodListString() {
    List<String> result = [];
    if(this.method != null) {
      for(String method in this.methods!) {
        result.add("\'$method\'");
      }
    }


    return "[${result.join(",")}]";
  }

  String getItems() {
    List<String> result = [];

    if(this.items != null) {
      for(Item item in this.items!) {
        result.add(item.toString());
      }
    }

    return "[${result.join(",")}]";
  }

  String getParamsStringAndroid() {
    return reVal(json.encode(params));
    // return '{}';
  }

  String getParamsString() {
    if (params != null || params!.isEmpty) return "{}";
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
    if (methods != null || methods!.isEmpty) return '';
    String result = '';
    for (String method in methods!) {
      if (result.length > 0) result += ',';
      result += method;
    }
    return result;
  }
}
