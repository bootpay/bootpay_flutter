import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/config/bootpay_config.dart';
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


// 1. 웹앱을 대체하는 뷰를 활용한 샘플
// 2. api 역할
class BootpayWebView extends StatelessWidget {
  // Payload;
  // Event
  // controller
  final Key? key;
  final Payload? payload;
  final BootpayDefaultCallback? onCancel;
  final BootpayDefaultCallback? onError;
  final BootpayCloseCallback? onClose;
  final BootpayDefaultCallback? onIssued;
  final BootpayConfirmCallback? onConfirm;
  final BootpayAsyncConfirmCallback? onConfirmAsync;
  final BootpayDefaultCallback? onDone;
  BootpayProgressBarCallback? onProgressShow;
  // ShowHeaderCallback? onShowHeader;
  bool? showCloseButton = false;
  Widget? closeButton;
  String? userAgent;
  int? requestType = BootpayConstant.REQUEST_TYPE_PAYMENT; //1: 결제, 2:정기결제, 3: 본인인증

  final DebounceCloseController closeController = Get.put(DebounceCloseController());
  late final WebViewController _controller;
  // final Completer<WebViewController> _controller = Completer<WebViewController>();

  final String INAPP_URL = 'https://webview.bootpay.co.kr/5.0.0-beta.25/';


  BootpayWebView(
      {this.key,
        // this._controller,
        this.payload,
        this.showCloseButton,
        this.onCancel,
        this.onError,
        this.onClose,
        this.onIssued,
        this.onConfirm,
        this.onConfirmAsync,
        this.onDone,
        this.closeButton,
        this.userAgent,
        this.requestType
      })
      : super(key: key);


  void setLocale(String locale) {

    _controller.runJavaScript("Bootpay.setLocale('$locale')");
  }

  void transactionConfirm() {
    String script = "Bootpay.confirm().then(function(confirmRes) { BootpayDone.postMessage(JSON.stringify(confirmRes)); }, function(confirmRes) { if (confirmRes.event === 'error') { BootpayError.postMessage(JSON.stringify(confirmRes)); } else if (confirmRes.event === 'cancel') { BootpayCancel.postMessage(JSON.stringify(confirmRes)); } })";
    if(payload?.extra?.openType == 'redirect') {
      script = "Bootpay.confirm();";
    }

    _controller.runJavaScript(script);
  }

  void removePaymentWindow() {
    _controller.runJavaScript(
        "Bootpay.dismiss();"
    );
    // _controller.
    // _controller.
  }



  String confirm() {
    return "if (res.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(res)); } }";
  }


  String done() {
    return "else if (res.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(res)); } }";
  }


  String issued() {
    return "else if (res.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(res)); } }";
  }

  String error() {
    return "if (res.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(res)); } }";
  }

  String cancel() {
    return "else if (res.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(res)); } }";
  }

  String close() {
    return "document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });";
  }

  late PlatformWebViewControllerCreationParams params;
  void init() {
    if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = PlatformWebViewControllerCreationParams(
      );
    }

    final WebViewController controller = WebViewController.fromPlatformCreationParams(params);

    if(userAgent != null) {
      controller.setUserAgent(userAgent!);
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            // debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            // debugPrint('Page finished loading: $url');
            if (url.startsWith(INAPP_URL)) {

              for (String script in await getBootpayJSBeforeContentLoaded()) {
                // widget._controller.runJavaScript(javaScript)
                _controller.runJavaScript(script);

              }
              _controller.runJavaScript(getBootpayJS());
              debugPrint(getBootpayJS());
            }

          },
          // onNavi
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
                    ''');
            if(error.errorCode == 3) { // SSL 인증서 에러, update 유도
              if(error.description.contains("sslerror:")) {
                if (this.onError != null) {
                  this.onError!(error.description);
                }
                debounceClose();
              }
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if(request.url.contains("https://nid.naver.com")) {
              _controller.runJavaScript("document.getElementById('back').remove()");
            }
            return NavigationDecision.navigate;
          },
          // Navigation

        ),
      )
      ..addJavaScriptChannel(
        'BootpayCancel',
        onMessageReceived: onCancelJS,
      )
      ..addJavaScriptChannel(
        'BootpayError',
        onMessageReceived: onErrorJS,
      )
      ..addJavaScriptChannel(
        'BootpayClose',
        onMessageReceived: onCloseJS,
      )
      ..addJavaScriptChannel(
        'BootpayIssued',
        onMessageReceived: onIssuedJS,
      )
      ..addJavaScriptChannel(
        'BootpayConfirm',
        onMessageReceived: onConfirmJS,
      )
      ..addJavaScriptChannel(
        'BootpayDone',
        onMessageReceived: onDoneJS,
      )
      ..addJavaScriptChannel(
        'BootpayFlutterWebView',
        onMessageReceived: onRedirectJS,
      )
      ..loadRequest(Uri.parse(INAPP_URL));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Widget platformWebViewWidget() {
    if(_controller.platform is AndroidWebViewController && BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
          AndroidWebViewWidgetCreationParams(
            controller: _controller.platform,
          ),
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(
        controller: _controller
    );
  }

  @override
  Widget build(BuildContext context) {
    init();
    // TODO: implement build
    return Stack(
      children: [
        platformWebViewWidget(),
        if(showCloseButton ?? false)
          closeButton != null ?
          GestureDetector(
            child: closeButton!,
            onTap: () => clickCloseButton(),
          ) :
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Container()),
                  IconButton(
                    onPressed: () => clickCloseButton(),
                    icon: Icon(Icons.close, size: 35.0, color: Colors.black54),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }
}

extension BootpayMethod on BootpayWebView {
  Future<List<String>> getBootpayJSBeforeContentLoaded() async {
    List<String> result = [];

    if (BootpayConfig.IS_FORCE_WEB) {
      result.add("Bootpay.setVersion('" + BootpayConfig.VERSION + "', 'flutter')");
    } else if (Platform.isAndroid) {
      result.add("Bootpay.setDevice('ANDROID');");
      result.add("Bootpay.setVersion('" + BootpayConfig.VERSION + "', 'android_flutter')");
    } else if (Platform.isIOS) {
      result.add("Bootpay.setDevice('IOS');");
      result.add("Bootpay.setVersion('" + BootpayConfig.VERSION + "', 'ios_flutter')");
    }

    if (BootpayConfig.ENV == BootpayConfig.ENV_DEBUG) {
      result.add("Bootpay.setEnvironmentMode('development');");
    } else if (BootpayConfig.ENV == BootpayConfig.ENV_STAGE) {
      result.add("Bootpay.setEnvironmentMode('stage');");
    }
    String locale = payload?.extra?.locale ?? "";
    if(locale.length > 0) {
      result.add("Bootpay.setLocale('$locale');");
    }

    result.add(await getAnalyticsData());
    result.add(close());

    return result;
  }

  String getBootpayJS() {
    String requestMethod = 'requestPayment';
    if(this.requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
      requestMethod = 'requestSubscription';
    } else if(this.requestType == BootpayConstant.REQUEST_TYPE_AUTH) {
      requestMethod = 'requestAuthentication';
    } else if(this.requestType == BootpayConstant.REQUEST_TYPE_PASSWORD) {
      this.payload?.method = "카드간편";
    }

    String script = "Bootpay.${requestMethod}(" +
        "${this.payload.toString()}" +
        ")" +
        ".then( function (res) {" +
        confirm() +
        issued() +
        done() +
        "}, function (res) {" +
        error() +
        cancel() +
        "})";

    return script;
  }



  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    return "window.Bootpay.\$analytics.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }


  void clickCloseButton() {
    if (this.onCancel != null)
      this.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
  }

  void debounceClose() {
    closeController.bootpayClose(this.onClose);
  }

  void removePaymentWindow() {
    // setState(() {
    //   this.isClosed = true;
    // });

    removePaymentWindow();
  }
}

extension BootpayCallback on BootpayWebView {
  Future<void> goConfirmEvent(JavaScriptMessage message) async {

    print("goConfirmEvent : ${this.onConfirm}, ${this.onConfirmAsync}");

    if (this.onConfirm != null) {
      bool goTransactionConfirm = this.onConfirm!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    } else if(this.onConfirmAsync != null) {
      bool goTransactionConfirm = await this.onConfirmAsync!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    }
  }

  void onProgressShow(bool isShow) {
    if(this.payload?.extra?.openType != 'redirect' && isShow) {

    } else {
      if(this.onProgressShow != null) {
        this.onProgressShow!(isShow);
      }
    }
  }


  Future<void> onCancelJS(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.onCancel != null)
      this.onCancel!(message.message);
  }

  Future<void> onErrorJS(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.onError != null)
      this.onError!(message.message);
  }

  Future<void> onCloseJS(JavaScriptMessage message) async {
    debounceClose();
  }

  Future<void> onIssuedJS(JavaScriptMessage message) async {
    onProgressShow(false);
    if (this.onIssued != null)
      this.onIssued!(message.message);
  }


  Future<void> onConfirmJS(JavaScriptMessage message) async {
    onProgressShow(true);
    await goConfirmEvent(message);
  }


  Future<void> onDoneJS(JavaScriptMessage message) async {
    onProgressShow(false);
    if (this.onDone != null) this.onDone!(message.message);
  }

  Future<void> onRedirectJS(JavaScriptMessage message) async {
    final data = json.decode(message.message);

    switch(data["event"]) {
      case "cancel":
        onProgressShow(false);
        if (this.onCancel != null) this.onCancel!(message.message);
        debounceClose();
        break;
      case "error":
        onProgressShow(false);
        if (this.onError != null) this.onError!(message.message);
        if(this.payload?.extra?.displayErrorResult != true) {
          debounceClose();
        }
        break;
      case "close":
        onProgressShow(false);
        debounceClose();
        break;
      case "issued":
        onProgressShow(false);

        if (this.onIssued != null) this.onIssued!(message.message);
        if(this.payload?.extra?.displaySuccessResult != true) {
          debounceClose();
        }
        break;
      case "confirm":
        onProgressShow(true);
        await goConfirmEvent(message);
        break;
      case "done":
        onProgressShow(false);
        if (this.onDone != null) this.onDone!(message.message);
        if(this.payload?.extra?.displaySuccessResult != true) {
          debounceClose();
        } else {
          final content = json.decode(data["data"]);
          if(content["method_origin_symbol"] == "card_rebill_rest") {
            debounceClose();
          }
        }
        break;
    }
  }
}
