import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../bootpay.dart';
import '../model/payload.dart';
import '../model/widget/widget_data.dart';
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

  // GlobalKey로 웹뷰 상태 유지
  final GlobalKey _webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _webViewController = BootpayWidgetWebViewController();
    _setupController();

    // 기존 호환성: onWidgetCreated 콜백 호출
    widget.onWidgetCreated?.call(widget.controller);
  }

  void _setupController() {
    // 컨트롤러에 웹뷰 컨트롤러 및 상태 연결
    widget.controller._setWebViewController(_webViewController);
    widget.controller._setWidgetState(this);
    widget.controller._webViewKey = _webViewKey;

    // 콜백 연결
    _webViewController.onReady = widget.controller._handleReady;
    _webViewController.onResize = widget.controller._handleResize;
    _webViewController.onChangePayment = widget.controller._handleChangePayment;
    _webViewController.onChangeAgreeTerm = widget.controller._handleChangeAgreeTerm;
  }

  void _refreshState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payload == null) {
      return const SizedBox.shrink();
    }

    // GlobalKey를 사용한 웹뷰 (상태 유지)
    final webView = KeyedSubtree(
      key: _webViewKey,
      child: BootpayWidgetWebView(
        payload: widget.payload!,
        controller: _webViewController,
      ),
    );

    return webView;
  }
}

/// 위젯 컨트롤러 (네이티브 SDK와 동일한 구조)
class BootpayWidgetController {
  BootpayWidgetWebViewController? _webViewController;
  _BootpayWidgetState? _widgetState;
  GlobalKey? _webViewKey;

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

  // 전체화면 관련
  OverlayEntry? _overlayEntry;
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  // 결제 콜백 (requestPayment에서 설정)
  BootpayDefaultCallback? _onError;
  BootpayDefaultCallback? _onCancel;
  BootpayCloseCallback? _onClose;
  BootpayDefaultCallback? _onIssued;
  BootpayConfirmCallback? _onConfirm;
  BootpayAsyncConfirmCallback? _onConfirmAsync;
  BootpayDefaultCallback? _onDone;

  void _setWebViewController(BootpayWidgetWebViewController controller) {
    _webViewController = controller;
  }

  void _setWidgetState(_BootpayWidgetState state) {
    _widgetState = state;
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

  /// 결제 요청 (iOS Swift SDK와 동일하게 기존 웹뷰를 전체화면으로 확장)
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

    debugPrint('[BootpayWidgetController] requestPayment called');
    debugPrint('[BootpayWidgetController] Platform: ${kIsWeb ? "Web" : Platform.operatingSystem}');

    // 콜백 저장
    _onError = onError;
    _onCancel = onCancel;
    _onClose = onClose;
    _onIssued = onIssued;
    _onConfirm = onConfirm;
    _onConfirmAsync = onConfirmAsync;
    _onDone = onDone;

    // 웹뷰 컨트롤러에 결제 콜백 설정
    _setupPaymentCallbacks();

    // iOS Swift SDK와 동일하게 전체화면으로 확장
    _expandToFullscreen(context);

    // 약간의 딜레이 후 결제 요청 (iOS Swift SDK와 동일하게 0.4초)
    Future.delayed(Duration(milliseconds: 400), () {
      debugPrint('[BootpayWidgetController] Calling requestPayment on webViewController');
      _webViewController?.requestPayment(payload: payload);
    });
  }

  /// 결제 콜백 설정
  void _setupPaymentCallbacks() {
    debugPrint('[BootpayWidgetController] Setting up payment callbacks');

    _webViewController?.onError = (data) {
      debugPrint('[BootpayWidgetController] onError: $data');
      _onError?.call(data);
      // 에러 후 축소 및 위젯 재로드
      _collapseAndReload();
    };

    _webViewController?.onCancel = (data) {
      debugPrint('[BootpayWidgetController] onCancel: $data');
      _onCancel?.call(data);
      // 취소 후 축소 및 위젯 재로드
      _collapseAndReload();
    };

    _webViewController?.onClose = () {
      debugPrint('[BootpayWidgetController] onClose');
      _onClose?.call();
      _collapseToOriginal();
    };

    _webViewController?.onIssued = (data) {
      debugPrint('[BootpayWidgetController] onIssued: $data');
      _onIssued?.call(data);
    };

    _webViewController?.onDone = (data) {
      debugPrint('[BootpayWidgetController] onDone: $data');
      _onDone?.call(data);
      // 완료 후 축소
      _collapseToOriginal();
    };

    // confirm 콜백 처리
    if (_onConfirmAsync != null) {
      _webViewController?.onConfirm = (data) {
        debugPrint('[BootpayWidgetController] onConfirm (async): $data');
        _onConfirmAsync!(data).then((result) {
          debugPrint('[BootpayWidgetController] Async confirm result: $result');
          if (result) {
            _webViewController?.transactionConfirm();
          }
        });
        return false;
      };
    } else if (_onConfirm != null) {
      _webViewController?.onConfirm = (data) {
        debugPrint('[BootpayWidgetController] onConfirm: $data');
        return _onConfirm!(data);
      };
    }
  }

  /// 전체화면으로 확장 (iOS Swift SDK의 expandToFullscreen과 동일)
  void _expandToFullscreen(BuildContext context) {
    if (_isExpanded) return;

    debugPrint('[BootpayWidgetController] _expandToFullscreen');

    _isExpanded = true;

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _FullscreenPaymentOverlay(
        webViewController: _webViewController,
        onClose: () {
          debugPrint('[BootpayWidgetController] Overlay close requested');
          _onClose?.call();
          _collapseToOriginal();
        },
      ),
    );

    overlay.insert(_overlayEntry!);
    debugPrint('[BootpayWidgetController] Overlay inserted');
  }

  /// 원래 크기로 축소 (iOS Swift SDK의 collapseToOriginal과 동일)
  void _collapseToOriginal() {
    if (!_isExpanded) return;

    debugPrint('[BootpayWidgetController] _collapseToOriginal');

    _isExpanded = false;
    _overlayEntry?.remove();
    _overlayEntry = null;

    debugPrint('[BootpayWidgetController] Overlay removed');
  }

  /// 축소 후 위젯 재로드 (iOS Swift SDK의 collapseAndReload와 동일)
  void _collapseAndReload() {
    debugPrint('[BootpayWidgetController] _collapseAndReload');
    _collapseToOriginal();

    // 약간의 딜레이 후 위젯 재로드
    Future.delayed(Duration(milliseconds: 300), () {
      reloadWidget();
    });
  }

  /// 결제 확인 (confirm 이벤트에서 호출)
  void transactionConfirm() {
    _webViewController?.transactionConfirm();
  }

  /// 결제 요청 (전체화면 전환 없이 기존 웹뷰에서 직접 실행)
  /// iOS Swift SDK와 동일하게 기존 웹뷰에서 결제 진행
  void requestPaymentDirect({
    Payload? payload,
    BootpayDefaultCallback? onError,
    BootpayDefaultCallback? onCancel,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onIssued,
    BootpayConfirmCallback? onConfirm,
    BootpayAsyncConfirmCallback? onConfirmAsync,
    BootpayDefaultCallback? onDone,
  }) {
    if (payload == null) {
      debugPrint('[BootpayWidgetController] requestPaymentDirect - payload is null');
      return;
    }

    debugPrint('[BootpayWidgetController] requestPaymentDirect called');

    // 콜백 저장
    _onError = onError;
    _onCancel = onCancel;
    _onClose = onClose;
    _onIssued = onIssued;
    _onConfirm = onConfirm;
    _onConfirmAsync = onConfirmAsync;
    _onDone = onDone;

    // 웹뷰 컨트롤러에 결제 콜백 설정
    _setupPaymentCallbacks();

    // 기존 웹뷰에서 직접 결제 요청
    _webViewController?.requestPayment(payload: payload);
  }
}

/// 전체화면 결제 오버레이 (결제 진행 중 표시)
/// 실제 결제는 기존 웹뷰에서 JavaScript로 진행됨
class _FullscreenPaymentOverlay extends StatefulWidget {
  final BootpayWidgetWebViewController? webViewController;
  final VoidCallback onClose;

  const _FullscreenPaymentOverlay({
    required this.webViewController,
    required this.onClose,
  });

  @override
  State<_FullscreenPaymentOverlay> createState() => _FullscreenPaymentOverlayState();
}

class _FullscreenPaymentOverlayState extends State<_FullscreenPaymentOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('[_FullscreenPaymentOverlay] initState');

    _animationController = AnimationController(
      duration: Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            children: [
              // 반투명 배경
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {}, // 배경 탭 무시
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * _fadeAnimation.value),
                  ),
                ),
              ),
              // 결제 진행 컨테이너 (SafeArea 적용)
              Positioned.fill(
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          // 상단 헤더
                          Container(
                            height: 50,
                            color: Colors.white,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    '결제',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  onPressed: () {
                                    debugPrint('[_FullscreenPaymentOverlay] Close button pressed');
                                    _handleClose();
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(height: 1, color: Colors.grey[300]),
                          // 결제 진행 표시
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    '결제를 진행하고 있습니다',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '잠시만 기다려주세요...',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
