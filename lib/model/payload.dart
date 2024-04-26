import 'dart:io';
import 'dart:convert';

import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/widget/oopay.dart';
import 'package:bootpay/model/widget/widget_data.dart';

import 'extra.dart';
import 'item.dart';
import 'user.dart';
import '../extension/json_query_string.dart';
import 'package:flutter/foundation.dart';

class Payload {
  String? webApplicationId = '';
  String? androidApplicationId = '';
  String? iosApplicationId = '';

  String? pg = '';
  String? method = '';
  List<String>? methods = [];
  String? orderName = '';

  double? price = 0;
  double? taxFree = 0;
  double? depositPrice = 0; //보증급 [컵]
  String? currency; //KRW, USD

  String? orderId = '';
  String? subscriptionId = '';
  String? authenticationId = '';
  // int? useOrderId = 0;

  Map<String, dynamic>? metadata = {};

  // String? accountExpireAt = '';
  // bool showAgreeWindow = false;
  String? userToken = '';

  Extra? extra = Extra();
  User? user = User();
  List<Item>? items = [];

  //widget data request 관련
  String? widgetKey; //default-widget
  bool? widgetUseTerms;
  bool? widgetSandbox;
  Oopay? widgetOopay = Oopay();

  //widget data response 관련
  String? _widgetWalletId;
  WidgetData? _widgetData;
  List<WidgetTerm>? _widgetSelectTerms;
  bool? _widgetTermPassed;
  bool? _widgetCompleted;

  bool get widgetIsCompleted => (_widgetTermPassed ?? false) && (_widgetCompleted ?? false);

  // Payload();
  Payload({
    this.webApplicationId,
    this.androidApplicationId,
    this.iosApplicationId,
    this.pg,
    this.method,
    this.methods,
    this.orderName,
    this.currency,
    this.price,
    this.taxFree,
    this.depositPrice,
    this.orderId,
    this.subscriptionId,
    this.authenticationId,
    this.metadata,
    this.userToken,
    this.extra,
    this.user,
    this.items,
    this.widgetKey,
    this.widgetUseTerms,
    this.widgetSandbox,
    this.widgetOopay,
  }) {
    if(this.extra == null) {
      this.extra = Extra();
    }
  }

  Payload.fromJson(Map<String, dynamic> json) {
    androidApplicationId = json["android_application_id"];
    iosApplicationId = json["ios_application_id"];

    pg = json["pg"];
    method = json["method"];
    methods = json["methods"];
    orderName = json["name"];

    price = json["price"];
    taxFree = json["tax_free"];
    depositPrice = json["deposit_price"];

    orderId = json["order_id"];
    subscriptionId = json["subscription_id"];
    authenticationId = json["authentication_id"];

    userToken = json["userToken"];

    // useOrderId = json["use_order_id"];

    metadata = json["metadata"];
    currency = json["currency"];


    // accountExpireAt = json["account_expire_at"];
    // showAgreeWindow = json["show_agree_window"];
    extra = Extra.fromJson(json["extra"]);

    widgetKey = json["widget_key"];
    widgetUseTerms = json["use_terms"];
    widgetSandbox = json["sandbox"];
    widgetOopay = Oopay.fromJson(json["oopay"]);
    _widgetWalletId = json["wallet_id"];
    _widgetData = json["widget_data"] != null ? WidgetData.fromJson(json["widget_data"]) : null;
    _widgetSelectTerms = [];
    if (json["select_terms"] != null) {
      json["select_terms"].forEach((v) {
        _widgetSelectTerms?.add(WidgetTerm.fromJson(v));
      });
    }
    _widgetTermPassed = json["term_passed"];
    _widgetCompleted = json["completed"];
  }


  //web에서 사용됨
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'application_id': getApplicationId(),
      'pg': pg,
      'order_name': orderName,
      'price': price,
      'currency': currency,
      'tax_free': taxFree,
      'deposit_price': depositPrice,
      'order_id': orderId,
      'subscription_id': subscriptionId,
      'authentication_id': authenticationId,
      // 'use_order_id': useOrderId,
      'metadata': metadata,
      // 'account_expire_at': accountExpireAt,
      // 'show_agree_window': showAgreeWindow,
      'user_token': userToken,
      'widget_key': widgetKey,
      'sandbox': widgetSandbox,
      'use_terms': widgetUseTerms,
    };
    if(this.methods != null && this.methods!.length > 0) {
      if(kIsWeb) result['method'] = this.methods;
      else result['method'] = getMethodValue();
    } else if(this.method != null && this.method!.length > 0) {
      result['method'] = this.method;
    }
    if(extra != null) {
      result['extra'] = extra!.toJson();
    }
    if(user != null) {
      result['user'] = user!.toJson();
    }
    if(items!.length > 0) {
      result['items'] = items!.map((e) => e.toJson()).toList();
    }
    if(widgetOopay != null) {
      result['oopay'] = widgetOopay!.toJson();
    }
    if(_widgetSelectTerms != null && _widgetSelectTerms!.length > 0) {
      result['select_terms'] = getSelectTermsValue();
    }

    return result;
  }


  getApplicationId() {
    if(kIsWeb || BootpayConfig.IS_FORCE_WEB) return this.webApplicationId;
    else if(Platform.isIOS) return this.iosApplicationId;
    else return this.androidApplicationId;
  }

  //android, ios에서 사용됨
  // String toString() {
  //   return "{application_id: '${getApplicationId()}', pg: '$pg', method: ${getMethodValue()}, order_name: '${orderName.queryReplace()}', price: $price, tax_free: $taxFree,order_id: '${orderId.queryReplace()}', subscription_id: '${subscriptionId.queryReplace()}', authentication_id: '${authenticationId.queryReplace()}', metadata: ${getMetadataStringAndroid()},user_token: '$userToken', extra: ${extra.toString()}, user: ${user.toString()}, items: ${getItems()}}";
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

    addPart('application_id', getApplicationId());
    addPart('pg', pg);
    addPart('method', getMethodValue(), isOriginal: true);
    addPart('order_name', orderName);
    addPart('price', price);
    addPart('tax_free', taxFree);
    addPart('deposit_price', depositPrice);

    addPart('order_id', orderId);
    addPart('subscription_id', subscriptionId);
    addPart('authentication_id', authenticationId);
    addPart('metadata', getMetadataStringAndroid(), isOriginal: true);

    addPart('user_token', userToken);
    addPart('extra', extra.toString(), isOriginal: true);
    addPart('user', user.toString(), isOriginal: true);
    addPart('items', getItems(), isOriginal: true);

    addPart('use_terms', widgetUseTerms);
    addPart('sandbox', widgetSandbox);
    // addPart('widget_sandbox', widgetSandbox);
    addPart('widget_key', widgetKey);
    if(widgetKey != null) addPart("widget", 1);
    addPart('oopay', widgetOopay?.toJson(), isOriginal: true);
    addPart('currency', currency);
    addPart('wallet_id', _widgetWalletId);
    addPart('terms', getSelectTermsValue(), isOriginal: true);
    // addPart('select_terms', getSelectTermsValue(), isOriginal: true);

    return "{${parts.join(", ")}}";
  }


  String getMethodValue() {
    if(this.methods == null || this.methods!.isEmpty) {
      return "'${this.method ?? ''}'";
    } else {
      List<String> result = [];
      for(String method in this.methods!) {
        result.add("\'$method\'");
      }
      return "[${result.join(",")}]";
    }
  }

  String getSelectTermsValue() {
    List<String> result = [];
    if(this._widgetSelectTerms != null) {
      for(WidgetTerm term in this._widgetSelectTerms!) {
        result.add(term.toString());
      }
    }

    return "[${result.join(",")}]";
  }

  // String methodListString() {
  //   List<String> result = [];
  //   if(this.methods != null) {
  //     for(String method in this.methods!) {
  //       result.add("\'$method\'");
  //     }
  //   }
  //
  //   return "[${result.join(",")}]";
  // }

  String getItems() {
    List<String> result = [];

    if(this.items != null) {
      for(Item item in this.items!) {
        result.add(item.toString());
      }
    }

    return "[${result.join(",")}]";
  }

  String getMetadataStringAndroid() {
    return reVal(json.encode(metadata));
    // return '{}';
  }

  String getMetadataString() {
    if (metadata != null || metadata!.isEmpty) return "{}";
    return reVal(metadata.toString());
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

  void mergeWidgetData(WidgetData? data) {
    if(data == null) return;
    this._widgetData = data;
    if(data.pg != null) this.pg = data.pg;
    if(data.method != null) this.method = data.method;


    this._widgetCompleted = data.completed;
    this._widgetTermPassed = data.termPassed;
    if(data.currency != null) this.currency = data.currency;
    if(data.selectTerms != null) this._widgetSelectTerms = data.selectTerms;
    if(data.walletId != null) this._widgetWalletId = data.walletId;

    if(this.extra == null) {
      this.extra = Extra();
    }
    if(data?.extra?.directCardCompany != null) this.extra?.directCardCompany = data?.extra?.directCardCompany;
    if(data?.extra?.directCardQuota != null) this.extra?.directCardQuota = "${data?.extra?.directCardQuota}";
    if(data?.extra?.cardQuota != null) this.extra?.cardQuota = "${data?.extra?.cardQuota}";
  }
}
