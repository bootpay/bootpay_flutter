
import 'dart:ui';

import 'package:bootpay_webview_flutter/webview_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bootpay.dart';
import '../bootpay_api.dart';
import '../bootpay_webview.dart';
import '../model/payload.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;

class WebViewRoute extends StatelessWidget {

  BootpayWebView? webView;


  WebViewRoute(this.webView);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(body: webView);
  }
}

class BootpayPlatform extends BootpayApi{

  BootpayWebView? webView;

  @override
  void request({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool isMaterialStyle = false,
    required bool showCloseButton,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    // webView = BootpayWebView(
    //   key: key,
    //   showCloseButton: showCloseButton,
    //   closeButton: closeButton,
    //   payload: payload,
    //   onCancel: onCancel,
    //   onError: onError,
    //   onClose: onClose,
    //   onReady: onReady,
    //   onConfirm: onConfirm,
    //   onDone: onDone,
    // );
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => WebViewRoute(webView)),
    // );

    if(isMaterialStyle) {
      _requestMaterialStyle(
        context: context,
        payload: payload,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onReady: onReady,
        onConfirm: onConfirm,
        onDone: onDone,
        showCloseButton: showCloseButton,
        closeButton: closeButton
      );
    } else {
      _requestCupertinoStyle(
          context: context,
          payload: payload,
          onCancel: onCancel,
          onError: onError,
          onClose: onClose,
          onReady: onReady,
          onConfirm: onConfirm,
          onDone: onDone,
          showCloseButton: showCloseButton,
          closeButton: closeButton
      );
    }
  }

  void _requestMaterialStyle({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool showCloseButton = false,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    webView = BootpayWebView(
      key: key,
      showCloseButton: showCloseButton,
      closeButton: closeButton,
      payload: payload,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      onReady: onReady,
      onConfirm: onConfirm,
      onDone: onDone,
      
    );

    BottomSheet.showMaterialModalBottomSheet(
      expand: true,
      enableDrag: false,
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        child: Scaffold(
          body: SafeArea(
            child: webView!,
          )
        ),
      ),
    );
  }

  void _requestCupertinoStyle({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool showCloseButton = false,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    webView = BootpayWebView(
      key: key,
      showCloseButton: showCloseButton,
      closeButton: closeButton,
      payload: payload,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      onReady: onReady,
      onConfirm: onConfirm,
      onDone: onDone,
    );

    BottomSheet.showCupertinoModalBottomSheet(
      expand: true,
      enableDrag: false,
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Scaffold(
            body: SafeArea(
              child: webView!,
            )
        ),
      ),
    );
  }

  @override
  void removePaymentWindow() {
    if(webView != null) webView!.removePaymentWindow();
  }

  @override
  void transactionConfirm(String data) {
    if(webView != null) webView!.transactionConfirm(data);
  }
}