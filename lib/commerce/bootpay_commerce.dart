import 'package:flutter/material.dart';
import '../model/commerce/commerce_payload.dart';
import 'commerce_webview.dart';

/// Commerce 결제 콜백 타입 정의
typedef CommerceDefaultCallback = void Function(Map<String, dynamic> data);
typedef CommerceCloseCallback = void Function();

/// Commerce 결제 요청을 위한 메인 클래스
/// iOS Swift SDK의 BootpayCommerce와 동일한 API를 제공합니다.
class BootpayCommerce {
  static final BootpayCommerce _instance = BootpayCommerce._internal();
  factory BootpayCommerce() => _instance;
  BootpayCommerce._internal();

  /// 환경 설정 (development, stage, production)
  String environmentMode = 'production';

  /// 현재 Payload
  CommercePayload? payload;

  /// 콜백 함수들
  CommerceDefaultCallback? onDone;
  CommerceDefaultCallback? onError;
  CommerceDefaultCallback? onCancel;
  CommerceCloseCallback? onClose;

  /// Commerce CDN URL
  static const String COMMERCE_URL =
      'https://webview.bootpay.co.kr/commerce/1.0.5/index.html';

  /// 환경 모드 설정
  static void setEnvironmentMode(String mode) {
    _instance.environmentMode = mode;
  }

  /// Commerce 결제 요청 (requestCheckout)
  /// [context] - BuildContext
  /// [payload] - CommercePayload 인스턴스
  /// [showCloseButton] - 닫기 버튼 표시 여부
  /// [closeButton] - 커스텀 닫기 버튼 위젯
  static BootpayCommerce requestCheckout({
    required BuildContext context,
    required CommercePayload payload,
    bool showCloseButton = false,
    Widget? closeButton,
  }) {
    _instance.payload = payload;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommerceWebViewPage(
          payload: payload,
          environmentMode: _instance.environmentMode,
          showCloseButton: showCloseButton,
          closeButton: closeButton,
          onDone: (data) {
            _instance.onDone?.call(data);
          },
          onError: (data) {
            _instance.onError?.call(data);
          },
          onCancel: (data) {
            _instance.onCancel?.call(data);
          },
          onClose: () {
            _instance.onClose?.call();
            _instance._clearCallbacks();
          },
        ),
      ),
    );

    return _instance;
  }

  /// 결제 완료 콜백 설정
  BootpayCommerce setOnDone(CommerceDefaultCallback callback) {
    onDone = callback;
    return this;
  }

  /// 결제 에러 콜백 설정
  BootpayCommerce setOnError(CommerceDefaultCallback callback) {
    onError = callback;
    return this;
  }

  /// 결제 취소 콜백 설정
  BootpayCommerce setOnCancel(CommerceDefaultCallback callback) {
    onCancel = callback;
    return this;
  }

  /// 결제창 닫힘 콜백 설정
  BootpayCommerce setOnClose(CommerceCloseCallback callback) {
    onClose = callback;
    return this;
  }

  /// 콜백 초기화
  void _clearCallbacks() {
    onDone = null;
    onError = null;
    onCancel = null;
    onClose = null;
    payload = null;
  }

  /// 결제창 닫기 (BuildContext가 필요한 경우)
  static void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }
}
