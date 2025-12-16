import 'dart:async';
import 'package:flutter/material.dart';

import '../bootpay.dart';
import '../model/payload.dart';

/// 위젯 결제 전체화면 페이지 (Web용)
/// Web에서는 JS SDK를 직접 사용하므로 별도 페이지가 필요없지만
/// 호환성을 위해 stub 제공
class BootpayWidgetPaymentPage extends StatefulWidget {
  final Payload payload;
  final BootpayDefaultCallback? onCancel;
  final BootpayDefaultCallback? onError;
  final BootpayCloseCallback? onClose;
  final BootpayDefaultCallback? onIssued;
  final BootpayConfirmCallback? onConfirm;
  final BootpayAsyncConfirmCallback? onConfirmAsync;
  final BootpayDefaultCallback? onDone;

  const BootpayWidgetPaymentPage({
    Key? key,
    required this.payload,
    this.onCancel,
    this.onError,
    this.onClose,
    this.onIssued,
    this.onConfirm,
    this.onConfirmAsync,
    this.onDone,
  }) : super(key: key);

  @override
  State<BootpayWidgetPaymentPage> createState() => _BootpayWidgetPaymentPageState();
}

class _BootpayWidgetPaymentPageState extends State<BootpayWidgetPaymentPage> {
  @override
  void initState() {
    super.initState();
    debugPrint('[WidgetPaymentPage Web] Web에서는 BootpayWidgetPaymentPage 대신 BootpayWidget을 사용하세요.');
    // Web에서는 JS SDK로 직접 결제하므로 바로 닫기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onClose?.call();
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Web에서는 BootpayWidget을 직접 사용하세요.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
