import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bootpay.dart';
import '../model/payload.dart';
import 'bootpay_widget_webview.dart';

/// 위젯 결제 전체화면 페이지
/// iOS Swift SDK의 expandToFullscreen과 동일한 역할
class BootpayWidgetPaymentPage extends StatefulWidget {
  final Payload payload;
  final BootpayDefaultCallback? onCancel;
  final BootpayDefaultCallback? onError;
  final BootpayCloseCallback? onClose;
  final BootpayDefaultCallback? onIssued;
  final BootpayConfirmCallback? onConfirm;
  final BootpayAsyncConfirmCallback? onConfirmAsync;
  final BootpayDefaultCallback? onDone;

  const BootpayWidgetPaymentPage({
    Key? key,
    required this.payload,
    this.onCancel,
    this.onError,
    this.onClose,
    this.onIssued,
    this.onConfirm,
    this.onConfirmAsync,
    this.onDone,
  }) : super(key: key);

  @override
  State<BootpayWidgetPaymentPage> createState() => _BootpayWidgetPaymentPageState();
}

class _BootpayWidgetPaymentPageState extends State<BootpayWidgetPaymentPage> {
  DateTime? currentBackPressTime = DateTime.now();

  late BootpayWidgetWebViewController _webViewController;
  bool _isPaymentRequested = false;
  bool _isCloseHandled = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _webViewController = BootpayWidgetWebViewController();
    _setupCallbacks();
  }

  void _setupCallbacks() {
    // 위젯 준비 완료 시 결제 요청
    _webViewController.onReady = () {
      debugPrint('[WidgetPaymentPage] Widget Ready - requesting payment');
      if (!_isPaymentRequested) {
        _isPaymentRequested = true;
        // 위젯 렌더링 후 약간의 딜레이를 주고 결제 요청 (iOS와 동일하게 0.4초)
        Future.delayed(Duration(milliseconds: 400), () {
          _webViewController.requestPayment(payload: widget.payload);
        });
      }
    };

    // 결제 콜백 설정
    _webViewController.onCancel = widget.onCancel;
    _webViewController.onError = widget.onError;
    _webViewController.onIssued = widget.onIssued;
    _webViewController.onDone = widget.onDone;
    _webViewController.onClose = widget.onClose;

    // confirm 콜백 처리
    if (widget.onConfirmAsync != null) {
      _webViewController.onConfirm = (data) {
        widget.onConfirmAsync!(data).then((result) {
          if (result) {
            _webViewController.transactionConfirm();
          }
        });
        return false;
      };
    } else if (widget.onConfirm != null) {
      _webViewController.onConfirm = widget.onConfirm;
    }
  }

  void _handleClose() {
    if (_isCloseHandled) return;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {
      if (!_isCloseHandled) {
        _isCloseHandled = true;
        widget.onClose?.call();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _handleClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isAndroid) {
      return WillPopScope(
        child: _buildScaffold(context),
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "'뒤로' 버튼을 한번 더 눌러주세요.");
            return Future.value(false);
          }
          return Future.value(true);
        },
      );
    } else {
      return _buildScaffold(context);
    }
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BootpayWidgetWebView(
          payload: widget.payload,
          controller: _webViewController,
        ),
      ),
    );
  }
}
