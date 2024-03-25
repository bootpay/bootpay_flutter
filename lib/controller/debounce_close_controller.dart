//package controller;//package controller;

import 'dart:async';

import 'package:get/get.dart';

import '../bootpay.dart';
import '../config/bootpay_config.dart';

class DebounceCloseController extends GetxController {
  Timer? _debounce;
  bool isFireCloseEvent = true;
  bool isDebounceShow = false;

  void bootpayClose(BootpayCloseCallback? onClose) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () {

      if(isDebounceShow == false) return;
      if (onClose != null) {
        onClose();
      }
      isDebounceShow = false;
      isFireCloseEvent = true;
      // BootpayPrint("DebounceCloseController bootpayClose : ${isFireCloseEvent}");
      // do something with query
    });
  }
}
