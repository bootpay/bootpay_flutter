import 'dart:async';
import 'dart:io';

import 'user_info.dart';
import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/webview_flutter.dart';

import 'bootpay.dart';
import 'model/payload.dart';


// 1. 웹앱을 대체하는 뷰를 활용한 샘플
// 2. api 역할
class BootpayWebView extends WebView {
  // Payload;
  // Event
  // controller
  final Key? key;
  final Payload? payload;
  final BootpayDefaultCallback? onCancel;
  final BootpayDefaultCallback? onError;
  final BootpayCloseCallback? onClose;
  final BootpayCloseCallback? onCloseHardware;
  final BootpayDefaultCallback? onReady;
  final BootpayConfirmCallback? onConfirm;
  final BootpayDefaultCallback? onDone;
  bool showCloseButton = false;
  Widget? closeButton;

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  BootpayWebView(
      {this.key,
      this.payload,
      required this.showCloseButton,
      this.onCancel,
      this.onError,
      this.onClose,
      this.onCloseHardware,
      this.onReady,
      this.onConfirm,
      this.onDone,
      this.closeButton
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BootpayWebViewState();

  void transactionConfirm(String data) {
    _controller.future.then((controller) {
      controller.evaluateJavascript(
          "var data = JSON.parse('$data'); BootPay.transactionConfirm(data);");
    });
  }

  void removePaymentWindow() {
    _controller.future.then((controller) {
      controller.evaluateJavascript("BootPay.removePaymentWindow();");
    });
  }
}

class _BootpayWebViewState extends State<BootpayWebView> {

  final String INAPP_URL = 'https://inapp.bootpay.co.kr/3.3.3/production.html';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        WebView(
          key: widget.key,
          initialUrl: INAPP_URL,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            widget._controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[
            onCancel(context),
            onError(context),
            onClose(context),
            onReady(context),
            onConfirm(context),
            onDone(context)
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {
            // if (request.url.startsWith('https://www.youtube.com/')) {
            //   return NavigationDecision.prevent;
            // }
            return NavigationDecision.navigate;
          },
          onPageFinished: (String url) {
            print(url);

            if (url.startsWith(INAPP_URL)) {
              widget._controller.future.then((controller) async {
                for (String script in await getBootpayJSBeforeContentLoaded()) {
                  controller.evaluateJavascript(script);
                }
                controller.evaluateJavascript(getBootpayJS());
              });
            }
          },
          gestureNavigationEnabled: true,
        ),
        widget.showCloseButton == false ?
        Container() :
        widget.closeButton != null ?
        GestureDetector(
          child: widget.closeButton!,
          onTap: () => removePaymentWindow(),
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
                    onPressed: () => removePaymentWindow(),
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

extension BootpayMethod on _BootpayWebViewState {
  Future<List<String>> getBootpayJSBeforeContentLoaded() async {
    List<String> result = [];
    if (Platform.isAndroid) {
      result.add("BootPay.setDevice('ANDROID');");
    } else if (Platform.isIOS) {
      result.add("BootPay.setDevice('IOS');");
    }
    result.add(await getAnalyticsData());
    if (this.widget.payload?.extra?.quick_popup == 1 &&
        this.widget.payload?.extra?.popup == 1) {
      result.add("BootPay.startQuickPopup();");
    }
    return result;
  }

  String getBootpayJS() {
    return "BootPay.request(${this.widget.payload.toString()})" +
        error() +
        cancel() +
        ready() +
        confirm() +
        close() +
        done();
  }

  String error() {
    return ".error(function (data) { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(data)); } })";
  }

  String cancel() {
    return ".cancel(function (data) { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(data)); } })";
  }

  String ready() {
    return ".ready(function (data) { if (window.BootpayReady && window.BootpayReady.postMessage) { BootpayReady.postMessage(JSON.stringify(data)); } })";
  }

  String confirm() {
    return ".confirm(function (data) { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(data)); } })";
  }

  String close() {
    return ".close(function (data) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage(JSON.stringify(data)); } })";
  }

  String done() {
    return ".done(function (data) { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(data)); } })";
  }

  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    return "BootPay.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }

  void transactionConfirm(String data) {
    widget.transactionConfirm(data);
  }

  void removePaymentWindow() {
    widget.removePaymentWindow();
  }
}

extension BootpayCallback on _BootpayWebViewState {
  JavascriptChannel onCancel(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayCancel',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onCancel != null)
            this.widget.onCancel!(message.message);
        });
  }

  JavascriptChannel onError(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayError',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onError != null)
            this.widget.onError!(message.message);
        });
  }

  JavascriptChannel onClose(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayClose',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onClose != null) this.widget.onClose!();
          // Navigator.of(context).pop();
        });
  }

  JavascriptChannel onReady(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayReady',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onReady != null)
            this.widget.onReady!(message.message);
        });
  }

  JavascriptChannel onConfirm(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayConfirm',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onConfirm != null) {
            bool goTransactionConfirm = this.widget.onConfirm!(message.message);
            if (goTransactionConfirm) {
              transactionConfirm(message.message);
            }
          }
        });
  }

  JavascriptChannel onDone(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayDone',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onDone != null) this.widget.onDone!(message.message);
        });
  }
}
