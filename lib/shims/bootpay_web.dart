
@JS()
library bootpay_api;

import 'dart:convert';

import 'package:js/js.dart';
import 'package:flutter/material.dart';
import '../bootpay.dart';
import '../bootpay_api.dart';
import '../model/payload.dart';

@JS()
external String _request(String payload);
@JS()
external void _removePaymentWindow();
@JS()
external void _transactionConfirm(String data);

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
external void BootpayReady(String data);
@JS('BootpayReady')
external set _BootpayReady(void Function(String) f);
@JS()
external bool BootpayConfirm(String data);
@JS('BootpayConfirm')
external set _BootpayConfirm(bool Function(String) f);
@JS()
external void BootpayError(String data);
@JS('BootpayError')
external set _BootpayError(void Function(String) f);

class BootpayPlatform extends BootpayApi{
  BootpayDefaultCallback? _callbackCancel;
  BootpayDefaultCallback? _callbackError;
  BootpayCloseCallback? _callbackClose;
  BootpayCloseCallback? _callbackCloseHardware;
  BootpayDefaultCallback? _callbackReady;
  BootpayConfirmCallback? _callbackConfirm;
  BootpayDefaultCallback? _callbackDone;

  BootpayPlatform() {
    _BootpayClose = allowInterop(onClose);
    _BootpayCancel = allowInterop(onCancel);
    _BootpayDone = allowInterop(onDone);
    _BootpayReady = allowInterop(onReady);
    _BootpayConfirm = allowInterop(onConfirm);
    _BootpayError = allowInterop(onError);
  }

  @override
  void request({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool? showCloseButton,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayCloseCallback? onCloseHardware,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    this._callbackCancel = onCancel;
    this._callbackError = onError;
    this._callbackClose = onClose;
    this._callbackCloseHardware = onCloseHardware;
    this._callbackReady = onReady;
    this._callbackConfirm = onConfirm;
    this._callbackDone = onDone;

    _request(jsonEncode(payload.toJson()));
  }

  @override
  void removePaymentWindow() {
    _removePaymentWindow();
  }

  @override
  void transactionConfirm(String data) {
    _transactionConfirm(data);
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
  void onReady(String data) {
    if(this._callbackReady != null) this._callbackReady!(data);
  }
  bool onConfirm(String data) {
    if(this._callbackConfirm != null) return this._callbackConfirm!(data);
    return false;
  }
  void onDone(String data) {
    if(this._callbackDone != null) this._callbackDone!(data);
  }
  void onError(String data) {
    if(this._callbackError != null) this._callbackError!(data);
  }
}