
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';

abstract class BootpayApi {

  void request(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onReady,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone
      });

  void transactionConfirm(String data);
  void removePaymentWindow();
  void dismiss(BuildContext context);
}