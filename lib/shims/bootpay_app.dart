
import 'dart:async';
import 'dart:io';
import 'package:bootpay/api/bootpay_analytics.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/constant/bootpay_constant.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../bootpay.dart';
import '../bootpay_api.dart';
import '../bootpay_webview.dart';
import '../bootpay_widget_api.dart';
import '../controller/debounce_close_controller.dart';
import '../model/payload.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'bootpay_app_page.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;



class BootpayPlatform extends BootpayApi with BootpayWidgetApi {

  String get WebUserAgent => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36';
  String get iOSUserAgent => 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_3_1 like Mac OS X) AppleWebKit/603.1.30 (KHTML, like Gecko) Version/10.0 Mobile/14E304 Safari/602.1';
  String get AndroidUserAgent => 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.40 Mobile Safari/537.36';

  // DebounceCloseController closeController = Get.find();
  BootpayWebView? webView;

  // void bootpayClose() {
  //   // BootpayPrint("bootpayClose : ${closeController.isFireCloseEvent}");
  //   if(closeController.isFireCloseEvent == true) return;
  //   closeController.bootpayClose(this.webView?.onClose);
  //   closeController.isFireCloseEvent = false;
  // }

  @override
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
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        double? webViewPadding,
        int? requestType
      }) {

    goBootpayRequest(
        key: key,
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
        padding: webViewPadding,
        requestType: BootpayConstant.REQUEST_TYPE_PAYMENT
    );
  }

  @override
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
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        double? webViewPadding,
        int? requestType
      }) {
    goBootpayRequest(
        key: key,
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
        padding: webViewPadding,
        requestType: BootpayConstant.REQUEST_TYPE_SUBSCRIPT
    );
  }

  @override
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
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        double? webViewPadding,
        int? requestType
      }) {

    goBootpayRequest(
        key: key,
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
        padding: webViewPadding,
        requestType: BootpayConstant.REQUEST_TYPE_AUTH
    );
  }


  @override
  void requestPassword(
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
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        double? webViewPadding,
        int? requestType
      }) {

    goBootpayRequest(
        key: key,
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
        padding: webViewPadding,
        requestType: BootpayConstant.REQUEST_TYPE_PASSWORD
    );
  }

  Future<void> goBootpayRequest(
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
        BootpayAsyncConfirmCallback? onConfirmAsync,
        BootpayDefaultCallback? onDone,
        String? userAgent,
        double? padding,
        int? requestType
      }) async {

    // if(isTabletOrWeb(context)) {
    //   if(userAgent == null) {
    //     userAgent = defaultOSUserAgent();
    //     // userAgent = iOSUserAgent;
    //   }
    // }

    createWebView(
      payload: payload,
      showCloseButton: showCloseButton,
      key: key,
      closeButton: closeButton,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      onIssued: onIssued,
      onConfirm: onConfirm,
      onConfirmAsync: onConfirmAsync,
      onDone: onDone,
      userAgent: userAgent,
      requestType: requestType,
    );
    webView?.isWidget = false;

    if(context == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BootpayAppPage(webView, padding))
    );
    webView = null;
  }

  void createWebView({
    Key? key,
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
    int? requestType
  }) {
    if(webView == null) {
      webView = BootpayWebView(key: key);
    }
    webView?.payload = payload;
    webView?.showCloseButton = showCloseButton;
    webView?.closeButton = closeButton;
    webView?.onCancel = onCancel;
    webView?.onError = onError;
    webView?.onClose = onClose;
    webView?.onIssued = onIssued;
    webView?.onConfirm = onConfirm;
    webView?.onConfirmAsync = onConfirmAsync;
    webView?.onDone = onDone;
    webView?.userAgent = userAgent;
    webView?.requestType = requestType;
  }

  //ipad check
  // bool isTabletOrWeb(BuildContext? context)  {
  //   if(context == null) return false;
  //   // if(!Platform.isIOS) return false;
  //   return MediaQuery.of(context).size.width >= 600;
  // }

  //iphone user agent
  String defaultOSUserAgent() {
    if(BootpayConfig.IS_FORCE_WEB) return WebUserAgent;
    if(Platform.isIOS) return iOSUserAgent;
    else return AndroidUserAgent;
  }

  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    if(BootpayConfig.IS_FORCE_WEB) return webApplicationId;
    else if(Platform.isIOS) return iosApplicationId;
    else return androidApplicationId;
  }


  @override
  void removePaymentWindow() {
    if(webView != null) {
      webView!.removePaymentWindow();
      webView = null;
    }
  }

  @override
  void dismiss(BuildContext context) {
    if(webView != null) {
      Navigator.of(context).pop();
      webView = null;
    }
  }

  @override
  void transactionConfirm() {
    if(webView != null) webView!.transactionConfirm();
  }

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
  }) async {
    if(ver == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      ver = packageInfo.version;
    }

    return BootpayAnalytics.userTrace(
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
  Future<http.Response> pageTrace({
    String? url,
    String? pageType,
    String? applicationId,
    String? userId,
    List<StatItem>? items,
    String? ver,
  }) async {
    if(ver == null) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      ver = packageInfo.version;
    }

    return BootpayAnalytics.pageTrace(
        url: url,
        pageType: pageType,
        userId: userId,
        items: items,
        applicationId: applicationId,
        ver: ver
    );
  }

  @override
  void setLocale(String locale) {
    if(webView != null) webView!.setLocale(locale);
  }

  @override
  void render({Key? key, BuildContext? context, Payload? payload}) {
    // if(webView != null) webView!.resizeWatch (key: key, context: context, payload: payload);

    webView = null;
    createWebView(
      key: key,
        payload: payload
    );
    webView?.isWidget = true;
    webView?.payload = payload;

    if(context == null) return;

    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BootpayAppPage(webView, 0))
    );
  }

  @override
  void update({Key? key, BuildContext? context, Payload? payload}) {
    // TODO: implement update
  }
}