
import 'package:flutter/foundation.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
  print(object);
}

class BootpayConfig {
  static const int ENV = ENV_PROMOTION; //-1: debug, -2: stage, 0보다 크면 실서버
  // static const int ENV = ENV_STAGE; //-1: debug, -2: stage, 0보다 크면 실서버

  static const int ENV_DEBUG = -1;
  static const int ENV_STAGE = -2;
  static const int ENV_PROMOTION = 1;

  static const String VERSION = "4.6.8";
}