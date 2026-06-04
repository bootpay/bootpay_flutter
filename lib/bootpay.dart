
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


/// 팝업(window.open / target="_blank") 위에 뜨는 반투명 닫기(✕) 버튼의 노출 모드.
///
/// - [auto]   : 기본값. 광고 도메인(`addPopupAdHosts` 목록)으로 분류된 팝업에만 ✕ 노출.
///              결제 팝업 등 그 외 팝업은 버튼 없이 표시되고 `window.close()` 로 닫힌다.
/// - [always] : 모든 팝업에 ✕ 노출.
/// - [never]  : ✕ 를 절대 노출하지 않음. 닫기는 `window.close()` 또는
///              [Bootpay.closePopupWebView] 로만 처리.
enum BootpayPopupCloseButtonMode { auto, always, never }


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
  // Popup Ad Filter (iOS/Android only)
  // ============================================

  static const MethodChannel _popupChannel =
      MethodChannel('kr.co.bootpay/webview_popup');

  /// 광고 팝업(window.open / target="_blank")에서만 닫기 바를 노출하기 위한
  /// 광고 도메인 목록을 런타임에 확장합니다.
  ///
  /// 팝업이나 광고를 차단하지 않습니다 — 광고는 항상 인앱에 그대로 표시되고,
  /// 이 목록은 "닫기 바를 띄울 광고 도메인"을 식별하는 용도일 뿐입니다.
  /// SDK 는 기본적으로 doubleclick.net / googleadservices.com /
  /// googlesyndication.com 등 주요 광고 네트워크 도메인을 내장하고 있습니다.
  /// 이 메서드로 광고 도메인 조각(host substring)을 추가 주입할 수 있습니다.
  /// 결제창은 동적 PG gateway 도메인을 사용하므로 목록에 매칭되지 않아
  /// 기존처럼 바 없이(full-bleed) 표시됩니다.
  ///
  /// [hosts] 는 host 의 부분 문자열로 대소문자 구분 없이 매칭됩니다.
  /// (예: `['ads.example.com', 'partner-ad.net']`)
  ///
  /// **Note**: iOS / Android 전용. Web 에서는 no-op 입니다.
  static Future<void> addPopupAdHosts(List<String> hosts) async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;
    if (hosts.isEmpty) return;

    try {
      await _popupChannel.invokeMethod<bool>('addAdHosts', hosts);
    } on PlatformException catch (e) {
      debugPrint('[Bootpay] addPopupAdHosts failed: ${e.message}');
    } on MissingPluginException {
      // Native side not registered (older plugin) — ignore.
    }
  }

  /// 팝업 위에 뜨는 반투명 닫기(✕) 버튼의 노출 모드를 설정합니다.
  /// 기본값은 [BootpayPopupCloseButtonMode.auto] (광고 도메인 팝업에만 노출).
  ///
  /// 팝업이나 광고를 차단하지 않습니다 — 광고는 항상 인앱에 그대로 표시되며, 이
  /// 설정은 "✕ 버튼을 언제 보여줄지"만 제어합니다.
  /// - [BootpayPopupCloseButtonMode.auto]   : 광고 도메인 팝업에만 ✕ 노출 (기본).
  /// - [BootpayPopupCloseButtonMode.always] : 모든 팝업에 ✕ 노출.
  /// - [BootpayPopupCloseButtonMode.never]  : ✕ 노출 안 함.
  ///
  /// **Note**: iOS / Android 전용. Web 에서는 no-op 입니다.
  static Future<void> setPopupCloseButtonMode(
      BootpayPopupCloseButtonMode mode) async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;

    try {
      await _popupChannel.invokeMethod<bool>('setCloseButtonMode', mode.name);
    } on PlatformException catch (e) {
      debugPrint('[Bootpay] setPopupCloseButtonMode failed: ${e.message}');
    } on MissingPluginException {
      // Native side not registered (older plugin) — ignore.
    }
  }

  /// 현재 떠 있는 팝업(window.open / target="_blank")을 프로그래매틱하게 닫습니다.
  ///
  /// 예: 광고 SDK 의 "광고 종료" 이벤트를 받았을 때 호출하면, 사용자가 ✕ 를 누르지
  /// 않아도 팝업이 닫힙니다. 메인 결제 WebView 에는 영향이 없으며, 열린 팝업이
  /// 없으면 아무 동작도 하지 않습니다.
  ///
  /// **Note**: iOS / Android 전용. Web 에서는 no-op 입니다.
  static Future<void> closePopupWebView() async {
    if (kIsWeb) return;
    if (!Platform.isIOS && !Platform.isAndroid) return;

    try {
      await _popupChannel.invokeMethod<bool>('closePopup');
    } on PlatformException catch (e) {
      debugPrint('[Bootpay] closePopupWebView failed: ${e.message}');
    } on MissingPluginException {
      // Native side not registered (older plugin) — ignore.
    }
  }

  // ============================================
  // Environment Mode
  // ============================================

  /// WebView 결제 환경을 설정합니다. 기본값은 production 입니다.
  ///
  /// 다른 SDK (JS / iOS / Android / RN) 와 일관된 API 로,
  /// 내부적으로는 [BootpayConfig.ENV] 값을 매핑합니다.
  ///
  /// - `'development'` → `BootpayConfig.ENV_DEBUG`
  /// - `'stage'` → `BootpayConfig.ENV_STAGE`
  /// - `'production'` (그 외 값 포함) → `BootpayConfig.ENV_PROMOTION`
  static void setEnvironmentMode(String mode) {
    switch (mode) {
      case 'development':
        BootpayConfig.ENV = BootpayConfig.ENV_DEBUG;
        break;
      case 'stage':
        BootpayConfig.ENV = BootpayConfig.ENV_STAGE;
        break;
      case 'production':
      default:
        BootpayConfig.ENV = BootpayConfig.ENV_PROMOTION;
        break;
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
