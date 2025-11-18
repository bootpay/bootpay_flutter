
@JS()
library bootpay_api;

import 'dart:convert';
import 'dart:js_interop';

import 'package:bootpay/api/bootpay_analytics.dart';
import 'package:bootpay/bootpay_widget_api.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:http/src/response.dart';
import 'package:flutter/material.dart';
import '../bootpay.dart';
import '../bootpay_api.dart';
import '../model/payload.dart';

@JS()
external void _jsBeforeLoad();
@JS()
external void _requestPayment(String payload);
@JS()
external void _requestSubscription(String payload);
@JS()
external void _requestAuthentication(String payload);
@JS()
external void _setLocale(String locale);
@JS()
external void _removePaymentWindow();

@JS()
external void _transactionConfirm();
@JS()
external void _addCloseEvent();

@JS('BootpayClose')
external set _BootpayClose(JSFunction f);

@JS('BootpayCancel')
external set _BootpayCancel(JSFunction f);

@JS('BootpayDone')
external set _BootpayDone(JSFunction f);

@JS('BootpayIssued')
external set _BootpayIssued(JSFunction f);

@JS('BootpayConfirm')
external set _BootpayConfirm(JSFunction f);

@JS('BootpayAsyncConfirm')
external set _BootpayAsyncConfirm(JSFunction f);

@JS('BootpayError')
external set _BootpayError(JSFunction f);

class BootpayPlatform extends BootpayApi with BootpayWidgetApi {
  BootpayDefaultCallback? _callbackCancel;
  BootpayDefaultCallback? _callbackError;
  BootpayCloseCallback? _callbackClose;
  BootpayDefaultCallback? _callbackIssued;
  BootpayConfirmCallback? _callbackConfirm;
  BootpayAsyncConfirmCallback? _callbackAsyncConfirm;
  BootpayDefaultCallback? _callbackDone;

  BootpayPlatform() {
    _BootpayClose = onClose.toJS;
    _BootpayCancel = onCancel.toJS;
    _BootpayDone = onDone.toJS;
    _BootpayIssued = onIssued.toJS;
    _BootpayConfirm = onConfirm.toJS;
    _BootpayAsyncConfirm = onConfirmAsync.toJS; //js에서 BootpayAsyncConfirm 호출시 onConfirmAsync 수행
    _BootpayError = onError.toJS;
  }


  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return webApplicationId;
  }

  @override
  void requestPayment(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent, //사용되진 않음
        int? requestType
      }) {

    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackAsyncConfirm = onConfirmAsync;
    this._callbackDone = onDone;

    if(payload != null) {
      _jsBeforeLoad();
      _requestPayment(jsonEncode(payload.toJson()));
    }
  }

  @override
  void requestSubscription(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent, //사용되진 않음
        int? requestType
      }) {


    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackAsyncConfirm = onConfirmAsync;
    this._callbackDone = onDone;


    if(payload != null) {
      if(payload.subscriptionId == null || payload.subscriptionId?.length == 0) {
        payload.subscriptionId = payload.orderId ?? "";
      }
      _jsBeforeLoad();
      _requestSubscription(jsonEncode(payload.toJson()));
    }
  }

  @override
  void requestAuthentication(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent, //사용되진 않음
        int? requestType
      }) {


    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackAsyncConfirm = onConfirmAsync;
    this._callbackDone = onDone;


    if(payload != null) {
      if(payload.subscriptionId == null || payload.subscriptionId?.length == 0) {
        payload.subscriptionId = payload.orderId ?? "";
      }
      _jsBeforeLoad();
      _requestAuthentication(jsonEncode(payload.toJson()));
    }
  }

  @override
  void requestPassword(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent, //사용되진 않음
        int? requestType
      }) {

    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackAsyncConfirm = onConfirmAsync;
    this._callbackDone = onDone;


    if(payload != null) {
      payload.method = "카드간편";

      _jsBeforeLoad();
      _requestPayment(jsonEncode(payload.toJson()));
    }
  }


  @override
  void transactionConfirm() {
    _transactionConfirm();
  }

  void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onClose() {
    if(this._callbackClose != null) this._callbackClose!();
  }
  void onCancel(String data) {
    if(this._callbackCancel != null) this._callbackCancel!(data);
  }
  void onIssued(String data) {
    if(this._callbackIssued != null) this._callbackIssued!(data);
  }
  bool onConfirm(String data) {
    if(this._callbackConfirm != null) return this._callbackConfirm!(data);
    return false;
  }

  JSPromise onConfirmAsync(String data)  {
    return JSPromise(((JSFunction resolve, JSFunction reject) {
      if(this._callbackAsyncConfirm != null) {
        this._callbackAsyncConfirm!(data).then((bool result) {
          resolve.callAsFunction(null, result.toJS);
        }).catchError((error) {
          reject.callAsFunction(null, error.toString().toJS);
        });
      } else {
        resolve.callAsFunction(null, false.toJS);
      }
    }).toJS);
  }

  // Future<bool> onConfirmAsync(String data) async {
  //   if(this._callbackAsyncConfirm != null) {
  //   //   // Future<bool> promise = this._callbackAsyncConfirm!(data);
  //   //   // // if(promise != null) Future.r;
  //   //   //
  //   //   // print("22onConfirmAsync : $data, $promise");
  //   //   //
  //   //   // return await promiseToFuture(promise);
  //
  //     // Future<bool> promise = this._callbackAsyncConfirm!(data);
  //     // return promiseToFuture(promise);
  //
  //     // return this._callbackAsyncConfirm!(data);
  //
  //     return Future.value(true);
  //
  //   } else {
  //     return Future.value(false);
  //   }
  // }

  void onDone(String data) {
    if(this._callbackDone != null) this._callbackDone!(data);
  }
  void onError(String data) {
    if(this._callbackError != null) this._callbackError!(data);
  }

  @override
  Future<Response> pageTrace({String? url, String? pageType, String? applicationId, String? userId, List<StatItem>? items, String? ver}) {
    // TODO: implement pageTrace
    return BootpayAnalytics.pageTrace(
        url: url,
        pageType: pageType,
        userId: userId,
        items: items,
        applicationId: applicationId,
        ver: ver
    );
  }

  @override
  Future<Response> userTrace({String? id, String? email, int? gender, String? birth, String? phone, String? area, String? applicationId, String? ver}) {
    // TODO: implement userTrace
    return BootpayAnalytics.userTrace(
        id: id,
        email: email,
        gender: gender,
        birth: birth,
        phone: phone,
        area: area,
        applicationId: applicationId,
        ver: ver
    );
  }

  @override
  void setLocale(String locale) {
    // TODO: implement setLocale
    _setLocale(locale);
  }

  @override
  void removePaymentWindow() {
    _removePaymentWindow();
  }

  @override
  void render({Key? key, BuildContext? context, Payload? payload}) {
    // TODO: implement render
  }

  @override
  void update({Key? key, BuildContext? context, Payload? payload}) {
    // TODO: implement update
  }

}