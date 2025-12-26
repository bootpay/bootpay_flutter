
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

  /// Whether the WebView has been warmed up
  static bool get isWarmedUp => _isWarmedUp;

  /// Pre-warms the WebView by creating an invisible instance (iOS/macOS only)
  ///
  /// This method initializes WKWebView's internal processes in the background:
  /// - GPU process initialization (1-2 seconds saved)
  /// - Networking process initialization (1-2 seconds saved)
  /// - WebContent process initialization (1-3 seconds saved)
  /// - **Total: 3-7 seconds faster first payment screen loading**
  ///
  /// ## Usage
  ///
  /// Call this as early as possible in your app lifecycle:
  ///
  /// ```dart
  /// void main() {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   Bootpay.warmUp();  // Pre-warm WebView
  ///   runApp(MyApp());
  /// }
  /// ```
  ///
  /// **Note**: This is a no-op on Android and Web platforms.
  ///
  /// Returns `true` if warm-up was initiated successfully.
  static Future<bool> warmUp() async {
    // Only supported on iOS and macOS
    if (kIsWeb) return false;
    if (!Platform.isIOS && !Platform.isMacOS) return false;

    try {
      final result = await _warmUpChannel.invokeMethod<bool>('warmUp');
      _isWarmedUp = result ?? false;
      return _isWarmedUp;
    } on PlatformException catch (e) {
      debugPrint('[Bootpay] WarmUp failed: ${e.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Releases the pre-warmed WebView to free memory (iOS/macOS only)
  ///
  /// Call this method when:
  /// - Receiving memory warnings
  /// - WebView is no longer needed in the app
  /// - App is going to background for extended period
  ///
  /// ## Usage
  ///
  /// ```dart
  /// @override
  /// void didReceiveMemoryWarning() {
  ///   Bootpay.releaseWarmUp();
  /// }
  /// ```
  ///
  /// **Note**: This is a no-op on Android and Web platforms.
  ///
  /// Returns `true` if release was successful.
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
