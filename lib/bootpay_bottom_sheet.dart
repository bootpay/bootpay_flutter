
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bootpay_webview.dart';
import 'model/payload.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart' as BottomSheet;

class BootpayBottomSheet {
  static void showCupertinoModalBottomSheet({
    Key? key,
    required BuildContext context,
    required Payload payload,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    BottomSheet.showCupertinoModalBottomSheet(
      expand: true,
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
    );
  }

  static void showMaterialModalBottomSheet({
    Key? key,
    required BuildContext context,
    required Payload payload,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    BottomSheet.showMaterialModalBottomSheet(
      expand: true,
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

  static void showBarModalBottomSheet({
    Key? key,
    required BuildContext context,
    required Payload payload,
    BootpayDefaultCallback? onCancel,
    BootpayDefaultCallback? onError,
    BootpayCloseCallback? onClose,
    BootpayDefaultCallback? onReady,
    BootpayConfirmCallback? onConfirm,
    BootpayDefaultCallback? onDone}) {

    BottomSheet.showBarModalBottomSheet(
      expand: true,
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
    );
  }
}
