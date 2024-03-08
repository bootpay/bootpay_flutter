
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
}

class BootpayConfig {
  static int ENV = ENV_PROMOTION; //-1: debug, -2: stage, 0보다 크면 실서버
  // static const int ENV = ENV_STAGE; //-1: debug, -2: stage, 0보다 크면 실서버

  static const int ENV_DEBUG = -1;
  static const int ENV_STAGE = -2;
  static const int ENV_PROMOTION = 1;

  static const String VERSION = "4.8.5";

}