

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../bootpay_webview.dart';
import '../config/bootpay_config.dart';
import '../controller/debounce_close_controller.dart';

class BootpayAppPage extends StatefulWidget {

  BootpayWebView? webView;
  double? padding;
  BootpayAppPage(this.webView, this.padding);

  @override
  _BootpayAppPageState createState() => _BootpayAppPageState();
}

class _BootpayAppPageState extends State<BootpayAppPage> {
  DebounceCloseController closeController = Get.find();
  DateTime? currentBackPressTime = DateTime.now();
  bool isProgressShow = false;

  double _height = 0;

  @override
  void initState() {
    // TODO: implement initState
    // closeController.isBootpayShow = true;
    super.initState();

    closeController.isFireCloseEvent = false;
    closeController.isDebounceShow = true;

    widget.webView?.onProgressShow = (isShow) {
      print(isShow);
      // setState(() {
      //   isProgressShow = isShow;
      // });
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

    // double paddingValue = widget.padding ?? (BootpayConfig.DISPLAY_TABLET_FULLSCREEN ? 0 : MediaQuery.of(context).size.width * 0.2);
    double paddingValue = widget.padding ?? 0;

    if(Platform.isAndroid) {
      return WillPopScope(
        child: Scaffold(
            body: SafeArea(
              child: Container(
                  color: Colors.black26,
                  child: Padding(
                    padding: EdgeInsets.all(paddingValue),
                    child: widget.webView ?? Container(),
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
                    child: Padding(
                      padding: EdgeInsets.all(paddingValue),
                      child: widget.webView ?? Container(),
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