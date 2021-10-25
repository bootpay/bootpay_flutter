
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;

import 'model/stat_item.dart';

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

  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId);
  void transactionConfirm(String data);
  void removePaymentWindow();
  void dismiss(BuildContext context);

  // 회원 추적 코드
  Future<http.Response> userTrace({
    String? id,
    String? email,
    int? gender,
    String? birth,
    String? phone,
    String? area,
    String? applicationId,
    String? ver,
  });

  // 페이지 추적 코드
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
    String? ver,
  });
}