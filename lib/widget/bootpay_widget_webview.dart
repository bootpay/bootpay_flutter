import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';

import '../config/bootpay_config.dart';
import '../model/payload.dart';
import '../model/widget/widget_data.dart';
import '../user_info.dart';

/// 위젯 URL 상수
class _WidgetConstants {
  static const String INAPP_URL = 'https://webview.bootpay.co.kr/5.2.2/';
  static const String WIDGET_URL = '${INAPP_URL}widget.html';
  // Bootpay SDK가 이미 window.Bootpay를 사용하므로 다른 이름 사용
  static const String BRIDGE_NAME = 'BootpayFlutterBridge';
}

/// 위젯 이벤트 콜백 타입 정의 (내부 사용, bootpay.dart의 typedef와 충돌 방지)
typedef _WidgetReadyCallback = void Function();
typedef _WidgetResizeCallback = void Function(double height);
typedef _WidgetChangeCallback = void Function(WidgetData? data);
typedef _WidgetEventCallback = void Function(String data);
typedef _WidgetConfirmCallback = bool Function(String data);
typedef _WidgetCloseCallback = void Function();

/// 위젯 전용 웹뷰 (네이티브 SDK와 동일한 구조)
class BootpayWidgetWebView extends StatefulWidget {
  final Payload payload;
  final BootpayWidgetWebViewController? controller;

  const BootpayWidgetWebView({
    Key? key,
    required this.payload,
    this.controller,
  }) : super(key: key);

  @override
  State<BootpayWidgetWebView> createState() => _BootpayWidgetWebViewState();
}

class _BootpayWidgetWebViewState extends State<BootpayWidgetWebView> {
  late WebViewController _webViewController;
  bool _isWidgetReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    debugPrint('[BootpayWidgetWebView] _initWebView START');
    debugPrint('[BootpayWidgetWebView] Platform: ${kIsWeb ? "Web" : Platform.operatingSystem}');

    // iOS용 WebKit 설정 (bootpay_webview.dart와 동일)
    late PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
      debugPrint('[BootpayWidgetWebView] Using BTWebKitWebViewPlatform (iOS)');
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      debugPrint('[BootpayWidgetWebView] Using default PlatformWebViewControllerCreationParams');
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('[BootpayWidgetWebView] Page started: $url');
          },
          onPageFinished: _onPageFinished,
          onNavigationRequest: _onNavigationRequest,
          onWebResourceError: (error) {
            debugPrint('[BootpayWidgetWebView] WebResourceError: ${error.description}, code: ${error.errorCode}');
          },
        ),
      )
      // 위젯 이벤트용 브릿지
      ..addJavaScriptChannel(
        _WidgetConstants.BRIDGE_NAME,
        onMessageReceived: _onJavaScriptMessage,
      )
      // 결제 이벤트용 브릿지 (bootpay_webview.dart와 동일)
      ..addJavaScriptChannel(
        'BootpayDone',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayDone: ${message.message}');
          widget.controller?._handleDone(message.message);
        },
      )
      ..addJavaScriptChannel(
        'BootpayConfirm',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayConfirm: ${message.message}');
          final shouldConfirm = widget.controller?._handleConfirm(message.message) ?? true;
          if (shouldConfirm) {
            _transactionConfirm();
          }
        },
      )
      ..addJavaScriptChannel(
        'BootpayCancel',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayCancel: ${message.message}');
          widget.controller?._handleCancel(message.message);
        },
      )
      ..addJavaScriptChannel(
        'BootpayError',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayError: ${message.message}');
          widget.controller?._handleError(message.message);
        },
      )
      ..addJavaScriptChannel(
        'BootpayIssued',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayIssued: ${message.message}');
          widget.controller?._handleIssued(message.message);
        },
      )
      ..addJavaScriptChannel(
        'BootpayClose',
        onMessageReceived: (message) {
          debugPrint('[BootpayWidgetWebView] BootpayClose: ${message.message}');
          widget.controller?._handleClose();
        },
      )
      // 리다이렉트 방식 결제 결과 처리 (bootpay_webview.dart와 동일)
      ..addJavaScriptChannel(
        'BootpayFlutterWebView',
        onMessageReceived: _onRedirectJS,
      )
      ..addJavaScriptChannel(
        'FlutterConsole',
        onMessageReceived: (message) {
          debugPrint('[WebView Console] ${message.message}');
        },
      );

    debugPrint('[BootpayWidgetWebView] WebViewController created');

    // 위젯 컨트롤러에 웹뷰 컨트롤러 연결
    widget.controller?._setWebViewController(_webViewController);
    widget.controller?._setPayload(widget.payload);
    debugPrint('[BootpayWidgetWebView] Controller connected');

    // 위젯 URL 로드
    _loadWidgetUrl();
    debugPrint('[BootpayWidgetWebView] _initWebView END');
  }

  void _loadWidgetUrl() {
    debugPrint('[BootpayWidgetWebView] Loading widget URL: ${_WidgetConstants.WIDGET_URL}');
    _webViewController.loadRequest(Uri.parse(_WidgetConstants.WIDGET_URL));
  }

  void _onPageFinished(String url) {
    debugPrint('[BootpayWidgetWebView] Page finished: $url');
    if (url.contains('webview.bootpay.co.kr') && url.contains('widget.html')) {
      debugPrint('[BootpayWidgetWebView] Widget page loaded, calling _renderWidget');
      _renderWidget();
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    debugPrint('[BootpayWidgetWebView] Navigation request: ${request.url}');
    return NavigationDecision.navigate;
  }

  void _onJavaScriptMessage(JavaScriptMessage message) {
    debugPrint('[BootpayWidgetWebView] ===== JS MESSAGE RECEIVED =====');
    debugPrint('[BootpayWidgetWebView] Raw message: ${message.message}');
    try {
      final data = jsonDecode(message.message);
      if (data is Map<String, dynamic>) {
        _parseWidgetEvent(data);
      }
    } catch (e) {
      debugPrint('[BootpayWidgetWebView] JSON parse error: $e');
      // String 메시지 처리
      if (message.message == 'close') {
        widget.controller?._handleClose();
      }
    }
  }

  void _parseWidgetEvent(Map<String, dynamic> data) {
    final event = data['event'] as String?;
    if (event == null) return;

    debugPrint('[BootpayWidgetWebView] Event: $event, Data: $data');

    switch (event) {
      case 'widget_ready':
        _isWidgetReady = true;
        widget.controller?._handleReady();
        break;

      case 'widget_resize':
        // e.detail.height 형태로 전달됨
        final height = (data['height'] as num?)?.toDouble() ?? 0;
        widget.controller?._handleResize(height);
        break;

      case 'widget_change_payment':
        // e.detail 형태로 전달됨
        final widgetData = _parseWidgetData(data);
        widget.controller?._handleChangePayment(widgetData);
        break;

      case 'widget_change_agree_term':
        // e.detail 형태로 전달됨
        final widgetData = _parseWidgetData(data);
        widget.controller?._handleChangeAgreeTerm(widgetData);
        break;

      case 'error':
        widget.controller?._handleError(jsonEncode(data));
        break;

      case 'cancel':
        widget.controller?._handleCancel(jsonEncode(data));
        break;

      case 'done':
        widget.controller?._handleDone(jsonEncode(data));
        break;

      case 'confirm':
        final shouldConfirm = widget.controller?._handleConfirm(jsonEncode(data)) ?? true;
        if (shouldConfirm) {
          _transactionConfirm();
        }
        break;

      case 'issued':
        widget.controller?._handleIssued(jsonEncode(data));
        break;

      case 'close':
        widget.controller?._handleClose();
        break;
    }
  }

  WidgetData? _parseWidgetData(Map<String, dynamic> data) {
    if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
      return WidgetData.fromJson(data['data']);
    }
    return WidgetData.fromJson(data);
  }

  void _renderWidget() {
    final payload = widget.payload;
    final renderScript = _getRenderWidgetJS(payload);

    debugPrint('[BootpayWidgetWebView] ========== RENDER START ==========');
    debugPrint('[BootpayWidgetWebView] Payload toString():');
    debugPrint('${payload.toString()}');
    debugPrint('[BootpayWidgetWebView] ========== RENDER SCRIPT ==========');
    debugPrint(renderScript);
    debugPrint('[BootpayWidgetWebView] ==================================');

    // setDevice, setVersion 호출 (Android/iOS 네이티브와 동일)
    _runDeviceSetup();

    // Android와 동일: waitForBootpayWidget으로 BootpayWidget 로드 대기 후 실행
    _webViewController.runJavaScript(renderScript);
  }

  void _runDeviceSetup() {
    if (kIsWeb || BootpayConfig.IS_FORCE_WEB) {
      _webViewController.runJavaScript("Bootpay.setVersion('${BootpayConfig.VERSION}', 'flutter');");
    } else if (Platform.isAndroid) {
      _webViewController.runJavaScript("Bootpay.setDevice('ANDROID');");
      _webViewController.runJavaScript("Bootpay.setVersion('${BootpayConfig.VERSION}', 'android_flutter');");
    } else if (Platform.isIOS) {
      _webViewController.runJavaScript("Bootpay.setDevice('IOS');");
      _webViewController.runJavaScript("Bootpay.setVersion('${BootpayConfig.VERSION}', 'ios_flutter');");
    }
  }


  /// 위젯 렌더 스크립트 (Android BootpayScript.renderWidget과 동일한 구조)
  /// waitForBootpayWidget으로 BootpayWidget 로드 대기 후 실행
  String _getRenderWidgetJS(Payload payload) {
    final bridgeName = _WidgetConstants.BRIDGE_NAME;

    // Android와 동일한 waitForBootpayWidget 함수
    const waitForBootpayWidget = '''
function waitForBootpayWidget(callback) {
  if (typeof BootpayWidget !== 'undefined') { callback(); }
  else { setTimeout(function() { waitForBootpayWidget(callback); }, 50); }
}
''';

    // iOS/Android 모두 지원하는 브릿지 호출 헬퍼 함수
    final bridgeHelper = '''
function flutterBridgePost(message) {
  console.log('[flutterBridgePost] Attempting to send message:', message);
  console.log('[flutterBridgePost] window.webkit:', typeof window.webkit);
  console.log('[flutterBridgePost] window.$bridgeName:', typeof window.$bridgeName);

  if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.$bridgeName) {
    console.log('[flutterBridgePost] Using iOS bridge (webkit)');
    window.webkit.messageHandlers.$bridgeName.postMessage(message);
  } else if (window.$bridgeName && window.$bridgeName.postMessage) {
    console.log('[flutterBridgePost] Using Android bridge (window.$bridgeName)');
    window.$bridgeName.postMessage(message);
  } else {
    console.log('[flutterBridgePost] ERROR: No bridge found!');
    console.log('[flutterBridgePost] Available window keys:', Object.keys(window).filter(k => k.toLowerCase().includes('boot') || k.toLowerCase().includes('flutter')));
  }
}
''';

    // 이벤트 리스너 스크립트 (iOS/Android 모두 지원) - console.log 추가하여 디버깅
    final readyWatch = "document.addEventListener('bootpay-widget-ready', function (e) { console.log('[Flutter Widget] bootpay-widget-ready event fired', e.detail); flutterBridgePost(JSON.stringify({event: 'widget_ready', data: e.detail})); });";
    final resizeWatch = "document.addEventListener('bootpay-widget-resize', function (e) { console.log('[Flutter Widget] bootpay-widget-resize event fired', e.detail); flutterBridgePost(JSON.stringify({event: 'widget_resize', height: e.detail.height})); });";
    final changeMethodWatch = "document.addEventListener('bootpay-widget-change-payment', function (e) { console.log('[Flutter Widget] bootpay-widget-change-payment event fired', e.detail); flutterBridgePost(JSON.stringify({event: 'widget_change_payment', data: e.detail})); });";
    final changeTermsWatch = "document.addEventListener('bootpay-widget-change-terms', function (e) { console.log('[Flutter Widget] bootpay-widget-change-terms event fired', e.detail); flutterBridgePost(JSON.stringify({event: 'widget_change_agree_term', data: e.detail})); });";
    // iOS Swift SDK와 동일하게 bootpayclose 이벤트 리스너 추가
    final closeWatch = "document.addEventListener('bootpayclose', function (e) { console.log('[Flutter Widget] bootpayclose event fired'); flutterBridgePost('close'); });";

    // 디버깅: console.log를 Flutter로 전달
    const consoleOverride = '''
// console.log를 Flutter로 전달
(function() {
  var originalLog = console.log;
  console.log = function() {
    var args = Array.prototype.slice.call(arguments);
    var message = args.map(function(arg) {
      try { return typeof arg === 'object' ? JSON.stringify(arg) : String(arg); }
      catch(e) { return String(arg); }
    }).join(' ');
    if (window.FlutterConsole && window.FlutterConsole.postMessage) {
      window.FlutterConsole.postMessage(message);
    }
    originalLog.apply(console, arguments);
  };
})();
''';

    // 디버깅: 모든 bootpay 관련 이벤트를 감시
    const eventDebugger = '''
// 디버깅: 모든 bootpay 이벤트 감시
['bootpay-widget-ready', 'bootpay-widget-resize', 'bootpay-widget-change-payment', 'bootpay-widget-change-terms', 'bootpayclose', 'bootpay-widget-change-method', 'change-payment', 'widget-change-payment'].forEach(function(eventName) {
  document.addEventListener(eventName, function(e) {
    console.log('[Flutter Debug] Event detected: ' + eventName, e.detail);
  });
});
''';

    // Android와 동일한 구조: waitForBootpayWidget 내부에서 이벤트 리스너 등록 후 render 호출
    return '''
$consoleOverride
$waitForBootpayWidget
$bridgeHelper
$eventDebugger
waitForBootpayWidget(function() {
  console.log('[Flutter Widget] BootpayWidget found, registering event listeners...');
  $readyWatch
  $resizeWatch
  $changeMethodWatch
  $changeTermsWatch
  $closeWatch
  console.log('[Flutter Widget] Event listeners registered, rendering widget...');
  console.log('[Flutter Widget] Payload: ${payload.toString().replaceAll("'", "\\'")}');
  BootpayWidget.render('#bootpay-widget', ${payload.toString()});
  console.log('[Flutter Widget] Widget render called');
});
''';
  }

  void _transactionConfirm() {
    // bootpay_webview.dart와 동일한 transactionConfirm 스크립트
    const script = "Bootpay.confirm().then(function(confirmRes) { "
        "if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(confirmRes)); } "
        "}, function(confirmRes) { "
        "if (confirmRes.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(confirmRes)); } } "
        "else if (confirmRes.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(confirmRes)); } } "
        "})";
    debugPrint('[BootpayWidgetWebView] transactionConfirm: $script');
    _webViewController.runJavaScript(script);
  }

  /// 리다이렉트 방식 결제 결과 처리 (bootpay_webview.dart의 onRedirectJS와 동일)
  void _onRedirectJS(JavaScriptMessage message) {
    debugPrint('[BootpayWidgetWebView] _onRedirectJS: ${message.message}');

    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final event = data['event'] as String?;

      debugPrint('[BootpayWidgetWebView] Redirect event: $event');

      switch (event) {
        case 'cancel':
          widget.controller?._handleCancel(message.message);
          break;
        case 'error':
          widget.controller?._handleError(message.message);
          break;
        case 'close':
          widget.controller?._handleClose();
          break;
        case 'issued':
          widget.controller?._handleIssued(message.message);
          break;
        case 'confirm':
          debugPrint('[BootpayWidgetWebView] Handling confirm event from redirect');
          final shouldConfirm = widget.controller?._handleConfirm(message.message) ?? true;
          if (shouldConfirm) {
            debugPrint('[BootpayWidgetWebView] Calling transactionConfirm');
            _transactionConfirm();
          }
          break;
        case 'done':
          widget.controller?._handleDone(message.message);
          break;
      }
    } catch (e) {
      debugPrint('[BootpayWidgetWebView] Error parsing redirect JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webViewController);
  }
}

/// 위젯 전용 웹뷰 컨트롤러 (네이티브 SDK와 동일한 구조)
class BootpayWidgetWebViewController {
  WebViewController? _webViewController;
  Payload? _payload;

  // 콜백
  _WidgetReadyCallback? onReady;
  _WidgetResizeCallback? onResize;
  _WidgetChangeCallback? onChangePayment;
  _WidgetChangeCallback? onChangeAgreeTerm;
  _WidgetEventCallback? onError;
  _WidgetEventCallback? onCancel;
  _WidgetEventCallback? onDone;
  _WidgetConfirmCallback? onConfirm;
  _WidgetEventCallback? onIssued;
  _WidgetCloseCallback? onClose;

  // 위젯 상태
  double _widgetHeight = 300.0;
  double get widgetHeight => _widgetHeight;

  WidgetData? _widgetData;
  WidgetData? get widgetData => _widgetData;

  void _setWebViewController(WebViewController controller) {
    _webViewController = controller;
  }

  void _setPayload(Payload payload) {
    _payload = payload;
  }

  /// 위젯 업데이트
  void update({required Payload payload, bool refresh = false}) {
    _payload = payload;
    final script = '''
      BootpayWidget.update(${payload.toString()}, ${refresh ? 'true' : 'false'});
    ''';
    _webViewController?.runJavaScript(script);
  }

  /// 위젯 재로드 (에러/취소 후 재시도 시 사용)
  void reloadWidget() {
    _webViewController?.loadRequest(Uri.parse(_WidgetConstants.WIDGET_URL));
  }

  /// 결제 요청
  void requestPayment({
    Payload? payload,
    _WidgetEventCallback? onError,
    _WidgetEventCallback? onCancel,
    _WidgetCloseCallback? onClose,
    _WidgetEventCallback? onIssued,
    _WidgetConfirmCallback? onConfirm,
    _WidgetEventCallback? onDone,
  }) {
    // 콜백 설정
    if (onError != null) this.onError = onError;
    if (onCancel != null) this.onCancel = onCancel;
    if (onClose != null) this.onClose = onClose;
    if (onIssued != null) this.onIssued = onIssued;
    if (onConfirm != null) this.onConfirm = onConfirm;
    if (onDone != null) this.onDone = onDone;

    final currentPayload = payload ?? _payload;
    if (currentPayload == null) {
      debugPrint('[BootpayWidgetWebViewController] requestPayment - payload is null');
      return;
    }

    debugPrint('[BootpayWidgetWebViewController] Requesting payment...');
    _executeRequestPayment(currentPayload);
  }

  /// 결제 요청 실행 (iOS Swift SDK와 동일하게 setDevice, setVersion, setUUID 설정 후 실행)
  Future<void> _executeRequestPayment(Payload payload) async {
    final uuid = await UserInfo.getBootpayUUID();
    debugPrint('[BootpayWidgetWebViewController] _executeRequestPayment - UUID: $uuid');

    // iOS Swift SDK의 getJSWidgetRequestPayment와 동일한 설정
    if (!kIsWeb && !BootpayConfig.IS_FORCE_WEB) {
      if (Platform.isIOS) {
        debugPrint('[BootpayWidgetWebViewController] Setting iOS device info');
        _webViewController?.runJavaScript("Bootpay.setDevice('IOS');");
        _webViewController?.runJavaScript("Bootpay.setVersion('${BootpayConfig.VERSION}', 'ios_flutter');");
        _webViewController?.runJavaScript("BootpaySDK.setDevice('IOS');");
        _webViewController?.runJavaScript("BootpaySDK.setUUID('$uuid');");
      } else if (Platform.isAndroid) {
        debugPrint('[BootpayWidgetWebViewController] Setting Android device info');
        _webViewController?.runJavaScript("Bootpay.setDevice('ANDROID');");
        _webViewController?.runJavaScript("Bootpay.setVersion('${BootpayConfig.VERSION}', 'android_flutter');");
        _webViewController?.runJavaScript("BootpaySDK.setDevice('ANDROID');");
        _webViewController?.runJavaScript("BootpaySDK.setUUID('$uuid');");
      }
    }

    final script = _getRequestPaymentScript(payload);
    debugPrint('[BootpayWidgetWebViewController] Running requestPayment script');
    debugPrint('[BootpayWidgetWebViewController] Script: $script');
    _webViewController?.runJavaScript(script);
  }

  /// 결제 요청 스크립트 (bootpay_webview.dart와 동일한 방식)
  /// 각 이벤트별로 별도의 JavaScript Channel 사용
  String _getRequestPaymentScript(Payload payload) {
    // bootpay_webview.dart와 동일한 이벤트 핸들러
    const confirmEventHandler = "if (res.event === 'confirm') { if (window.BootpayConfirm && window.BootpayConfirm.postMessage) { BootpayConfirm.postMessage(JSON.stringify(res)); } }";
    const issuedEventHandler = "else if (res.event === 'issued') { if (window.BootpayIssued && window.BootpayIssued.postMessage) { BootpayIssued.postMessage(JSON.stringify(res)); } }";
    const doneEventHandler = "else if (res.event === 'done') { if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(res)); } }";
    const errorEventHandler = "if (res.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(res)); } }";
    const cancelEventHandler = "else if (res.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(res)); } }";

    // iOS Swift SDK와 동일하게 최소한의 결제 정보만 전달
    final requestPaymentJson = _getRequestPaymentJson(payload);
    debugPrint('[BootpayWidgetWebViewController] RequestPayment JSON: $requestPaymentJson');

    // bootpay_webview.dart와 동일한 스크립트 구조
    final script = "BootpayWidget.requestPayment($requestPaymentJson)"
        ".then( function (res) {"
        "console.log('[BootpayWidget] requestPayment response:', res);"
        "$confirmEventHandler"
        "$issuedEventHandler"
        "$doneEventHandler"
        "}, function (res) {"
        "console.log('[BootpayWidget] requestPayment error:', res);"
        "$errorEventHandler"
        "$cancelEventHandler"
        "})";

    return script;
  }

  /// iOS Swift SDK의 getWidgetRequestPaymentJson과 동일한 구조
  /// render 시 설정된 값 외에 결제 요청에 필요한 정보만 전달
  String _getRequestPaymentJson(Payload payload) {
    List<String> parts = [];

    void addPart(String key, dynamic value, {bool isString = true}) {
      if (value != null && value.toString().isNotEmpty) {
        if (isString && value is String) {
          parts.add("$key: '${value.replaceAll("'", "\\'")}'");
        } else {
          parts.add("$key: $value");
        }
      }
    }

    // 주문 정보
    addPart('order_name', payload.orderName);
    addPart('order_id', payload.orderId);
    if (payload.metadata != null) {
      parts.add("metadata: ${payload.metadata}");
    }
    addPart('user_token', payload.userToken);

    // Extra (결제 요청용 - redirect_url 필수)
    List<String> extraParts = [];
    if (payload.extra?.appScheme != null) {
      extraParts.add("app_scheme: '${payload.extra!.appScheme}'");
    }
    extraParts.add("show_close_button: ${payload.extra?.showCloseButton ?? false}");
    extraParts.add("display_success_result: ${payload.extra?.displaySuccessResult ?? false}");
    extraParts.add("display_error_result: ${payload.extra?.displayErrorResult ?? true}");
    if (payload.extra?.separatelyConfirmed == true) {
      extraParts.add("separately_confirmed: true");
    }
    // redirect_url 필수 (iOS Swift SDK와 동일)
    extraParts.add("redirect_url: 'https://api.bootpay.co.kr/v2/callback'");
    parts.add("extra: {${extraParts.join(', ')}}");

    // User
    if (payload.user != null) {
      List<String> userParts = [];
      if (payload.user!.id != null && payload.user!.id!.isNotEmpty) {
        userParts.add("id: '${payload.user!.id}'");
      }
      if (payload.user!.username != null && payload.user!.username!.isNotEmpty) {
        userParts.add("username: '${payload.user!.username}'");
      }
      if (payload.user!.email != null && payload.user!.email!.isNotEmpty) {
        userParts.add("email: '${payload.user!.email}'");
      }
      if (payload.user!.phone != null && payload.user!.phone!.isNotEmpty) {
        userParts.add("phone: '${payload.user!.phone}'");
      }
      if (userParts.isNotEmpty) {
        parts.add("user: {${userParts.join(', ')}}");
      }
    }

    // Items
    if (payload.items != null && payload.items!.isNotEmpty) {
      parts.add("items: ${payload.items!.map((e) => e.toString()).toList()}");
    }

    return "{${parts.join(', ')}}";
  }

  /// 결제 확인 (confirm 이벤트에서 호출)
  void transactionConfirm() {
    // bootpay_webview.dart와 동일한 transactionConfirm 스크립트
    const script = "Bootpay.confirm().then(function(confirmRes) { "
        "if (window.BootpayDone && window.BootpayDone.postMessage) { BootpayDone.postMessage(JSON.stringify(confirmRes)); } "
        "}, function(confirmRes) { "
        "if (confirmRes.event === 'error') { if (window.BootpayError && window.BootpayError.postMessage) { BootpayError.postMessage(JSON.stringify(confirmRes)); } } "
        "else if (confirmRes.event === 'cancel') { if (window.BootpayCancel && window.BootpayCancel.postMessage) { BootpayCancel.postMessage(JSON.stringify(confirmRes)); } } "
        "})";
    debugPrint('[BootpayWidgetWebViewController] transactionConfirm: $script');
    _webViewController?.runJavaScript(script);
  }

  // 내부 이벤트 핸들러
  void _handleReady() {
    onReady?.call();
  }

  void _handleResize(double height) {
    if (_widgetHeight != height) {
      _widgetHeight = height;
      onResize?.call(height);
    }
  }

  void _handleChangePayment(WidgetData? data) {
    _widgetData = data;
    onChangePayment?.call(data);
  }

  void _handleChangeAgreeTerm(WidgetData? data) {
    _widgetData = data;
    onChangeAgreeTerm?.call(data);
  }

  void _handleError(String data) {
    onError?.call(data);
  }

  void _handleCancel(String data) {
    onCancel?.call(data);
  }

  void _handleDone(String data) {
    onDone?.call(data);
  }

  bool _handleConfirm(String data) {
    return onConfirm?.call(data) ?? true;
  }

  void _handleIssued(String data) {
    onIssued?.call(data);
  }

  void _handleClose() {
    onClose?.call();
  }
}
