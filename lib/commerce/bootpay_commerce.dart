import 'package:flutter/material.dart';
import '../model/commerce/commerce_payload.dart';
import 'commerce_webview.dart';

/// Commerce 결제 콜백 타입 정의
typedef CommerceDefaultCallback = void Function(Map<String, dynamic> data);
typedef CommerceCloseCallback = void Function();

/// Commerce 결제 요청을 위한 메인 클래스
/// Bootpay.requestPayment와 동일한 API 패턴을 사용합니다.
class BootpayCommerce {
  static final BootpayCommerce _instance = BootpayCommerce._internal();
  factory BootpayCommerce() => _instance;
  BootpayCommerce._internal();

  /// 환경 설정 (development, stage, production)
  String environmentMode = 'production';

  /// 현재 Payload
  CommercePayload? payload;

  /// Commerce CDN URL
  static const String COMMERCE_URL =
      'https://webview.bootpay.co.kr/commerce/1.0.5/index.html';

  /// 환경 모드 설정
  static void setEnvironmentMode(String mode) {
    _instance.environmentMode = mode;
  }

  /// Commerce 결제 요청 (requestCheckout)
  /// Bootpay.requestPayment와 동일한 API 패턴
  static void requestCheckout({
    required BuildContext context,
    required CommercePayload payload,
    bool showCloseButton = false,
    Widget? closeButton,
    CommerceDefaultCallback? onDone,
    CommerceDefaultCallback? onError,
    CommerceDefaultCallback? onCancel,
    CommerceCloseCallback? onClose,
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
          onDone: onDone,
          onError: onError,
          onCancel: onCancel,
          onClose: () {
            onClose?.call();
            _instance.payload = null;
          },
        ),
      ),
    );
  }

  /// 결제창 닫기 (BuildContext가 필요한 경우)
  static void dismiss(BuildContext context) {
    Navigator.of(context).pop();
  }
}
