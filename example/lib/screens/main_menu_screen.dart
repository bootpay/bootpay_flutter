import 'package:flutter/material.dart';
import 'payments/default_payment_screen.dart';
import 'payments/total_payment_screen.dart';
import 'payments/subscription_screen.dart';
import 'payments/subscription_bootpay_screen.dart';
import 'payments/authentication_screen.dart';
import 'payments/password_payment_screen.dart';
import 'payments/widget_payment_screen.dart';
import 'payments/webapp_payment_screen.dart';
import 'payments/commerce_screen.dart';

/// 메인 메뉴 화면 (Android MainActivity / iOS ViewController)
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 타이틀
            const Text(
              'Bootpay 결제 테스트',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '테스트할 결제 방식을 선택하세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            // 메뉴 버튼들
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _MenuButton(
                    number: 1,
                    title: 'PG 일반 결제 테스트',
                    onTap: () => _navigateTo(context, const DefaultPaymentScreen()),
                  ),
                  _MenuButton(
                    number: 2,
                    title: '통합결제 테스트',
                    onTap: () => _navigateTo(context, const TotalPaymentScreen()),
                  ),
                  _MenuButton(
                    number: 3,
                    title: '카드자동 결제 테스트 (인증)',
                    onTap: () => _navigateTo(context, const SubscriptionScreen()),
                  ),
                  _MenuButton(
                    number: 4,
                    title: '카드자동 결제 테스트 (비인증)',
                    onTap: () => _navigateTo(context, const SubscriptionBootpayScreen()),
                  ),
                  _MenuButton(
                    number: 5,
                    title: '본인인증 테스트',
                    onTap: () => _navigateTo(context, const AuthenticationScreen()),
                  ),
                  _MenuButton(
                    number: 6,
                    title: '비밀번호 결제 테스트',
                    onTap: () => _navigateTo(context, const PasswordPaymentScreen()),
                  ),
                  _MenuButton(
                    number: 7,
                    title: '위젯 결제 테스트',
                    onTap: () => _navigateTo(context, const WidgetPaymentScreen()),
                  ),
                  _MenuButton(
                    number: 8,
                    title: '웹앱으로 연동하기',
                    onTap: () => _navigateTo(context, const WebAppPaymentScreen()),
                  ),
                  _MenuButton(
                    number: 9,
                    title: 'Commerce 구독 결제',
                    onTap: () => _navigateTo(context, const CommerceScreen()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final int number;
  final String title;
  final VoidCallback onTap;

  const _MenuButton({
    required this.number,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$number. $title',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
