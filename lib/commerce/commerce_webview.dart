import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bootpay_webview_flutter/bootpay_webview_flutter.dart';
import 'package:bootpay_webview_flutter_android/bootpay_webview_flutter_android.dart';
import 'package:bootpay_webview_flutter_wkwebview/bootpay_webview_flutter_wkwebview.dart';

import '../model/commerce/commerce_payload.dart';
import 'bootpay_commerce.dart';

/// Commerce 결제 WebView 페이지
class CommerceWebViewPage extends StatefulWidget {
  final CommercePayload payload;
  final String environmentMode;
  final bool showCloseButton;
  final Widget? closeButton;
  final CommerceDefaultCallback? onDone;
  final CommerceDefaultCallback? onError;
  final CommerceDefaultCallback? onCancel;
  final CommerceDefaultCallback? onIssued;
  final CommerceCloseCallback? onClose;

  const CommerceWebViewPage({
    Key? key,
    required this.payload,
    this.environmentMode = 'production',
    this.showCloseButton = false,
    this.closeButton,
    this.onDone,
    this.onError,
    this.onCancel,
    this.onIssued,
    this.onClose,
  }) : super(key: key);

  @override
  State<CommerceWebViewPage> createState() => _CommerceWebViewPageState();
}

class _CommerceWebViewPageState extends State<CommerceWebViewPage> {
  late WebViewController _controller;
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is BTWebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('[CommerceWebView] Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            debugPrint('[CommerceWebView] Page started: $url');
          },
          onPageFinished: (String url) {
            debugPrint('[CommerceWebView] Page finished: $url');
            _onPageFinished(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('[CommerceWebView] Error: ${error.description}');
            if (error.errorCode == 3 &&
                error.description.contains('sslerror:')) {
              widget.onError?.call({
                'event': 'error',
                'error_code': error.errorCode,
                'message': error.description,
              });
              _debounceCloseCallback();
              _removePaymentWindow();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('[CommerceWebView] Navigation request: ${request.url}');
            return _handleNavigationRequest(request);
          },
          onUrlChange: (UrlChange change) {
            debugPrint('[CommerceWebView] URL changed: ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Bootpay',
        onMessageReceived: _onMessageReceived,
      )
      ..addJavaScriptChannel(
        'CommerceClose',
        onMessageReceived: (message) {
          debugPrint('[CommerceWebView] Close message received');
          _debounceCloseCallback();
          _removePaymentWindow();
        },
      )
      ..loadRequest(Uri.parse(BootpayCommerce.COMMERCE_URL));

    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  void _onPageFinished(String url) {
    if (url.contains('webview.bootpay.co.kr/commerce')) {
      setState(() {
        _isLoading = false;
      });

      // 환경 설정
      _controller.runJavaScript(
          "BootpayCommerce.setEnvironmentMode('${widget.environmentMode}');");

      // close 이벤트 리스너 등록
      _controller.runJavaScript(
          "document.addEventListener('bootpayclose', function(e) { if (window.CommerceClose && window.CommerceClose.postMessage) { CommerceClose.postMessage('close'); } });");

      // 결제 요청 JavaScript 실행
      final checkoutScript = _getCheckoutScript();
      _controller.runJavaScript(checkoutScript);
      debugPrint('[CommerceWebView] Checkout script executed');
    }
  }

  String _getCheckoutScript() {
    final payloadJson = widget.payload.toJsonString();
    debugPrint('[CommerceWebView] Payload JSON: $payloadJson');

    return '''
      BootpayCommerce.requestCheckout($payloadJson)
        .then(function(res) {
          console.log('[BootpayCommerce] requestCheckout response:', res);
          if (window.Bootpay && window.Bootpay.postMessage) {
            Bootpay.postMessage(JSON.stringify(res));
          }
        })
        .catch(function(err) {
          console.error('[BootpayCommerce] requestCheckout error:', err);
          if (window.Bootpay && window.Bootpay.postMessage) {
            Bootpay.postMessage(JSON.stringify({event: 'error', data: err}));
          }
        });
    ''';
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final url = request.url;

    // 콜백 URL 처리 (api.bootpay.co.kr/v2/callback)
    if (url.contains('api.bootpay.co.kr/v2/callback')) {
      debugPrint('[CommerceWebView] Callback URL detected');
      _handleCallbackUrl(url);
      return NavigationDecision.prevent;
    }

    // iTunes URL 처리
    if (_isItunesUrl(url)) {
      debugPrint('[CommerceWebView] iTunes URL detected');
      _launchAppToApp(url);
      return NavigationDecision.prevent;
    }

    // about:blank 허용
    if (url.startsWith('about:blank')) {
      return NavigationDecision.navigate;
    }

    // 비 HTTP 스킴 처리 (앱 스킴)
    if (!url.startsWith('http')) {
      debugPrint('[CommerceWebView] App scheme detected: $url');
      _launchAppToApp(url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _handleCallbackUrl(String url) {
    final uri = Uri.parse(url);
    Map<String, dynamic> data = {};

    uri.queryParameters.forEach((key, value) {
      if (key == 'metadata') {
        try {
          data['metadata'] = json.decode(value);
        } catch (e) {
          data[key] = value;
        }
      } else {
        data[key] = value;
      }
    });

    debugPrint('[CommerceWebView] Callback data: $data');

    // 콜백을 캡처 (WebView가 pop된 후에도 호출 가능하도록)
    final onDone = widget.onDone;
    final onCancel = widget.onCancel;
    final onError = widget.onError;
    final onIssued = widget.onIssued;
    final event = data['event'] as String? ?? '';

    // 먼저 WebView 닫기
    _removePaymentWindow();

    // 그 다음 콜백 호출
    switch (event) {
      case 'done':
        onDone?.call(data);
        break;
      case 'cancel':
        onCancel?.call(data);
        break;
      case 'error':
        onError?.call(data);
        break;
      case 'issued':
        onIssued?.call(data);
        break;
      default:
        // event가 없으면 receipt_id로 판단
        if (data['receipt_id'] != null) {
          onDone?.call(data);
        } else {
          onCancel?.call(data);
        }
    }

    _debounceCloseCallback();
  }

  void _onMessageReceived(JavaScriptMessage message) {
    debugPrint('[CommerceWebView] Message received: ${message.message}');

    if (message.message == 'close') {
      _debounceCloseCallback();
      _removePaymentWindow();
      return;
    }

    try {
      final data = json.decode(message.message) as Map<String, dynamic>;
      _parseCommerceEvent(data);
    } catch (e) {
      debugPrint('[CommerceWebView] JSON parse error: $e');
    }
  }

  void _parseCommerceEvent(Map<String, dynamic> data) {
    final event = data['event'] as String?;

    // 콜백을 캡처 (WebView가 pop된 후에도 호출 가능하도록)
    final onDone = widget.onDone;
    final onCancel = widget.onCancel;
    final onError = widget.onError;
    final onIssued = widget.onIssued;

    if (event == null) {
      // event가 없으면 done 이벤트로 처리 (receipt_id가 있는 경우)
      if (data['receipt_id'] != null) {
        _removePaymentWindow();  // 먼저 WebView 닫기
        onDone?.call(data);      // 그 다음 콜백 호출
        _debounceCloseCallback();
      }
      return;
    }

    switch (event) {
      case 'cancel':
        _removePaymentWindow();  // 먼저 WebView 닫기
        onCancel?.call(data);    // 그 다음 콜백 호출
        _debounceCloseCallback();
        break;
      case 'error':
        _removePaymentWindow();  // 먼저 WebView 닫기
        onError?.call(data);     // 그 다음 콜백 호출
        _debounceCloseCallback();
        break;
      case 'done':
        _removePaymentWindow();  // 먼저 WebView 닫기
        onDone?.call(data);      // 그 다음 콜백 호출
        _debounceCloseCallback();
        break;
      case 'issued':
        _removePaymentWindow();  // 먼저 WebView 닫기
        onIssued?.call(data);    // 그 다음 콜백 호출
        _debounceCloseCallback();
        break;
      case 'close':
        _controller.runJavaScript('BootpayCommerce.destroy();');
        _removePaymentWindow();
        _debounceCloseCallback();
        break;
      default:
        debugPrint('[CommerceWebView] Unknown event: $event');
    }
  }

  /// iOS의 debounceClose()와 동일 - onClose 콜백만 0.5초 후 호출
  void _debounceCloseCallback() {
    _debounceTimer?.cancel();
    // widget이 dispose되기 전에 콜백을 캡처
    final onClose = widget.onClose;
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      onClose?.call();
    });
  }

  /// iOS의 removePaymentWindow()와 동일 - 즉시 창 닫기
  void _removePaymentWindow() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _launchAppToApp(String urlString) async {
    // URL 스킴으로 앱 실행
    debugPrint('[CommerceWebView] Launching app: $urlString');

    // Platform별 URL 실행은 url_launcher 패키지를 사용해야 하지만,
    // 기존 bootpay_webview에서 처리하므로 여기서는 로그만 출력
  }

  bool _isItunesUrl(String url) {
    return RegExp(r'\/\/itunes\.apple\.com\/').hasMatch(url);
  }

  void _onCloseButtonPressed() {
    widget.onCancel?.call({
      'event': 'cancel',
      'code': -102,
      'action': 'BootpayCancel',
      'message': '사용자가 창을 닫았습니다.',
    });
    _debounceCloseCallback();
    _removePaymentWindow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: const Color.fromRGBO(0, 0, 0, 0.25),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            if (widget.showCloseButton)
              widget.closeButton != null
                  ? GestureDetector(
                      onTap: _onCloseButtonPressed,
                      child: widget.closeButton!,
                    )
                  : Positioned(
                      top: 5,
                      right: 5,
                      child: IconButton(
                        onPressed: _onCloseButtonPressed,
                        icon: const Icon(Icons.close,
                            size: 35, color: Colors.black54),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}
