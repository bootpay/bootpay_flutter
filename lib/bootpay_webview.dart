import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bootpay/config/bootpay_config.dart';

import 'constant/bootpay_constant.dart';
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
  final BootpayDefaultCallback? onIssued;
  final BootpayConfirmCallback? onConfirm;
  final BootpayDefaultCallback? onDone;
  ShowHeaderCallback? onShowHeader;
  bool? showCloseButton = false;
  Widget? closeButton;
  String? userAgent;
  int? requestType = BootpayConstant.REQUEST_TYPE_PAYMENT; //1: 결제, 2:정기결제, 3: 본인인증

  final Completer<WebViewController> _controller = Completer<WebViewController>();

  BootpayWebView(
      {this.key,
        this.payload,
        this.showCloseButton,
        this.onCancel,
        this.onError,
        this.onClose,
        this.onIssued,
        this.onConfirm,
        this.onDone,
        this.closeButton,
        this.userAgent,
        this.requestType
      })
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _BootpayWebViewState();

  void transactionConfirm() {
    String script = "Bootpay.confirm()" +
        ".then( function (res) {" +
        confirm() +
        issued() +
        done() +
        "}, function (res) {" +
        error() +
        cancel() +
        "});";


    _controller.future.then((controller) {
      controller.evaluateJavascript(
          "setTimeout(function() { $script }, 30);"
      );
    });
  }

  void removePaymentWindow() {
    _controller.future.then((controller) {
      controller.evaluateJavascript(
          "Bootpay.removePaymentWindow();"
      );
      // controller.
    });
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
}

class _BootpayWebViewState extends State<BootpayWebView> {

  // final String INAPP_URL = 'https://inapp.bootpay.co.kr/3.3.3/production.html';
  final String INAPP_URL = 'https://webview.bootpay.co.kr/4.1.2/';

  bool isClosed = false;

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
        isClosed == false ? WebView(
          key: widget.key,
          initialUrl: INAPP_URL,
          javascriptMode: JavascriptMode.unrestricted,
          userAgent: widget.userAgent ?? null,
          onWebViewCreated: (WebViewController webViewController) {
            widget._controller.complete(webViewController);
          },
          javascriptChannels: <JavascriptChannel>[
            onCancel(context),
            onError(context),
            onClose(context),
            onIssued(context),
            onConfirm(context),
            onDone(context),
            onRedirect(context)
          ].toSet(),
          navigationDelegate: (NavigationRequest request) {


            if(widget.onShowHeader != null) {
              widget.onShowHeader!(request.url.contains("https://nid.naver.com") || request.url.contains("naversearchthirdlogin://"));
            }

            if(Platform.isAndroid)  return NavigationDecision.prevent;
            else return NavigationDecision.navigate;
          },

          onPageFinished: (String url) {

            if (url.startsWith(INAPP_URL)) {
              widget._controller.future.then((controller) async {
                for (String script in await getBootpayJSBeforeContentLoaded()) {
                  controller.evaluateJavascript(script);
                  BootpayPrint(script);
                }
                controller.evaluateJavascript(getBootpayJS());
                BootpayPrint(getBootpayJS());
                // controller.
              });
            }

            //네이버페이 일 경우 뒤로가기 버튼 제거 - 그러나 작동하지 않는다 (아마 팝업이라)
            // if(url.startsWith("https://nid.naver.com/nidlogin.login")) {
            //   widget._controller.future.then((controller) async {
            //     controller.evaluateJavascript('window.document.getElementById("back").remove();');
            //   });
            // }
          },
          gestureNavigationEnabled: true,
        ) : Container(),
        widget.showCloseButton == false ?
        Container() :
        widget.closeButton != null ?
        GestureDetector(
          child: widget.closeButton!,
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

extension BootpayMethod on _BootpayWebViewState {
  Future<List<String>> getBootpayJSBeforeContentLoaded() async {
    List<String> result = [];
    if (Platform.isAndroid) {
      result.add("Bootpay.setDevice('ANDROID');");
      result.add("Bootpay.setVersion('" + BootpayConfig.VERSION + "', 'android_flutter')");
    } else if (Platform.isIOS) {
      result.add("Bootpay.setDevice('IOS');");
      result.add("Bootpay.setVersion('" + BootpayConfig.VERSION + "', 'ios_flutter')");
    }
    if (BootpayConfig.DEBUG) {
      result.add("Bootpay.setEnvironmentMode('development');");
    }
    // result.add("Bootpay.setEnvironmentMode('development');");
    result.add( "setTimeout(function() {" + await getAnalyticsData() + "}, 50);");
    result.add(widget.close());

    // if (this.widget.payload?.extra?.quickPopup == 1 &&
    //     this.widget.payload?.extra?.popup == 1) {
    //   result.add("setTimeout(function() {BootPay.startQuickPopup();}, 30);");
    // }
    return result;
  }

  // String getJSPasswordPayment() {
  //   this.widget.payload?.method = "카드간편";
  //
  //   String script = "Bootpay.requestPayment(" +
  //       "${this.widget.payload.toString()}" +
  //       ")" +
  //       ".then( function (res) {" +
  //       widget.confirm() +
  //       widget.issued() +
  //       widget.done() +
  //       "}, function (res) {" +
  //       widget.error() +
  //       widget.cancel() +
  //       "})";
  //
  //   return "setTimeout(function() {" + script + "}, 50);";
  // }

  String getBootpayJS() {
    String requestMethod = 'requestPayment';
    if(widget.requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
      requestMethod = 'requestSubscription';
    } else if(widget.requestType == BootpayConstant.REQUEST_TYPE_AUTH) {
      requestMethod = 'requestAuthentication';
    } else if(widget.requestType == BootpayConstant.REQUEST_TYPE_PASSWORD) {
      this.widget.payload?.method = "카드간편";
    }

    String script = "Bootpay.${requestMethod}(" +
        "${this.widget.payload.toString()}" +
        ")" +
        ".then( function (res) {" +
        widget.confirm() +
        widget.issued() +
        widget.done() +
        "}, function (res) {" +
        widget.error() +
        widget.cancel() +
        "})";


    return "setTimeout(function() {" + script + "}, 50);";
  }



  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    return "Bootpay.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }

  void transactionConfirm() {
    widget.transactionConfirm();
  }

  void clickCloseButton() {

    if (this.widget.onCancel != null)
      this.widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
    if (this.widget.onClose != null)
      this.widget.onClose!();
  }

  void removePaymentWindow() {
    setState(() {
      this.isClosed = true;
    });

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

  JavascriptChannel onIssued(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayIssued',
        onMessageReceived: (JavascriptMessage message) {
          if (this.widget.onIssued != null)
            this.widget.onIssued!(message.message);
        });
  }

  JavascriptChannel onConfirm(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayConfirm',
        onMessageReceived: (JavascriptMessage message) async {
          if (this.widget.onConfirm != null) {
            bool goTransactionConfirm = this.widget.onConfirm!(message.message);
            if (goTransactionConfirm) {
              transactionConfirm();
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

  JavascriptChannel onRedirect(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayFlutterWebView', //이벤트 이름은 Android로 하자
        onMessageReceived: (JavascriptMessage message) {
          BootpayPrint("redirect: ${message.message}");

          final data = json.decode(message.message);
          switch(data["event"]) {
            case "cancel":
              if (this.widget.onCancel != null) this.widget.onCancel!(message.message);
              if (this.widget.onClose != null) this.widget.onClose!();
              break;
            case "error":
              if (this.widget.onError != null) this.widget.onError!(message.message);
              if(this.widget.payload?.extra?.displayErrorResult != true) {
                if (this.widget.onClose != null) this.widget.onClose!();
              }
              break;
            case "close":
              if (this.widget.onClose != null) this.widget.onClose!();
              break;
            case "issued":
              if (this.widget.onIssued != null) this.widget.onIssued!(message.message);
              if(this.widget.payload?.extra?.displaySuccessResult != true) {
                if (this.widget.onClose != null) this.widget.onClose!();
              }
              break;
            case "confirm":
              if (this.widget.onConfirm != null) {
                bool goTransactionConfirm = this.widget.onConfirm!(message.message);
                if (goTransactionConfirm) {
                  transactionConfirm();
                }
              }
              break;
            case "done":
              if (this.widget.onDone != null) this.widget.onDone!(message.message);
              if(this.widget.payload?.extra?.displaySuccessResult != true) {
                if (this.widget.onClose != null) this.widget.onClose!();
              }
              break;
          }
        });
  }
}
