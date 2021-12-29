
import 'model/stat_item.dart';
import 'shims/bootpay_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bootpay_api.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;


typedef void BootpayDefaultCallback(String data);
typedef bool BootpayConfirmCallback(String data);
typedef void BootpayCloseCallback();
typedef void ShowHeaderCallback(bool showHeader);

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
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return _platform.applicationId(webApplicationId, androidApplicationId, iosApplicationId);
  }

  @override
  void requestPayment(
      {Key? key,
      BuildContext? context,
      Payload? payload,
      bool? showCloseButton,
      Widget? closeButton,
      BootpayDefaultCallback? onCancel,
      BootpayDefaultCallback? onError,
      BootpayCloseCallback? onClose,
      BootpayCloseCallback? onCloseHardware,
      BootpayDefaultCallback? onIssued,
      BootpayConfirmCallback? onConfirm,
      BootpayDefaultCallback? onDone,
      int? requestType}) {

    _platform.requestPayment(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onCloseHardware: onCloseHardware,
        onConfirm: onConfirm, 
        onDone: onDone,
        requestType: requestType
    );
  }

  @override
  void requestSubscription(
      {Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
        int? requestType}) {

    if(payload?.subscriptionId == null || payload?.subscriptionId?.length == 0) {
      payload?.subscriptionId = payload.orderId ?? "";
    }

    _platform.requestSubscription(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onDone: onDone,
        requestType: requestType
    );
  }

  @override
  void requestAuthentication(
      {Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
        int? requestType}) {

    if(payload?.subscriptionId == null || payload?.subscriptionId?.length == 0) {
      payload?.subscriptionId = payload.orderId ?? "";
    }

    _platform.requestAuthentication(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onCloseHardware: onCloseHardware,
        onConfirm: onConfirm,
        onDone: onDone,
        requestType: requestType
    );
  }

  @override
  void confirm() {
    _platform.confirm();
  }

  @override
  void removePaymentWindow() {
    _platform.removePaymentWindow();
  }

  @override
  void dismiss(BuildContext context) {
    _platform.dismiss(context);
  }

  // 회원 추적 코드
  @override
  Future<http.Response> userTrace({
    String? id,
    String? email,
    int? gender,
    String? birth,
    String? phone,
    String? area,
    String? applicationId,
    String? ver,
  }) {

    return _platform.userTrace(
        id: id,
        email: email,
        gender: gender,
        birth: birth,
        phone: phone,
        area: area,
        applicationId: applicationId,
        ver: ver
    );
  }

  // 페이지 추적 코드
  @override
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
    String? ver,
  }) {

    return _platform.pageTrace(
        url: url,
        pageType: pageType,
        userId: userId,
        items: items,
        applicationId: applicationId,
        ver: ver
    );
  }
}
