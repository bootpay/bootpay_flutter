import 'dart:async';
import 'dart:convert';
import 'dart:io';

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


// 1. 웹앱을 대체하는 뷰를 활용한 샘플
// 2. api 역할
class BootpayWebView extends StatefulWidget {
  final Key? key;
  Payload? payload;
  BootpayDefaultCallback? onCancel;
  BootpayDefaultCallback? onError;
  BootpayCloseCallback? onClose;
  BootpayDefaultCallback? onIssued;
  BootpayConfirmCallback? onConfirm;
  BootpayAsyncConfirmCallback? onConfirmAsync;
  BootpayDefaultCallback? onDone;

  //widget

  BootpayCloseCallback? onWidgetReady;
  WidgetResizeCallback? onWidgetResize;
  WidgetChangePaymentCallback? onWidgetChangePayment;
  WidgetChangePaymentCallback? onWidgetChangeAgreeTerm;

  BootpayProgressBarCallback? onProgressShow;
  // ShowHeaderCallback? onShowHeader;
  bool? showCloseButton = false;
  bool? isWidget = false;
  Widget? closeButton;
  String? userAgent;
  int? requestType = BootpayConstant.REQUEST_TYPE_PAYMENT; //1: 결제, 2:정기결제, 3: 본인인증
  late WebViewController _controller;

  final DebounceCloseController closeController = Get.put(DebounceCloseController());

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
        this.onWidgetResize,
        this.closeButton,
        this.userAgent,
        this.requestType
      })
      : super(key: key);

  @override
  State<BootpayWebView> createState() => BootpayWebViewState();



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

  void widgetUpdate(Payload? payload, bool? refresh) {
    if(payload == null) return;
    _controller.runJavaScript(
        "BootpayWidget.update(${payload.toString()}, ${refresh == true ? 'true' : 'false'});"
    );
  }

  void requestPayment({
    Payload? payload,
    BootpayDefaultCallback? onError,
    BootpayDefaultCallback? onCancel,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onIssued,
    BootpayConfirmCallback? onConfirm,
    BootpayAsyncConfirmCallback? onConfirmAsync,
    BootpayDefaultCallback? onDone,
  }) {
    if(onError != null) this.onError = onError;
    if(onCancel != null) this.onCancel = onCancel;
    if(onClose != null) this.onClose = onClose;
    if(onIssued != null) this.onIssued = onIssued;
    if(onConfirm != null) this.onConfirm = onConfirm;
    if(onConfirmAsync != null) this.onConfirmAsync = onConfirmAsync;
    if(onDone != null) this.onDone = onDone;
    if(payload != null) this.payload = payload;

    String script = "BootpayWidget.requestPayment(" +
        "${this.payload?.toString()}" +
        ")" +
        ".then( function (res) {" +
        confirm +
        issued +
        done +
        "}, function (res) {" +
        error +
        cancel +
        "})";

    print(script);

    _controller.runJavaScript(
        script
    );
  }


  String get confirm {
    return "if (res.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(res)); } }";
  }


  String get done {
    return "else if (res.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(res)); } }";
  }


  String get issued {
    return "else if (res.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(res)); } }";
  }

  String get error {
    return "if (res.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(res)); } }";
  }

  String get cancel {
    return "else if (res.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(res)); } }";
  }

  String get close {
    return "document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });";
  }
}

class BootpayWebViewState extends State<BootpayWebView> {

  late double _height = 516;


  // late final WebViewController _controller;
  // final Completer<WebViewController> _controller = Completer<WebViewController>();

  final String INAPP_URL = 'https://webview.bootpay.co.kr/5.0.0-beta.36/';
  late final String WIDGET_URL = INAPP_URL + 'widget.html';



  // String confirm() {
  //   return "if (res.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(res)); } }";
  // }
  //
  //
  // String done() {
  //   return "else if (res.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(res)); } }";
  // }
  //
  //
  // String issued() {
  //   return "else if (res.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String error() {
  //   return "if (res.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String cancel() {
  //   return "else if (res.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(res)); } }";
  // }
  //
  // String close() {
  //   return "document.addEventListener('bootpayclose', function (e) { if (window.BootpayClose && window.BootpayClose.postMessage) { BootpayClose.postMessage('결제창이 닫혔습니다'); } });";
  // }


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

    if(widget.userAgent != null) {
      controller.setUserAgent(widget.userAgent!);
    }

    String loadUrl = (widget.isWidget ?? false) ? WIDGET_URL : INAPP_URL;
    // print(loadUrl);

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
            (widget.isWidget ?? false) ? loadWidgetScript(url) : loadPaymentScript(url);

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
                if (this.widget.onError != null) {
                  this.widget.onError!(error.description);
                }
                debounceClose();
              }
            }
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
        'WidgetReady',
        onMessageReceived: onWidgetReadyJS,
      )
      ..addJavaScriptChannel(
        'WidgetResize',
        onMessageReceived: onWidgetResizeJS,
      )
      ..addJavaScriptChannel(
        'WidgetChangePayment',
        onMessageReceived: onWidgetChangePaymentJS,
      )
      ..addJavaScriptChannel(
        'WidgetChangeTerms',
        onMessageReceived: onWidgetChangeAgreeTermJS,
      )
      ..addJavaScriptChannel(
        'BootpayFlutterWebView',
        onMessageReceived: onRedirectJS,
      )
      ..loadRequest(Uri.parse(loadUrl));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    widget._controller = controller;
  }

  Widget platformWebViewWidget() {
    if(widget._controller.platform is AndroidWebViewController && BootpayConfig.DISPLAY_WITH_HYBRID_COMPOSITION) {
      return WebViewWidget.fromPlatformCreationParams(
        params: AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
          AndroidWebViewWidgetCreationParams(
            controller: widget._controller.platform,
          ),
          displayWithHybridComposition: true,
        ),
      );
    }
    return WebViewWidget(
        controller: widget._controller
    );
  }

  // void initWidgetEvent() {
  //   this.widget.onWidgetResize = (height) {
  //     if(_height == height) return;
  //       // set
  //     _height = height;
  //     setState(() {
  //       // _height = height;
  //     });
  //   };
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
    // if(widget.isWidget ?? false) { initWidgetEvent(); }
  }

  @override
  Widget build(BuildContext context) {

    return (widget.isWidget ?? false) ? buildWidgetUI() : buildPaymentUI();
  }

  Widget buildPaymentUI( ) {
    return Stack(
      children: [
        platformWebViewWidget(),
        if(widget.showCloseButton ?? false)
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

  Future<void> loadPaymentScript(String url) async {
    if (url.startsWith(INAPP_URL)) {
      for (String script in await getBootpayJSBeforeContentLoaded()) {
        widget._controller.runJavaScript(script);
      }

      widget._controller.runJavaScript(getBootpayJS());
    }
  }

  Future<void> loadWidgetScript(String url) async {

    if(widget.payload == null) {
      debugPrint("** bootpayWidget payload data is null !! **");
      return;
    }
    if (url.startsWith(WIDGET_URL)) {
      if(widget.payload?.widgetKey == null) debugPrint("** bootpayWidget widgetKey is null !! **");
      if(widget.payload?.widgetSandbox == null) debugPrint("** bootpayWidget widgetSandbox is null !! **");
      if(widget.payload?.widgetUseTerms == null) debugPrint("** bootpayWidget widgetUseTerms is null !! **");

      if(BootpayConfig.ENV == BootpayConfig.ENV_DEBUG) {
        widget._controller.runJavaScript("BootpayWidget.setEnvironmentMode('development', '');");
      }
      //
      // widget._controller.runJavaScript(allAgreeWatch);
      widget._controller.runJavaScript(readyWatch);
      widget._controller.runJavaScript(resizeWatch);
      widget._controller.runJavaScript(changeMethodWatch);
      widget._controller.runJavaScript(changeTermsWatch);
      widget._controller.runJavaScript(renderWidgetJS);
      widget._controller.runJavaScript(widget.close);
    }
  }

}


extension PaymentWidget on BootpayWebViewState {

  Widget buildWidgetUI() {

    return   SizedBox(
        height: _height,
        child: platformWebViewWidget()
    );
  }



  // String get allAgreeWatch {
  //   return "document.addEventListener('bootpay-all-agree-terms', function (e) { if (window.WidgetAllAgreeTerms && window.WidgetAllAgreeTerms.postMessage) { WidgetAllAgreeTerms.postMessage(JSON.stringify(e.detail)); } });";
  // }

  String get readyWatch {
    return "document.addEventListener('bootpay-widget-ready', function (e) { if (window.WidgetReady && window.WidgetReady.postMessage) { WidgetReady.postMessage(JSON.stringify(e.detail)); } });";
  }

  // {"height": 700}
  String get resizeWatch {
    return "document.addEventListener('bootpay-widget-resize', function (e) { if (window.WidgetResize && window.WidgetResize.postMessage) { WidgetResize.postMessage(JSON.stringify(e.detail)); } });";
  }

  // {"pg":"nicepay","method":"card","select_terms":[{"term_id":"65eec9c1ca8deb0060382a7f","pk":"test_1","title":"테스트약관","term_type":1},{"term_id":"65eec9c1ca8deb0060382a80","pk":"new-terms","title":"새로운약관","term_type":1},{"pk":"external-test-1","title":"부트페이 외부 약관1","term_type":2}],"term_passed":false,"extra":{"direct_card_company":"하나","direct_card_quota":3,"direct_card_interest":true,"card_quota":0}}
  String get changeMethodWatch {
    return "document.addEventListener('bootpay-widget-change-payment', function (e) { if (window.WidgetChangePayment && window.WidgetChangePayment.postMessage) { WidgetChangePayment.postMessage(JSON.stringify(e.detail)); } });";
  }

  String get changeTermsWatch {
    return "document.addEventListener('bootpay-widget-change-terms', function (e) { if (window.WidgetChangeTerms && window.WidgetChangeTerms.postMessage) { WidgetChangeTerms.postMessage(JSON.stringify(e.detail)); } });";
  }

  String get renderWidgetJS {
    String temp =   "BootpayWidget.render('#bootpay-widget', " +
        "${this.widget.payload?.toString()}" +
        ")";
    print(temp);
    return temp;
  }

}

extension BootpayMethod on BootpayWebViewState {
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
    String locale = widget.payload?.extra?.locale ?? "";
    if(locale.length > 0) {
      result.add("Bootpay.setLocale('$locale');");
    }

    result.add(await getAnalyticsData());
    result.add(widget.close);

    return result;
  }

  String getBootpayJS() {
    String requestMethod = 'requestPayment';
    if(this.widget.requestType == BootpayConstant.REQUEST_TYPE_SUBSCRIPT) {
      requestMethod = 'requestSubscription';
    } else if(this.widget.requestType == BootpayConstant.REQUEST_TYPE_AUTH) {
      requestMethod = 'requestAuthentication';
    } else if(this.widget.requestType == BootpayConstant.REQUEST_TYPE_PASSWORD) {
      this.widget.payload?.method = "카드간편";
    }

    String script = "Bootpay.${requestMethod}(" +
        "${this.widget.payload.toString()}" +
        ")" +
        ".then( function (res) {" +
        widget.confirm +
        widget.issued +
        widget.done +
        "}, function (res) {" +
        widget.error +
        widget.cancel +
        "})";

    print(script);

    return script;
  }


  Future<String> getAnalyticsData() async {
    UserInfo.updateInfo();
    return "window.Bootpay.\$analytics.setAnalyticsData({uuid:'${await UserInfo.getBootpayUUID()}',sk:'${await UserInfo.getBootpaySK()}',sk_time:'${await UserInfo.getBootpayLastTime()}',time:'${DateTime.now().millisecondsSinceEpoch - await UserInfo.getBootpayLastTime()}'});";
  }

  void clickCloseButton() {
    if (this.widget.onCancel != null)
      this.widget.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
  }

  void debounceClose() {
    widget.closeController.bootpayClose(this.widget.onClose);
  }

  void removePaymentWindow() {
    removePaymentWindow();
  }
}

extension BootpayCallback on BootpayWebViewState {
  Future<void> goConfirmEvent(JavaScriptMessage message) async {

    if (this.widget.onConfirm != null) {
      bool goTransactionConfirm = this.widget.onConfirm!(message.message);
      if (goTransactionConfirm) {
        widget.transactionConfirm();
      }
    } else if(this.widget.onConfirmAsync != null) {
      bool goTransactionConfirm = await this.widget.onConfirmAsync!(message.message);
      if (goTransactionConfirm) {
        widget.transactionConfirm();
      }
    }
  }

  void onProgressShow(bool isShow) {
    print(isShow);
    // if(this.widget.payload?.extra?.openType != 'redirect' && isShow) {
    //
    // } else {
    //   print(this.onProgressShow);
    //   if(this.onProgressShow != null) {
    //     this.onProgressShow!(isShow);
    //   }
    // }
    // this.onProgressShow(isShow);
  }


  Future<void> onCancelJS(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.widget.onCancel != null)
      this.widget.onCancel!(message.message);
  }

  Future<void> onErrorJS(JavaScriptMessage message) async {
    onProgressShow(false);

    if (this.widget.onError != null)
      this.widget.onError!(message.message);
  }

  Future<void> onCloseJS(JavaScriptMessage message) async {
    debounceClose();
  }

  Future<void> onIssuedJS(JavaScriptMessage message) async {
    onProgressShow(false);
    if (this.widget.onIssued != null)
      this.widget.onIssued!(message.message);
  }


  Future<void> onConfirmJS(JavaScriptMessage message) async {
    onProgressShow(true);
    await goConfirmEvent(message);
  }


  Future<void> onDoneJS(JavaScriptMessage message) async {
    onProgressShow(false);
    if (this.widget.onDone != null) this.widget.onDone!(message.message);
  }

  // Future<void> onWidgetChangeAgreeTermJS(JavaScriptMessage message) async {
  //   print("onWidgetAllAgreeTermsJS : ${message.message}");
  //   if (this.widget.onWidgetChangeAgreeTerm != null) this.widget.onWidgetChangeAgreeTerm!(message.message);
  // }

  Future<void> onWidgetReadyJS(JavaScriptMessage message) async {
    // print("onWidgetReadyJS : ${message.message}");
    if (this.widget.onWidgetReady != null) this.widget.onWidgetReady!();
  }

  Future<void> onWidgetResizeJS(JavaScriptMessage message) async {
    // print("onWidgetResizeJS : ${message.message}");
    try {
      Map<String, dynamic> data = jsonDecode(message.message);
      double height = double.parse(data['height'].toString());
      if (this.widget.onWidgetResize != null) this.widget.onWidgetResize!(height);
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  Future<void> onWidgetChangePaymentJS(JavaScriptMessage message) async {
    // print("onWidgetChangePaymentJS : ${message.message}");
    try {
      Map<String, dynamic> data = jsonDecode(message.message);
      WidgetData widgetData = WidgetData.fromJson(data);
      if (this.widget.onWidgetChangePayment != null) this.widget.onWidgetChangePayment!(widgetData);
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  Future<void> onWidgetChangeAgreeTermJS(JavaScriptMessage message) async {
    // print("onWidgetChangeTermsJS : ${message.message}");
    try {
      Map<String, dynamic> data = jsonDecode(message.message);
      WidgetData widgetData = WidgetData.fromJson(data);
      if (this.widget.onWidgetChangeAgreeTerm != null) this.widget.onWidgetChangeAgreeTerm!(widgetData);
    } catch (e) {
      print("Error parsing JSON: $e");
    }
  }

  Future<void> onRedirectJS(JavaScriptMessage message) async {
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
