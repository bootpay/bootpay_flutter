import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/bootpay_webview.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/widget/widget_data.dart';
import 'package:get/get.dart';

import 'constant/bootpay_constant.dart';
import 'controller/debounce_close_controller.dart';
import 'user_info.dart';
import 'package:flutter/material.dart';

import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';

import 'bootpay.dart';
import 'model/payload.dart';


// second full screen webview
class BootpayHeroWebView extends StatefulWidget {
  // BootpayWebView webView;
  WebViewController controller;
  BootpayCloseCallback? onCloseWidget;

  BootpayHeroWebView({
    Key? key,
    this.onCloseWidget,
    required this.controller
  }) : super(key: key);

  @override
  State<BootpayHeroWebView> createState() => BootpayHeroWebViewState();
}


class BootpayHeroWebViewState extends State<BootpayHeroWebView> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // widget.controller.web


    return buildFullScreen();
  }

  Widget buildFullScreen() {
    return  Scaffold(
      body: SafeArea(
        child: Hero(
          tag: "bootpayWidgetWebView",
          transitionOnUserGestures: true,
          child: platformWebViewWidget()
        ),
      ),
    );
  }

  Widget platformWebViewWidget() {
    if(widget.controller.platform is AndroidWebViewController && BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
          AndroidWebViewWidgetCreationParams(
            controller: widget.controller.platform,
          ),
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(
        controller: widget.controller
    );
  }
}

