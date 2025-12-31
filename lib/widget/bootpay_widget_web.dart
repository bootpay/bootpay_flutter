import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../bootpay.dart';
import '../model/extra.dart';
import '../model/payload.dart';
import '../model/widget/widget_data.dart';

/// 위젯 생성 콜백 (deprecated - 기존 호환성용)
typedef BootpayWidgetControllerCallback = void Function(BootpayWidgetController controller);

// JS interop for BootpayWidget
@JS('BootpayWidget')
external JSObject? get _bootpayWidget;

@JS('BootpayWidget.render')
external void _jsWidgetRender(String selector, JSObject payload);

@JS('BootpayWidget.update')
external void _jsWidgetUpdate(JSObject payload, bool refresh);

@JS('BootpayWidget.requestPayment')
external JSPromise _jsWidgetRequestPayment(JSObject payload);

@JS('JSON.parse')
external JSObject _jsonParse(String json);

@JS('JSON.stringify')
external String _stringify(JSObject obj);

// JS event listeners
@JS('document.addEventListener')
external void _jsAddEventListener(String event, JSFunction callback);

@JS('document.removeEventListener')
external void _jsRemoveEventListener(String event, JSFunction callback);

@JS('Bootpay.confirm')
external JSPromise _jsBootpayConfirm();

@JS('console.log')
external void _jsConsoleLog(String message);

// 위젯용 redirect 이벤트 핸들러 등록
@JS('BootpayWidgetRedirectHandler')
external set _bootpayWidgetRedirectHandler(JSFunction? f);

int _widgetIdCounter = 0;

/// 부트페이 위젯 (Web용 - JS SDK 연동)
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
  bool _isInitialized = false;
  bool _isWidgetReady = false;
  String? _errorMessage;
  late String _containerId;
  web.HTMLDivElement? _containerElement;
  final GlobalKey _containerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _containerId = 'bootpay-widget-${_widgetIdCounter++}';
    _initWidget();

    // 기존 호환성: onWidgetCreated 콜백 호출
    widget.onWidgetCreated?.call(widget.controller);
  }

  void _initWidget() {
    // 컨트롤러에 상태 연결
    widget.controller._setWidgetState(this);
    widget.controller._containerId = _containerId;

    // JS SDK 로드 확인 및 이벤트 리스너 등록
    _setupJSEventListeners();

    setState(() {
      _isInitialized = true;
    });
  }

  void _setupJSEventListeners() {
    // widget_ready 이벤트
    widget.controller._jsReadyCallback = ((JSAny event) {
      debugPrint('[BootpayWidgetWeb] widget_ready event received');
      _isWidgetReady = true;
      widget.controller._handleReady();
    }).toJS;

    // widget_resize 이벤트
    widget.controller._jsResizeCallback = ((JSAny event) {
      try {
        final eventObj = event as JSObject;
        final detail = eventObj.getProperty('detail'.toJS);
        if (detail != null && detail.isA<JSObject>()) {
          final detailObj = detail as JSObject;
          final heightVal = detailObj.getProperty('height'.toJS);
          double height = 300.0;
          if (heightVal != null && heightVal.isA<JSNumber>()) {
            height = (heightVal as JSNumber).toDartDouble;
          }
          debugPrint('[BootpayWidgetWeb] widget_resize: $height');
          widget.controller._handleResize(height);
        }
      } catch (e) {
        debugPrint('[BootpayWidgetWeb] Error parsing resize event: $e');
      }
    }).toJS;

    // widget_change_payment 이벤트
    widget.controller._jsChangePaymentCallback = ((JSAny event) {
      try {
        final eventObj = event as JSObject;
        final detail = eventObj.getProperty('detail'.toJS);
        if (detail != null && detail.isA<JSObject>()) {
          final jsonStr = _stringify(detail as JSObject);
          final data = WidgetData.fromJson(jsonDecode(jsonStr));
          debugPrint('[BootpayWidgetWeb] widget_change_payment');
          widget.controller._handleChangePayment(data);
        }
      } catch (e) {
        debugPrint('[BootpayWidgetWeb] Error parsing change_payment event: $e');
      }
    }).toJS;

    // widget_change_terms 이벤트
    widget.controller._jsChangeTermsCallback = ((JSAny event) {
      try {
        final eventObj = event as JSObject;
        final detail = eventObj.getProperty('detail'.toJS);
        if (detail != null && detail.isA<JSObject>()) {
          final jsonStr = _stringify(detail as JSObject);
          final data = WidgetData.fromJson(jsonDecode(jsonStr));
          debugPrint('[BootpayWidgetWeb] widget_change_agree_term');
          widget.controller._handleChangeAgreeTerm(data);
        }
      } catch (e) {
        debugPrint('[BootpayWidgetWeb] Error parsing change_terms event: $e');
      }
    }).toJS;

    // 이벤트 리스너 등록
    _jsAddEventListener('bootpay-widget-ready', widget.controller._jsReadyCallback!);
    _jsAddEventListener('bootpay-widget-resize', widget.controller._jsResizeCallback!);
    _jsAddEventListener('bootpay-widget-change-payment', widget.controller._jsChangePaymentCallback!);
    _jsAddEventListener('bootpay-widget-change-terms', widget.controller._jsChangeTermsCallback!);
  }

  void _createAndInsertContainer() {
    // 기존 container 제거
    final existing = web.document.getElementById(_containerId);
    if (existing != null) {
      existing.remove();
    }

    // 새 container 생성
    _containerElement = web.document.createElement('div') as web.HTMLDivElement;
    _containerElement!.id = _containerId;
    _containerElement!.style.width = '100%';
    _containerElement!.style.minHeight = '300px';
    _containerElement!.style.position = 'absolute';
    _containerElement!.style.left = '0';
    _containerElement!.style.top = '0';
    _containerElement!.style.zIndex = '9999';
    _containerElement!.style.pointerEvents = 'auto';
    _containerElement!.style.backgroundColor = 'white';

    // body에 추가
    web.document.body?.appendChild(_containerElement!);
    debugPrint('[BootpayWidgetWeb] Container created and inserted: $_containerId');
  }

  void _updateContainerPosition() {
    if (_containerElement == null || _containerKey.currentContext == null) return;

    final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _containerElement!.style.position = 'absolute';
    _containerElement!.style.left = '${position.dx}px';
    _containerElement!.style.top = '${position.dy}px';
    _containerElement!.style.width = '${size.width}px';
    _containerElement!.style.height = '${size.height}px';
    _containerElement!.style.minHeight = '300px';

    debugPrint('[BootpayWidgetWeb] Container position updated: ${position.dx}, ${position.dy}, ${size.width}x${size.height}');
  }

  @override
  void dispose() {
    // 이벤트 리스너 해제
    if (widget.controller._jsReadyCallback != null) {
      _jsRemoveEventListener('bootpay-widget-ready', widget.controller._jsReadyCallback!);
    }
    if (widget.controller._jsResizeCallback != null) {
      _jsRemoveEventListener('bootpay-widget-resize', widget.controller._jsResizeCallback!);
    }
    if (widget.controller._jsChangePaymentCallback != null) {
      _jsRemoveEventListener('bootpay-widget-change-payment', widget.controller._jsChangePaymentCallback!);
    }
    if (widget.controller._jsChangeTermsCallback != null) {
      _jsRemoveEventListener('bootpay-widget-change-terms', widget.controller._jsChangeTermsCallback!);
    }

    // Container 제거
    _containerElement?.remove();
    _containerElement = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payload == null) {
      return const SizedBox.shrink();
    }

    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    // 레이아웃 후 container 위치 업데이트 및 렌더링
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_containerElement == null) {
        _createAndInsertContainer();
      }
      _updateContainerPosition();

      if (!_isWidgetReady) {
        _renderJSWidget();
      }
    });

    return Container(
      key: _containerKey,
      height: widget.controller.widgetHeight > 0 ? widget.controller.widgetHeight : 300,
      color: Colors.transparent,
    );
  }

  void _renderJSWidget() {
    if (_bootpayWidget == null) {
      setState(() {
        _errorMessage = 'BootpayWidget JS SDK가 로드되지 않았습니다. index.html에 bootpay-widget JS를 추가해주세요.';
      });
      debugPrint('[BootpayWidgetWeb] Error: BootpayWidget JS SDK not loaded');
      return;
    }

    try {
      final payloadJson = jsonEncode(widget.payload!.toJson());
      debugPrint('[BootpayWidgetWeb] Payload JSON: $payloadJson');
      debugPrint('[BootpayWidgetWeb] Selector: #$_containerId');

      // JS 콘솔에도 로그 출력
      _jsConsoleLog('[BootpayWidgetWeb] Calling BootpayWidget.render');
      _jsConsoleLog('[BootpayWidgetWeb] Selector: #$_containerId');
      _jsConsoleLog('[BootpayWidgetWeb] Payload: $payloadJson');

      final jsPayload = _jsonParse(payloadJson);
      _jsWidgetRender('#$_containerId', jsPayload);

      _jsConsoleLog('[BootpayWidgetWeb] render() called');
      debugPrint('[BootpayWidgetWeb] Widget rendered to #$_containerId');
    } catch (e) {
      debugPrint('[BootpayWidgetWeb] Error rendering widget: $e');
      _jsConsoleLog('[BootpayWidgetWeb] Error: $e');
      setState(() {
        _errorMessage = 'Widget 렌더링 중 오류가 발생했습니다: $e';
      });
    }
  }
}

/// 위젯 컨트롤러 (Web용)
class BootpayWidgetController {
  _BootpayWidgetState? _widgetState;
  String? _containerId;

  // JS 콜백 저장 (해제용)
  JSFunction? _jsReadyCallback;
  JSFunction? _jsResizeCallback;
  JSFunction? _jsChangePaymentCallback;
  JSFunction? _jsChangeTermsCallback;

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

  // 결제 콜백 (requestPayment에서 설정)
  BootpayDefaultCallback? _onError;
  BootpayDefaultCallback? _onCancel;
  BootpayCloseCallback? _onClose;
  BootpayDefaultCallback? _onIssued;
  BootpayConfirmCallback? _onConfirm;
  BootpayAsyncConfirmCallback? _onConfirmAsync;
  BootpayDefaultCallback? _onDone;

  // 전체화면 관련 (Web에서는 미사용, 호환성 유지)
  bool _isExpanded = false;
  bool get isExpanded => _isExpanded;

  void _setWidgetState(_BootpayWidgetState state) {
    _widgetState = state;
  }

  void _handleReady() {
    onWidgetReady?.call();
  }

  /// Widget 컨테이너 숨기기 (결제 완료 후 호출)
  void hideContainer() {
    debugPrint('[BootpayWidgetController] hideContainer called');
    _widgetState?._containerElement?.remove();
    _widgetState?._containerElement = null;
  }

  /// Widget 컨테이너 보이기
  void showContainer() {
    _widgetState?._containerElement?.style.display = 'block';
  }

  void _handleResize(double height) {
    if (height > 0 && _widgetHeight != height) {
      _widgetHeight = height;
      onWidgetResize?.call(height);
      _widgetState?.setState(() {});
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
  void update({Payload? payload, bool? refresh}) {
    if (payload != null && _bootpayWidget != null) {
      try {
        final payloadJson = jsonEncode(payload.toJson());
        final jsPayload = _jsonParse(payloadJson);
        _jsWidgetUpdate(jsPayload, refresh ?? false);
        debugPrint('[BootpayWidgetController] Widget updated');
      } catch (e) {
        debugPrint('[BootpayWidgetController] Error updating widget: $e');
      }
    }
  }

  /// 위젯 재로드
  void reloadWidget() {
    _widgetState?.setState(() {});
  }

  /// 결제 요청 (Web에서는 JS SDK 직접 호출)
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

    debugPrint('[BootpayWidgetController] requestPayment called (Web)');

    // 콜백 저장
    _onError = onError;
    _onCancel = onCancel;
    _onClose = onClose;
    _onIssued = onIssued;
    _onConfirm = onConfirm;
    _onConfirmAsync = onConfirmAsync;
    _onDone = onDone;

    _executeRequestPayment(payload);
  }

  void _executeRequestPayment(Payload payload) {
    if (_bootpayWidget == null) {
      debugPrint('[BootpayWidgetController] BootpayWidget JS not loaded');
      _onError?.call('{"error": "BootpayWidget JS SDK not loaded"}');
      return;
    }

    // Flutter Web에서는 useBootpayInappSdk = false로 설정하여 Promise 방식 사용
    if (payload.extra == null) {
      payload.extra = Extra();
    }


    try {
      final payloadJson = jsonEncode(payload.toJson());
      final jsPayload = _jsonParse(payloadJson);

      _jsWidgetRequestPayment(jsPayload).toDart.then((result) {
        final resultObj = result as JSObject;
        final eventVal = resultObj.getProperty('event'.toJS);
        String? event;
        if (eventVal != null && eventVal.isA<JSString>()) {
          event = (eventVal as JSString).toDart;
        }
        final jsonStr = _stringify(resultObj);

        debugPrint('[BootpayWidgetController] requestPayment result: $event');

        if (event == 'confirm') {
          if (_onConfirmAsync != null) {
            _onConfirmAsync!(jsonStr).then((shouldConfirm) {
              if (shouldConfirm) {
                transactionConfirm();
              }
            });
          } else if (_onConfirm != null) {
            final shouldConfirm = _onConfirm!(jsonStr);
            if (shouldConfirm) {
              transactionConfirm();
            }
          }
        } else if (event == 'issued') {
          _onIssued?.call(jsonStr);
        } else if (event == 'done') {
          hideContainer(); // 결제 완료 후 컨테이너 숨기기
          _onDone?.call(jsonStr);
        }
      }).catchError((error) {
        final errorObj = error as JSObject;
        final eventVal = errorObj.getProperty('event'.toJS);
        String? event;
        if (eventVal != null && eventVal.isA<JSString>()) {
          event = (eventVal as JSString).toDart;
        }
        final jsonStr = _stringify(errorObj);

        debugPrint('[BootpayWidgetController] requestPayment error: $event');

        hideContainer(); // 에러/취소 시에도 컨테이너 숨기기

        if (event == 'error') {
          _onError?.call(jsonStr);
        } else if (event == 'cancel') {
          _onCancel?.call(jsonStr);
        }
      });
    } catch (e) {
      debugPrint('[BootpayWidgetController] Error executing requestPayment: $e');
      _onError?.call('{"error": "$e"}');
    }
  }

  /// 결제 확인
  void transactionConfirm() {
    try {
      _jsBootpayConfirm().toDart.then((result) {
        final resultObj = result as JSObject;
        final eventVal = resultObj.getProperty('event'.toJS);
        String? event;
        if (eventVal != null && eventVal.isA<JSString>()) {
          event = (eventVal as JSString).toDart;
        }
        final jsonStr = _stringify(resultObj);

        if (event == 'issued') {
          _onIssued?.call(jsonStr);
        } else if (event == 'done') {
          hideContainer(); // 결제 완료 후 컨테이너 숨기기
          _onDone?.call(jsonStr);
        }
      }).catchError((error) {
        final errorObj = error as JSObject;
        final eventVal = errorObj.getProperty('event'.toJS);
        String? event;
        if (eventVal != null && eventVal.isA<JSString>()) {
          event = (eventVal as JSString).toDart;
        }
        final jsonStr = _stringify(errorObj);

        hideContainer(); // 에러/취소 시에도 컨테이너 숨기기

        if (event == 'error') {
          _onError?.call(jsonStr);
        } else if (event == 'cancel') {
          _onCancel?.call(jsonStr);
        }
      });
    } catch (e) {
      debugPrint('[BootpayWidgetController] Error confirming transaction: $e');
    }
  }

  /// 결제 요청 (Direct - 호환성 유지)
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

    // 콜백 저장
    _onError = onError;
    _onCancel = onCancel;
    _onClose = onClose;
    _onIssued = onIssued;
    _onConfirm = onConfirm;
    _onConfirmAsync = onConfirmAsync;
    _onDone = onDone;

    _executeRequestPayment(payload);
  }
}
