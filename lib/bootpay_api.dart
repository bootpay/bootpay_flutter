import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';

abstract class BootpayApi {
  // static const MethodChannel _channel = const MethodChannel('bootpay_api');

  void request({
    Key? key,
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
    BootpayDefaultCallback? onDone});

  void transactionConfirm(String data);
  void removePaymentWindow();
}