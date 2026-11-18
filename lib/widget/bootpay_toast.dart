import 'dart:async';

import 'package:flutter/material.dart';

/// SDK 내부용 짧은 안내 토스트 (fluttertoast 대체).
///
/// 네이티브 의존 없이 Overlay 위에 Android Toast 와 비슷한 모양을 그린다.
/// 결제 화면은 항상 Navigator 로 push 되므로 Overlay 가 존재한다.
/// 공개 API 가 아니다 — `bootpay.dart` 에서 export 하지 않는다.
class BootpayToast {
  BootpayToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _dismiss();
    final entry = OverlayEntry(
      builder: (context) => _BootpayToastView(message: message),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _BootpayToastView extends StatelessWidget {
  const _BootpayToastView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.maybeOf(context)?.padding.bottom ?? 0;
    return Positioned(
      left: 24,
      right: 24,
      bottom: bottomInset + 64,
      child: IgnorePointer(
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 150),
            builder: (context, opacity, child) =>
                Opacity(opacity: opacity, child: child),
            child: Material(
              color: const Color(0xE6323232),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
