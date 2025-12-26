
import 'dart:io';

import 'package:bootpay/config/bootpay_config.dart';
import 'package:flutter/services.dart';

import 'model/stat_item.dart';
import 'model/widget/widget_data.dart';
import 'shims/bootpay_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bootpay_api.dart';
import 'model/payload.dart';
import 'package:http/http.dart' as http;

// Commerce exports
export 'commerce/bootpay_commerce.dart';
export 'model/commerce/commerce_payload.dart';
export 'model/commerce/commerce_user.dart';
export 'model/commerce/commerce_product.dart';
export 'model/commerce/commerce_extra.dart';


typedef void BootpayProgressBarCallback(bool isShow);
// typedef void ShowHeaderCallback(bool showHeader);

typedef BootpayDefaultCallback = void Function(String data);
typedef BootpayConfirmCallback = bool Function(String data);
typedef BootpayAsyncConfirmCallback = Future<bool> Function(String data);
typedef BootpayCloseCallback = void Function();

typedef WidgetResizeCallback = void Function(double height);
typedef WidgetChangePaymentCallback = void Function(WidgetData? data);


class Bootpay extends BootpayApi {

  // ============================================
  // WebView WarmUp API (iOS/macOS only)
  // ============================================

  static const MethodChannel _warmUpChannel =
      MethodChannel('kr.co.bootpay/webview_warmup');

  static bool _isWarmedUp = false;
  static bool _autoWarmUpCalled = false;

  /// Whether the WebView has been warmed up
  static bool get isWarmedUp => _isWarmedUp;

  /// Automatically warms up the WebView when SDK is first used.
  /// This is called internally - users don't need to call this manually.
  static void _autoWarmUp() {
    if (_autoWarmUpCalled) return;
    _autoWarmUpCalled = true;

    // Only supported on iOS and macOS
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isMacOS) return;

    // Call warmUp asynchronously without blocking
    _warmUpChannel.invokeMethod<bool>('warmUp').then((result) {
      _isWarmedUp = result ?? false;
      if (_isWarmedUp) {
        debugPrint('[Bootpay] WebView auto warm-up completed');
      }
    }).catchError((e) {
      // Silently ignore errors - warmUp is optional optimization
    });
  }

  /// Releases the pre-warmed WebView to free memory (iOS/macOS only)
  ///
  /// Call this method when receiving memory warnings.
  /// Note: This is optional. The SDK handles memory efficiently by default.
  ///
  /// **Note**: This is a no-op on Android and Web platforms.
  static Future<bool> releaseWarmUp() async {
    // Only supported on iOS and macOS
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isMacOS) return false;

    try {
      final result = await _warmUpChannel.invokeMethod<bool>('releaseWarmUp');
      _isWarmedUp = false;
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('[Bootpay] ReleaseWarmUp failed: ${e.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  // ============================================
  // Singleton Instance
  // ============================================
  static final Bootpay _bootpay = Bootpay._internal();
  factory Bootpay() {
    return _bootpay;
  }
  Bootpay._internal() {
    _platform = BootpayPlatform();
    // Auto warm-up WebView on iOS/macOS for faster first payment
    _autoWarmUp();
  }

  late BootpayPlatform _platform;


  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    return _platform.applicationId(webApplicationId, androidApplicationId, iosApplicationId);
  }

  final double WIDGET_HEIGHT = 300.0;

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
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
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
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
        onDone: onDone,
        userAgent: userAgent,
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
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        String? userAgent,
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
        onConfirm: onConfirm,
        userAgent: userAgent,
        onConfirmAsync: onConfirmAsync,
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
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
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
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
        onDone: onDone,
        userAgent: userAgent,
        requestType: requestType
    );
  }


  @override
  void requestPassword(
      {Key? key,
        BuildContext? context,
        Payload? payload,
        bool? showCloseButton,
        Widget? closeButton,
        BootpayDefaultCallback? onCancel,
        BootpayDefaultCallback? onError,
        BootpayCloseCallback? onClose,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        int? requestType}) {


    _platform.requestPassword(
        context: context,
        payload: payload,
        showCloseButton: showCloseButton,
        closeButton: closeButton,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onIssued: onIssued,
        onConfirm: onConfirm,
        onConfirmAsync: onConfirmAsync,
        onDone: onDone,
        userAgent: userAgent,
        requestType: requestType
    );
  }

  @override
  void transactionConfirm() {
    _platform.transactionConfirm();
  }

  // @override
  // void removePaymentWindow() {
  //   _platform.removePaymentWindow();
  // }

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
    String? applicationId
  }) {

    return _platform.userTrace(
        id: id,
        email: email,
        gender: gender,
        birth: birth,
        phone: phone,
        area: area,
        applicationId: applicationId,
        ver: BootpayConfig.VERSION
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
  }) {

    return _platform.pageTrace(
        url: url,
        pageType: pageType,
        userId: userId,
        items: items,
        applicationId: applicationId,
        ver: BootpayConfig.VERSION
    );
  }

  @override
  void setLocale(String locale) {
    // TODO: implement setLocale
    _platform.setLocale(locale);
  }

  @override
  void removePaymentWindow() {
    _platform.removePaymentWindow();
  }
}
