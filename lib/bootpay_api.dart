
import 'package:flutter/widgets.dart';

import 'bootpay.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;

import 'model/stat_item.dart';

abstract class BootpayApi {

  void requestPayment(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
        int? requestType
      });

  void requestSubscription(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
        int? requestType
      });

  void requestAuthentication(
      {
        Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
        int? requestType
      });

  // String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId);
  void transactionConfirm();
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
    String? applicationId
  });

  // 페이지 추적 코드
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items
  });
}