
import 'package:bootpay/config/bootpay_config.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';

import 'bootpay.dart';


// second full screen webview
class BootpayHeroWebView extends StatefulWidget {
  // BootpayWebView webView;

  // final GlobalKey<BootpayWebViewState> _globalKey = GlobalKey<BootpayWebViewState>();

  GlobalKey webViewKey;
  WebViewController controller;
  // BootpayCloseCallback? onCloseWidget;

  BootpayHeroWebView({
    Key? key,
    required this.webViewKey,
    // this.onCloseWidget,
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
        // key: widget.webViewKey,
        controller: widget.controller
    );
  }

}

