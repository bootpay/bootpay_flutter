
import 'dart:async';

import 'package:bootpay/config/bootpay_config.dart';
import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';


class WebAppPayment extends StatefulWidget {
  const WebAppPayment();

  @override
  State<WebAppPayment> createState() => _WebAppPaymentState();
}

class _WebAppPaymentState extends State<WebAppPayment> {
  late final WebViewController _controller;


  @override
  void initState() {
    super.initState();

    /// #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },

          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },

        ),
      )
      // ..setOnJavaScriptAlertDialog((JavaScriptAlertDialogRequest request) async {
      //   await _showAlert(context, request.message);
      // })
      // ..setOnJavaScriptConfirmDialog(
      //         (JavaScriptConfirmDialogRequest request) async {
      //       final bool result = await _showConfirm(context, request.message);
      //       return result;
      //     })
      // ..setOnJavaScriptTextInputDialog(
      //         (JavaScriptTextInputDialogRequest request) async {
      //       final String result =
      //       await _showTextInput(context, request.message, request.defaultText);
      //       return result;
      //     })
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('https://dev-js.bootapi.com/test/payment/widget.html'));

    _controller = controller;
  }


  Future<void> _showAlert(BuildContext context, String message) async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text(message),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  Future<bool> _showConfirm(BuildContext context, String message) async {
    return await showDialog<bool>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text(message),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text('OK')),
            ],
          );
        }) ??
        false;
  }

  Future<String> _showTextInput(
      BuildContext context, String message, String? defaultText) async {
    return await showDialog<String>(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            content: Text(message),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop('Text test');
                  },
                  child: const Text('Enter')),
            ],
          );
        }) ??
        '';
  }

  @override
  Widget build(context) {
    // return Scaffold(
    //   backgroundColor: Colors.green,
    //   body: SafeArea(
    //       child: platformWebViewWidget()
    //   ),
    // );
    return Scaffold(
      backgroundColor: const Color(0xFF4CAF50),
      appBar: AppBar(
        title: const Text('Flutter WebView example'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        // actions: <Widget>[
        //   NavigationControls(webViewController: _controller),
        //   SampleMenu(
        //     webViewController: _controller,
        //     cookieManager: widget.cookieManager,
        //   ),
        // ],
      ),
      body: WebViewWidget(controller: _controller),
      // floatingActionButton: favoriteButton(),
    );
  }

  // Widget platformWebViewWidget() {
  //   if(_controller.platform is AndroidWebViewController && BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION) {
  //     return WebViewWidget.fromPlatformCreationParams(
  //       params: AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
  //         AndroidWebViewWidgetCreationParams(
  //           controller: _controller.platform,
  //         ),
  //         displayWithHybridComposition: true,
  //       ),
  //     );
  //   }
  //   return WebViewWidget(controller: _controller).build(context);
  // }
}
