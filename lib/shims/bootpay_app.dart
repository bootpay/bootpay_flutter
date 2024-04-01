
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
import '../controller/debounce_close_controller.dart';
import '../model/payload.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;

class WebViewRoute extends StatefulWidget {

  BootpayWebView? webView;
  bool isTablet;
  WebViewRoute(this.webView, this.isTablet);

  @override
  _WebViewRouteState createState() => _WebViewRouteState();
}

class _WebViewRouteState extends State<WebViewRoute> {
  DebounceCloseController closeController = Get.find();
  DateTime? currentBackPressTime = DateTime.now();
  bool isProgressShow = false;
  // bool isBootpayShow = true;
  // bool showHeaderView = false;




  @override
  void initState() {
    // TODO: implement initState
    // closeController.isBootpayShow = true;
    super.initState();

    closeController.isFireCloseEvent = false;
    closeController.isDebounceShow = true;

    widget.webView?.onProgressShow = (isShow) {
      setState(() {
        isProgressShow = isShow;
      });
    };
  }


  // void dis

  // void updateShowHeader(bool showHeader) {
  //   if(this.showHeaderView != showHeader) {
  //     setState(() {
  //       showHeaderView = showHeader;
  //     });
  //   }
  // }

  clickCloseButton() {
    if (widget.webView?.onCancel != null)
      widget.webView?.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
    if (widget.webView?.onClose != null)
      widget.webView?.onClose!();
  }


  // Timer? _debounce;
  void bootpayClose() {
    // BootpayPrint("bootpayClose : ${closeController.isFireCloseEvent}");
    if(closeController.isFireCloseEvent == true) return;
    closeController.bootpayClose(this.widget.webView?.onClose);
    closeController.isFireCloseEvent = false;
  }

  @override
  void dispose() {
    bootpayClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    // isBootpayShow = true;

    double paddingValue = BootpayConfig.DISPLAY_TABLET_FULLSCREEN ? 0 : MediaQuery.of(context).size.width * 0.2;

    if(Platform.isAndroid) {
      return WillPopScope(
        child: Scaffold(
            body: SafeArea(
              child: Container(
                  color: Colors.black26,
                  child: widget.isTablet == false ? widget.webView ?? Container() : Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: widget.webView!,
                  )
              ),
            )
        ),
        onWillPop: () async {
          DateTime now = DateTime.now();
          if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "\'뒤로\' 버튼을 한번 더 눌러주세요.");
            return Future.value(false);
          }
          // bootpayClose();
          return Future.value(true);
        },
      );
    } else {
      return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                    color: Colors.black26,
                    child: widget.isTablet == false ? widget.webView ?? Container() : Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: widget.webView!,
                    )
                ),
                isProgressShow == false ? Container() : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Colors.black12,
                    child: Center(child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                )
              ],
            ),
          )
      );
    }
  }
}

class BootpayPlatform extends BootpayApi{

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
        int? requestType
      }) async {

    if(isTabletOrWeb(context)) {
      if(userAgent == null) {
        userAgent = defaultOSUserAgent();
        // userAgent = iOSUserAgent;
      }
    }

    webView = BootpayWebView(
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

    if(context == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewRoute(webView, isTabletOrWeb(context))),
    );
    webView = null;
  }

  //ipad check
  bool isTabletOrWeb(BuildContext? context)  {
    if(context == null) return false;
    // if(!Platform.isIOS) return false;
    return MediaQuery.of(context).size.width >= 600;
  }

  //iphone user agent
  String defaultOSUserAgent() {
    if(BootpayConfig.IS_FORCE_WEB) return WebUserAgent;
    if(Platform.isIOS) return iOSUserAgent;
    else return AndroidUserAgent;
    // return iOSUserAgent;
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

    // print(ModalRoute.of(context)?.settings.name);


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
    // TODO: implement setLocale
    if(webView != null) webView!.setLocale(locale);
  }
}