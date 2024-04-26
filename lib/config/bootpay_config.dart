
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
}

class BootpayConfig {
  static int ENV = ENV_DEBUG; //-1: debug, -2: stage, 0보다 크면 실서버
  // static int ENV = ENV_PROMOTION; //-1: debug, -2: stage, 0보다 크면 실서버
  static bool IS_FORCE_WEB = false; // 강제로 웹시나리오로 결제를 태울지 말지

  // static const int ENV = ENV_STAGE; //-1: debug, -2: stage, 0보다 크면 실서버

  static const int ENV_DEBUG = -1;
  static const int ENV_STAGE = -2;
  static const int ENV_PROMOTION = 1;

  static const String VERSION = "5.0.0";


  static bool DISPLAY_WITH_HYBRID_COMPOSITION = false;
  // static bool DISPLAY_TABLET_FULLSCREEN = false; 결제요청시 padding 값으로 대체됨
}