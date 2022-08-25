
import 'package:flutter/foundation.dart';

void BootpayPrint(Object? object) {
  if(kReleaseMode) return;
  print(object);
}

class BootpayConfig {
  static const bool DEBUG = false;
  static const String VERSION = "4.2.7";
}