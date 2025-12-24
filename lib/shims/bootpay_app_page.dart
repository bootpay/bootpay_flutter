

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

class _BootpayAppPageState extends State<BootpayAppPage> with WidgetsBindingObserver {
  DebounceCloseController closeController = Get.find();
  DateTime? currentBackPressTime = DateTime.now();
  bool isProgressShow = false;
  bool _isResuming = false; // 외부 앱에서 복귀 시 깜빡임 방지

  double _height = 0;

  @override
  void initState() {
    // TODO: implement initState
    // closeController.isBootpayShow = true;
    super.initState();

    // 앱 상태 변화 감지 등록
    WidgetsBinding.instance.addObserver(this);

    closeController.isFireCloseEvent = false;
    closeController.isDebounceShow = true;
    print("BootpayAppPage.initState() - isDebounceShow set to true");

    widget.webView?.onProgressShow = (isShow) {
      print(isShow);
      // setState(() {
      //   isProgressShow = isShow;
      // });
    };

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 외부 앱에서 돌아올 때 - 깜빡임 방지를 위해 약간의 딜레이
      _isResuming = true;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isResuming = false;
          });
        }
      });
    }
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
    if(this.widget.webView?.isWidget == true ) {
      closeController.bootpayClose(this.widget.webView?.onCloseWidget);
    } else {
      closeController.bootpayClose(this.widget.webView?.onClose);
    }

    closeController.isFireCloseEvent = false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            backgroundColor: Colors.white, // 외부 앱 복귀 시 깜빡임 방지
            body: SafeArea(
              child: Container(
                  color: Colors.white, // 배경색 통일
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
          backgroundColor: Colors.white, // 외부 앱 복귀 시 깜빡임 방지
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                    color: Colors.white, // 배경색 통일
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