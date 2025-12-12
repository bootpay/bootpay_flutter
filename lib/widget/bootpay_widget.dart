import 'package:flutter/material.dart';

import '../bootpay.dart';
import '../model/payload.dart';
import '../model/widget/widget_data.dart';
import 'bootpay_widget_payment_page.dart';
import 'bootpay_widget_webview.dart' show BootpayWidgetWebView, BootpayWidgetWebViewController;

/// 위젯 생성 콜백 (deprecated - 기존 호환성용)
typedef BootpayWidgetControllerCallback = void Function(BootpayWidgetController controller);

/// 부트페이 위젯 (앱 화면 내에 삽입 가능한 결제 컴포넌트)
/// 네이티브 SDK (iOS/Android)와 동일한 구조로 분리된 위젯 전용 웹뷰 사용
class BootpayWidget extends StatefulWidget {
  final Payload? payload;
  final BootpayWidgetControllerCallback? onWidgetCreated;
  final BootpayWidgetController controller;

  BootpayWidget({
    Key? key,
    this.payload,
    this.onWidgetCreated,
    required this.controller,
  }) : super(key: key);

  @override
  State<BootpayWidget> createState() => _BootpayWidgetState();
}

class _BootpayWidgetState extends State<BootpayWidget> {
  late BootpayWidgetWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = BootpayWidgetWebViewController();
    _setupController();

    // 기존 호환성: onWidgetCreated 콜백 호출
    widget.onWidgetCreated?.call(widget.controller);
  }

  void _setupController() {
    // 컨트롤러에 웹뷰 컨트롤러 연결
    widget.controller._setWebViewController(_webViewController);

    // 콜백 연결
    _webViewController.onReady = widget.controller._handleReady;
    _webViewController.onResize = widget.controller._handleResize;
    _webViewController.onChangePayment = widget.controller._handleChangePayment;
    _webViewController.onChangeAgreeTerm = widget.controller._handleChangeAgreeTerm;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payload == null) {
      return const SizedBox.shrink();
    }

    return BootpayWidgetWebView(
      payload: widget.payload!,
      controller: _webViewController,
    );
  }
}

/// 위젯 컨트롤러 (네이티브 SDK와 동일한 구조)
class BootpayWidgetController {
  BootpayWidgetWebViewController? _webViewController;

  // 위젯 이벤트 콜백
  BootpayCloseCallback? onWidgetReady;
  WidgetResizeCallback? onWidgetResize;
  WidgetChangePaymentCallback? onWidgetChangePayment;
  WidgetChangePaymentCallback? onWidgetChangeAgreeTerm;

  // 위젯 상태
  double _widgetHeight = 300.0;
  double get widgetHeight => _widgetHeight;

  WidgetData? _widgetData;
  WidgetData? get widgetData => _widgetData;

  void _setWebViewController(BootpayWidgetWebViewController controller) {
    _webViewController = controller;
  }

  void _handleReady() {
    onWidgetReady?.call();
  }

  void _handleResize(double height) {
    if (_widgetHeight != height) {
      _widgetHeight = height;
      onWidgetResize?.call(height);
    }
  }

  void _handleChangePayment(WidgetData? data) {
    _widgetData = data;
    onWidgetChangePayment?.call(data);
  }

  void _handleChangeAgreeTerm(WidgetData? data) {
    _widgetData = data;
    onWidgetChangeAgreeTerm?.call(data);
  }

  /// 위젯 업데이트
  /// [payload] 업데이트할 페이로드
  /// [refresh] true일 경우 위젯 전체 새로고침
  void update({Payload? payload, bool? refresh}) {
    if (payload != null) {
      _webViewController?.update(payload: payload, refresh: refresh ?? false);
    }
  }

  /// 위젯 재로드 (에러/취소 후 재시도 시 사용)
  void reloadWidget() {
    _webViewController?.reloadWidget();
  }

  /// 결제 요청 (전체화면 결제 페이지로 이동)
  void requestPayment({
    Payload? payload,
    BootpayDefaultCallback? onError,
    BootpayDefaultCallback? onCancel,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onIssued,
    BootpayConfirmCallback? onConfirm,
    BootpayAsyncConfirmCallback? onConfirmAsync,
    BootpayDefaultCallback? onDone,
    required BuildContext context,
  }) {
    if (payload == null) {
      debugPrint('[BootpayWidgetController] requestPayment - payload is null');
      return;
    }

    // iOS Swift SDK의 expandToFullscreen과 동일하게 전체화면 결제 페이지로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BootpayWidgetPaymentPage(
          payload: payload,
          onCancel: onCancel,
          onError: onError,
          onClose: onClose,
          onIssued: onIssued,
          onConfirm: onConfirm,
          onConfirmAsync: onConfirmAsync,
          onDone: onDone,
        ),
      ),
    );
  }

  /// 결제 확인 (confirm 이벤트에서 호출)
  void transactionConfirm() {
    _webViewController?.transactionConfirm();
  }
}
