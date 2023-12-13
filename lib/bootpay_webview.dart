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
class BootpayWebView extends StatefulWidget {
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

  @override
  State<StatefulWidget> createState() => _BootpayWebViewState();

  void setLocale(String locale) {

    _controller.runJavaScript("Bootpay.setLocale('$locale')");
  }

  void transactionConfirm() {
    // String script = "Bootpay.confirm()" +
    //     ".then( function (res) {" +
    //     confirm() +
    //     issued() +
    //     done() +
    //     "}, function (res) {" +
    //     error() +
    //     cancel() +
    //     "});";

    String script = "Bootpay.confirm().then(function(confirmRes) { BootpayDone.postMessage(JSON.stringify(confirmRes)); }, function(confirmRes) { if (confirmRes.event === 'error') { BootpayError.postMessage(JSON.stringify(confirmRes)); } else if (confirmRes.event === 'cancel') { BootpayCancel.postMessage(JSON.stringify(confirmRes)); } })";
    if(payload?.extra?.openType == 'redirect') {
      script = "Bootpay.confirm();";
    }

    _controller.runJavaScript(script);
  }

  void removePaymentWindow() {
    _controller.runJavaScript(
        "Bootpay.removePaymentWindow();"
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
}

class _BootpayWebViewState extends State<BootpayWebView> {

  final String INAPP_URL = 'https://webview.bootpay.co.kr/4.3.3/';



  bool isClosed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
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
                widget._controller.runJavaScript(script);

              }
              widget._controller.runJavaScript(getBootpayJS());
              BootpayPrint(getBootpayJS());
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
          },
          onNavigationRequest: (NavigationRequest request) {
            if(request.url.contains("https://nid.naver.com")) {
              widget._controller.runJavaScript("document.getElementById('back').remove()");
            } 
            return NavigationDecision.navigate;
          },
          // Navigation

        ),
      )
      ..addJavaScriptChannel(
        'BootpayCancel',
        onMessageReceived: onCancel,
      )
      ..addJavaScriptChannel(
        'BootpayError',
        onMessageReceived: onError,
      )
      ..addJavaScriptChannel(
        'BootpayClose',
        onMessageReceived: onClose,
      )
      ..addJavaScriptChannel(
        'BootpayIssued',
        onMessageReceived: onIssued,
      )
      ..addJavaScriptChannel(
        'BootpayConfirm',
        onMessageReceived: onConfirm,
      )
      ..addJavaScriptChannel(
        'BootpayDone',
        onMessageReceived: onDone,
      )
      ..addJavaScriptChannel(
        'BootpayFlutterWebView',
        onMessageReceived: onRedirect,
      )
      ..loadRequest(Uri.parse(INAPP_URL));

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    widget._controller = controller;
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Stack(
      children: [
        isClosed == false ? WebViewWidget(controller: widget._controller) : Container(),
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
    if (BootpayConfig.ENV == BootpayConfig.ENV_DEBUG) {
      result.add("Bootpay.setEnvironmentMode('development');");
    } else if (BootpayConfig.ENV == BootpayConfig.ENV_STAGE) {
      result.add("Bootpay.setEnvironmentMode('stage');");
    }
    String locale = widget.payload?.extra?.locale ?? "";
    if(locale.length > 0) {
      result.add("Bootpay.setLocale('$locale');");
    }



    // result.add("Bootpay.setEnvironmentMode('development');");
    // result.add( "setTimeout(function() {" + await getAnalyticsData() + "}, 50);");
    result.add(await getAnalyticsData());
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

    // print(script);


    // return "setTimeout(function() {" + script + "}, 50);";
    return script;
  }



  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    // return "Bootpay.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
    return "window.Bootpay.\$analytics.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }

  void transactionConfirm() {
    widget.transactionConfirm();
  }



  void clickCloseButton() {

    if (this.widget.onCancel != null)
      this.widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
  }

  void debounceClose() {
    // BootpayPrint("debounceClose call");
    widget.closeController.bootpayClose(this.widget.onClose);
    // if (this.widget.debounceClose != null)
    //   this.widget.debounceClose!();
    // if (this.widget.onClose != null)
    //   this.widget.onClose!();
  }

  void removePaymentWindow() {
    setState(() {
      this.isClosed = true;
    });

    widget.removePaymentWindow();
  }
}

extension BootpayCallback on _BootpayWebViewState {
  Future<void> goConfirmEvent(JavaScriptMessage message) async {
    if (this.widget.onConfirm != null) {
      bool goTransactionConfirm = this.widget.onConfirm!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    } else if(this.widget.onConfirmAsync != null) {
      bool goTransactionConfirm = await this.widget.onConfirmAsync!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    }
  }

  void onProgressShow(bool isShow) {
    if(this.widget.payload?.extra?.openType != 'redirect' && isShow) {

    } else {
      if(this.widget.onProgressShow != null) {
        this.widget.onProgressShow!(isShow);
      }
    }
  }


  Future<void> onCancel(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.widget.onCancel != null)
      this.widget.onCancel!(message.message);
  }

  Future<void> onError(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.widget.onError != null)
      this.widget.onError!(message.message);
  }

  Future<void> onClose(JavaScriptMessage message) async {
    debounceClose();
    // if (this.widget.onClose != null) this.widget.onClose!();
    // Navigator.of(context).pop();
  }

  Future<void> onIssued(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.widget.onIssued != null)
      this.widget.onIssued!(message.message);
  }


  Future<void> onConfirm(JavaScriptMessage message) async {
    onProgressShow(true);

    await goConfirmEvent(message);
  }


  Future<void> onDone(JavaScriptMessage message) async {
    final data = json.decode(message.message);
    print(data);

    onProgressShow(false);

    if (this.widget.onDone != null) this.widget.onDone!(message.message);
  }

  Future<void> onRedirect(JavaScriptMessage message) async {
    final data = json.decode(message.message);


    switch(data["event"]) {
      case "cancel":
        onProgressShow(false);

        if (this.widget.onCancel != null) this.widget.onCancel!(message.message);
        debounceClose();
        break;
      case "error":
        onProgressShow(false);

        if (this.widget.onError != null) this.widget.onError!(message.message);
        if(this.widget.payload?.extra?.displayErrorResult != true) {
          debounceClose();
        }
        break;
      case "close":
        onProgressShow(false);

        debounceClose();
        break;
      case "issued":
        onProgressShow(false);

        if (this.widget.onIssued != null) this.widget.onIssued!(message.message);
        if(this.widget.payload?.extra?.displaySuccessResult != true) {
          debounceClose();
        }
        break;
      case "confirm":
        onProgressShow(true);

        await goConfirmEvent(message);
        break;
      case "done":
        onProgressShow(false);

        if (this.widget.onDone != null) this.widget.onDone!(message.message);
        if(this.widget.payload?.extra?.displaySuccessResult != true) {
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

/*
extension BootpayCallback on _BootpayWebViewState {
  Future<void> goConfirmEvent(JavascriptMessage message) async {
    if (this.widget.onConfirm != null) {
      bool goTransactionConfirm = this.widget.onConfirm!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    } else if(this.widget.onConfirmAsync != null) {
      bool goTransactionConfirm = await this.widget.onConfirmAsync!(message.message);
      if (goTransactionConfirm) {
        transactionConfirm();
      }
    }
  }

  JavascriptChannel onCancel(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayCancel',
        onMessageReceived: (JavascriptMessage message) {
          if(this.widget.onProgressShow != null) {
            this.widget.onProgressShow!(false);
          }
          if (this.widget.onCancel != null)
            this.widget.onCancel!(message.message);
        });
  }

  JavascriptChannel onError(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayError',
        onMessageReceived: (JavascriptMessage message) {
          if(this.widget.onProgressShow != null) {
            this.widget.onProgressShow!(false);
          }
          if (this.widget.onError != null)
            this.widget.onError!(message.message);
        });
  }

  JavascriptChannel onClose(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayClose',
        onMessageReceived: (JavascriptMessage message) {
          debounceClose();
          // if (this.widget.onClose != null) this.widget.onClose!();
          // Navigator.of(context).pop();
        });
  }

  JavascriptChannel onIssued(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayIssued',
        onMessageReceived: (JavascriptMessage message) {
          if(this.widget.onProgressShow != null) {
            this.widget.onProgressShow!(false);
          }
          if (this.widget.onIssued != null)
            this.widget.onIssued!(message.message);
        });
  }

  JavascriptChannel onConfirm(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayConfirm',
        onMessageReceived: (JavascriptMessage message) async {
          if(this.widget.onProgressShow != null) {
            this.widget.onProgressShow!(true);
          }
          await goConfirmEvent(message);
          // if (this.widget.onConfirm != null) {
          //   bool goTransactionConfirm = this.widget.onConfirm!(message.message);
          //   if (goTransactionConfirm) {
          //     transactionConfirm();
          //   }
          // } else if(this.widget.onConfirmAsync != null) {
          //   bool goTransactionConfirm = await this.widget.onConfirmAsync!(message.message);
          //   if (goTransactionConfirm) {
          //     transactionConfirm();
          //   }
          // }
        });
  }

  JavascriptChannel onDone(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayDone',
        onMessageReceived: (JavascriptMessage message) {
          if(this.widget.onProgressShow != null) {
            this.widget.onProgressShow!(true);
          }
          if (this.widget.onDone != null) this.widget.onDone!(message.message);
        });
  }

  JavascriptChannel onRedirect(BuildContext context) {
    return JavascriptChannel(
        name: 'BootpayFlutterWebView', //이벤트 이름은 Android로 하자
        onMessageReceived: (JavascriptMessage message) async {
          // BootpayPrint("redirect: ${mounted}, ${message.message}");

          final data = json.decode(message.message);
          switch(data["event"]) {
            case "cancel":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(false);
              }
              if (this.widget.onCancel != null) this.widget.onCancel!(message.message);
              debounceClose();
              break;
            case "error":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(false);
              }
              if (this.widget.onError != null) this.widget.onError!(message.message);
              if(this.widget.payload?.extra?.displayErrorResult != true) {
              debounceClose();
              }
              break;
            case "close":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(false);
              }
              debounceClose();
              break;
            case "issued":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(false);
              }
              if (this.widget.onIssued != null) this.widget.onIssued!(message.message);
              if(this.widget.payload?.extra?.displaySuccessResult != true) {
                debounceClose();
              }
              break;
            case "confirm":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(true);
              }
              await goConfirmEvent(message);
              // if (this.widget.onConfirm != null) {
              //   bool goTransactionConfirm = this.widget.onConfirm!(message.message);
              //   if (goTransactionConfirm) {
              //     transactionConfirm();
              //   }
              // }
              break;
            case "done":
              if(this.widget.onProgressShow != null) {
                this.widget.onProgressShow!(false);
              }
              if (this.widget.onDone != null) this.widget.onDone!(message.message);
              if(this.widget.payload?.extra?.displaySuccessResult != true) {
                debounceClose();
              } else {
                final content = json.decode(data["data"]);
                if(content["method_origin_symbol"] == "card_rebill_rest") {
                  debounceClose();
                }
              }
              break;
          }
        });
  }
}
*/