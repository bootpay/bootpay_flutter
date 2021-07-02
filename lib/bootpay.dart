
import 'shims/bootpay_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bootpay_api.dart';
import 'model/payload.dart';


typedef void BootpayDefaultCallback(String data);
typedef bool BootpayConfirmCallback(String data);
typedef void BootpayCloseCallback();

class Bootpay extends BootpayApi {
  static final Bootpay _bootpay = Bootpay._internal();
  factory Bootpay() {
    return _bootpay;
  }
  Bootpay._internal() {
    _platform = BootpayPlatform();
  }

  late BootpayPlatform _platform;

  @override
  void request(
      {Key? key,
      required BuildContext context,
      required Payload payload,
      required bool isMaterialStyle,
      required bool showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      BootpayDefaultCallback? onReady,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone}) {

    _platform.request(
        context: context,
        payload: payload,
        isMaterialStyle: isMaterialStyle,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onConfirm: onConfirm,
        onDone: onDone
    );
  }

  @override
  void transactionConfirm(String data) {
    _platform.transactionConfirm(data);
  }

  @override
  void removePaymentWindow() {
    _platform.removePaymentWindow();
  }
}
