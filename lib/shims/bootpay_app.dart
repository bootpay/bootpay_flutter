
import 'dart:io';
import 'package:bootpay/api/bootpay_analytics.dart';
import 'package:bootpay/model/stat_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

import '../bootpay.dart';
import '../bootpay_api.dart';
import '../bootpay_webview.dart';
import '../model/payload.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;

class WebViewRoute extends StatefulWidget {

  BootpayWebView? webView;
  WebViewRoute(this.webView);

  @override
  _WebViewRouteState createState() => _WebViewRouteState();
}

class _WebViewRouteState extends State<WebViewRoute> {
  DateTime? currentBackPressTime = DateTime.now();
  bool showHeaderView = false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.webView?.onShowHeader = updateShowHeader;

  }

  void updateShowHeader(bool showHeader) {
    if(this.showHeaderView != showHeader) {
      setState(() {
        showHeaderView = showHeader;
      });
    }

  }

  clickCloseButton() {
    if (widget.webView?.onCancel != null)
      widget.webView?.onCancel!('{"action":"BootpayCancel","status":-100,"message":"사용자에 의한 취소"}');
    if (widget.webView?.onClose != null)
      widget.webView?.onClose!();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    // widget.webView?.on


    // print(widget.webView?.showHeaderView);

    return WillPopScope(

      child: Scaffold(
          body: SafeArea(
              child: Stack(
                children: [
                  Container(
                      child: widget.webView!
                  ),
                  this.showHeaderView == true ? Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      height: 40,
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Container()),
                          IconButton(
                            onPressed: () => clickCloseButton(),
                            icon: Icon(Icons.close, size: 35.0, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ) : Container()
                ],
              )
          )
      ),
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          if(widget.webView?.onCloseHardware != null) widget.webView?.onCloseHardware!();
          Fluttertoast.showToast(msg: "\'뒤로\' 버튼을 한번 더 눌러주세요.");
          return Future.value(false);
        }
        return Future.value(true);
      },
    );
  }
}

class BootpayPlatform extends BootpayApi{

  BootpayWebView? webView;

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
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
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
      onCloseHardware: onCloseHardware,
      onIssued: onIssued,
      onConfirm: onConfirm,
      onDone: onDone,
      requestType: requestType
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
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
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
        onCloseHardware: onCloseHardware,
        onIssued: onIssued,
        onConfirm: onConfirm,
        onDone: onDone,
        requestType: requestType
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
        BootpayCloseCallback? onCloseHardware,
        BootpayDefaultCallback? onIssued,
        BootpayConfirmCallback? onConfirm,
        BootpayDefaultCallback? onDone,
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
        onCloseHardware: onCloseHardware,
        onIssued: onIssued,
        onConfirm: onConfirm,
        onDone: onDone,
        requestType: requestType
    );
  }

  void goBootpayRequest(
      {
        Key? key,
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
        int? requestType
      }) {

    webView = BootpayWebView(
      payload: payload,
      showCloseButton: showCloseButton,
      key: key,
      closeButton: closeButton,
      onCancel: onCancel,
      onError: onError,
      onClose: onClose,
      onCloseHardware: onCloseHardware,
      onIssued: onIssued,
      onConfirm: onConfirm,
      onDone: onDone,
      requestType: requestType,
    );

    if(context == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewRoute(webView)),
    );
  }

  @override
  String applicationId(String webApplicationId, String androidApplicationId, String iosApplicationId) {
    if(Platform.isIOS) return iosApplicationId;
    else return androidApplicationId;
  }


  @override
  void removePaymentWindow() {
    if(webView != null) {
      webView!.removePaymentWindow();
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
  void confirm() {
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
}