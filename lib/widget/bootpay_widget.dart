import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/bootpay_webview.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';

import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';

import '../bootpay.dart';
import '../model/payload.dart';

typedef BootpayWidgetControllerCallback = void Function(BootpayWidgetController controller);

class BootpayWidget extends StatefulWidget {
  // Key? key;

  Payload? payload;
  BootpayWidgetControllerCallback? onWidgetCreated;
  BootpayWidgetController controller;
  //
  //
  // BootpayWidget({
  //   Key? key,
  //   this.widgetPayload,
  //   this.onWidgetCreated,
  //   this.controller
  // });

  BootpayWidget({
    Key? key,
    this.payload,
    this.onWidgetCreated,
    required this.controller
  });

  // const BootpayWidgetView();

  @override
  State<BootpayWidget> createState() => _BootpayWidgetState();
}

class _BootpayWidgetState extends State<BootpayWidget> {

  BootpayWebView _bootpayWebView = BootpayWebView();



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bootpayWebView = BootpayWebView(key: widget.key);
    _bootpayWebView.payload = widget.payload;
    _bootpayWebView.isWidget = true;

    widget.controller._bootpayWebView = _bootpayWebView;
    widget.controller._initEvent();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _bootpayWebView;
  }

  // late final WebViewController _controller;
  //
  // @override
  // void initState() {
  //   super.initState();
  //
  //   // #docregion platform_features
  //   late final PlatformWebViewControllerCreationParams params;
  //   if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
  //     params = WebKitWebViewControllerCreationParams(
  //       allowsInlineMediaPlayback: true,
  //       mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
  //     );
  //   } else {
  //     params = const PlatformWebViewControllerCreationParams();
  //   }
  //
  //   final WebViewController controller =
  //       WebViewController.fromPlatformCreationParams(params);
  //   // #enddocregion platform_features
  //
  //   _controller = controller;
  // }
  //
  // @override
  // Widget build(context) {
  //   return Scaffold(
  //     backgroundColor: Colors.green,
  //     body: WebViewWidget(controller: _controller),
  //   );
  // }
}

class BootpayWidgetController {

  BootpayWebView? _bootpayWebView;


  BootpayCloseCallback? onWidgetReady;
  WidgetResizeCallback? onWidgetResize;
  WidgetChangePaymentCallback? onWidgetChangePayment;
  WidgetChangePaymentCallback? onWidgetChangeAgreeTerm;

  double _widgetHeight = 0;

  void _initEvent() {
    _bootpayWebView?.onWidgetChangePayment = onWidgetChangePayment;
    _bootpayWebView?.onWidgetChangeAgreeTerm = onWidgetChangeAgreeTerm;
    _bootpayWebView?.onWidgetReady = onWidgetReady;
    _bootpayWebView?.onWidgetResize = (height) {
      if(_widgetHeight == height) return;
      _widgetHeight = height;
      if(onWidgetResize != null) onWidgetResize!(height);
    };
  }

  void update({Payload? payload, bool? refresh}) {
    _bootpayWebView?.widgetUpdate(payload, refresh ?? false);
  }

  // void requestPayment({
  //   Payload? payload,
  //   BootpayDefaultCallback? onError,
  //   BootpayDefaultCallback? onCancel,
  //   BootpayCloseCallback? onClose,
  //   BootpayDefaultCallback? onIssued,
  //   BootpayConfirmCallback? onConfirm,
  //   BootpayAsyncConfirmCallback? onConfirmAsync,
  //   BootpayDefaultCallback? onDone,
  // }) {
  //   _bootpayWebView?.requestPayment(
  //     payload: payload,
  //     onCancel: onCancel,
  //     onError: onError,
  //     onClose: onClose,
  //     onIssued: onIssued,
  //     onConfirm: onConfirm,
  //     onConfirmAsync: onConfirmAsync,
  //     onDone: onDone
  //   );
  // }
}