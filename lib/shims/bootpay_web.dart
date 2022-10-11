
@JS()
library bootpay_api;

import 'dart:async';
import 'dart:convert';

import 'package:bootpay/api/bootpay_analytics.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:http/src/response.dart';
import 'package:js/js.dart';
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
external void _removePaymentWindow();
@JS()
external void _transactionConfirm();
@JS()
external void _addCloseEvent();

@JS()
external void BootpayClose();
@JS('BootpayClose')
external set _BootpayClose(void Function() f);
@JS()
external void BootpayCancel(String data);
@JS('BootpayCancel')
external set _BootpayCancel(void Function(String) f);
@JS()
external void BootpayDone(String data);
@JS('BootpayDone')
external set _BootpayDone(void Function(String) f);
@JS()
external void BootpayIssued(String data);
@JS('BootpayIssued')
external set _BootpayIssued(void Function(String) f);
@JS()
external void Function(void Function(bool data)) BootpayConfirm(String data);
@JS('BootpayConfirm')
external set _BootpayConfirm(void Function(void Function(bool data)) Function(String) f);
@JS()
external void BootpayError(String data);
@JS('BootpayError')
external set _BootpayError(void Function(String) f);

class BootpayPlatform extends BootpayApi{
  BootpayDefaultCallback? _callbackCancel;
  BootpayDefaultCallback? _callbackError;
  BootpayCloseCallback? _callbackClose;
  BootpayDefaultCallback? _callbackIssued;
  BootpayConfirmCallback? _callbackConfirm;
  BootpayAsyncConfirmCallback? _callbackConfirmAsync;
  BootpayDefaultCallback? _callbackDone;

  BootpayPlatform() {
    _BootpayClose = allowInterop(onClose);
    _BootpayCancel = allowInterop(onCancel);
    _BootpayDone = allowInterop(onDone);
    _BootpayIssued = allowInterop(onIssued);
    _BootpayConfirm = allowInterop(onConfirm);
    _BootpayError = allowInterop(onError);
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
        int? requestType
      }) {

    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackDone = onDone;
    this._callbackConfirmAsync = onConfirmAsync;

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
        int? requestType
      }) {


    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackConfirmAsync = onConfirmAsync;
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
        int? requestType
      }) {


    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackConfirmAsync = onConfirmAsync;
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
        int? requestType
      }) {

    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackIssued = onIssued;
    this._callbackConfirm = onConfirm;
    this._callbackConfirmAsync = onConfirmAsync;
    this._callbackDone = onDone;


    if(payload != null) {
      payload.method = "카드간편";

      _jsBeforeLoad();
      _requestPayment(jsonEncode(payload.toJson()));
    }
  }

  @override
  void removePaymentWindow() {
    // _removePaymentWindow();
  }

  @override
  void transactionConfirm() {
    _transactionConfirm();
  }

  void dismiss(BuildContext context) {
    // _removePaymentWindow();
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
  void Function(void Function(bool d))  onConfirm(String data) {
    if(this._callbackConfirm != null) {
      void a(void Function(bool d) callback) {
        callback(this._callbackConfirm!(data));
      }
      return a;
    } else if(this._callbackConfirmAsync != null) {
      Future<void> a(void Function(bool d) callback) async {
        final rnt = await this._callbackConfirmAsync!(data);
        callback(rnt);
      }
      return a;
    } else {
      void a(void Function(bool d) callback) {
        callback(false);
      }
      return a;
    }
  }
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

}