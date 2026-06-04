
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
}

class BootpayConfig {
  /// WebView 결제 환경. ENV_DEBUG(-1) | ENV_STAGE(-2) | ENV_PROMOTION(1=production).
  /// 기본값은 항상 ENV_PROMOTION. 배포 시 절대 변경하지 말 것.
  /// 로컬 테스트는 `Bootpay.setEnvironmentMode('development')` 등을 런타임에 호출.
  static int ENV = ENV_PROMOTION;
  static bool IS_FORCE_WEB = false; // 강제로 웹시나리오로 결제를 태울지 말지

  static const int ENV_DEBUG = -1;
  static const int ENV_STAGE = -2;
  static const int ENV_PROMOTION = 1;

  static const String VERSION = "5.3.0";


  static bool DISPLAY_WITH_HYBRID_COMPOSITION = false;
  // static bool DISPLAY_TABLET_FULLSCREEN = false; 결제요청시 padding 값으로 대체됨
}