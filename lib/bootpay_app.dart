
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bootpay_webview.dart';
import 'model/payload.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;

class BootpayApp {
  static void request({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool isMaterialStyle = false,
    required bool showCloseButton,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    if(isMaterialStyle) {
      _requestMaterialStyle(
        context: context,
        payload: payload,
        onCancel: onCancel,
        onError: onError,
        onClose: onClose,
        onReady: onReady,
        onConfirm: onConfirm,
        onDone: onDone,
        showCloseButton: showCloseButton,
        closeButton: closeButton
      );
    } else {
      _requestCupertinoStyle(
          context: context,
          payload: payload,
          onCancel: onCancel,
          onError: onError,
          onClose: onClose,
          onReady: onReady,
          onConfirm: onConfirm,
          onDone: onDone,
          showCloseButton: showCloseButton,
          closeButton: closeButton
      );
    }
  }

  static void _requestMaterialStyle({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool showCloseButton = false,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {
    BottomSheet.showMaterialModalBottomSheet(
      expand: true,
      enableDrag: false,
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        child: SafeArea(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Material(
              color: Colors.transparent,
              child: Scaffold(
                backgroundColor: CupertinoTheme.of(context)
                    .scaffoldBackgroundColor
                    .withOpacity(0.95),
                extendBodyBehindAppBar: true,
                body: BootpayWebView(
                  key: key,
                  showCloseButton: showCloseButton,
                  closeButton: closeButton,
                  payload: payload,
                  onCancel: onCancel,
                  onError: onError,
                  onClose: onClose,
                  onReady: onReady,
                  onConfirm: onConfirm,
                  onDone: onDone,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _requestCupertinoStyle({
    Key? key,
    required BuildContext context,
    required Payload payload,
    bool showCloseButton = false,
    Widget? closeButton,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {
    BottomSheet.showCupertinoModalBottomSheet(
      expand: true,
      enableDrag: false,
      useRootNavigator: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.transparent,
          child: Scaffold(
            backgroundColor: CupertinoTheme.of(context)
                .scaffoldBackgroundColor
                .withOpacity(0.95),
            extendBodyBehindAppBar: true,
            body: BootpayWebView(
              key: key,
              payload: payload,
              showCloseButton: showCloseButton,
              closeButton: closeButton,
              onCancel: onCancel,
              onError: onError,
              onClose: onClose,
              onReady: onReady,
              onConfirm: onConfirm,
              onDone: onDone,
            ),
          ),
        ),
      ),
    );
  }
}