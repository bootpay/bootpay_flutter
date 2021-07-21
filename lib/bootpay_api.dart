
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';

abstract class BootpayApi {

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
  void dismiss(BuildContext context);
}