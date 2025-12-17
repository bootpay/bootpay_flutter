import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart.dart';
import 'payments/default_payment_screen.dart';
import 'payments/total_payment_screen.dart';
import 'payments/subscription_screen.dart';
import 'payments/subscription_bootpay_screen.dart';
import 'payments/authentication_screen.dart';
import 'payments/webapp_payment_screen.dart';
import 'payments/widget_payment_screen.dart';
import 'payments/password_payment_screen.dart';

/// 결제 옵션 선택 화면 (Android MainActivity / iOS ViewController 역할)
class PaymentOptionsScreen extends StatelessWidget {
  const PaymentOptionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    final cart = Cart();

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 방법 선택'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 결제 금액 정보
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '결제 금액',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatter.format(cart.totalPrice.toInt())}원',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '상품 ${cart.itemCount}개',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // 결제 옵션 목록
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const _SectionHeader(title: '일반 결제'),
                _PaymentOptionCard(
                  icon: Icons.credit_card,
                  title: '1. PG 일반 결제',
                  description: '카드, 계좌이체, 가상계좌 등',
                  onTap: () => _navigateTo(context, const DefaultPaymentScreen()),
                ),
                _PaymentOptionCard(
                  icon: Icons.payment,
                  title: '2. 통합결제 테스트',
                  description: '모든 결제수단 통합 UI',
                  onTap: () => _navigateTo(context, const TotalPaymentScreen()),
                ),
                const SizedBox(height: 16),
                const _SectionHeader(title: '정기 결제'),
                _PaymentOptionCard(
                  icon: Icons.autorenew,
                  title: '3. 정기결제 (인증)',
                  description: 'PG사 UI로 카드 등록',
                  onTap: () => _navigateTo(context, const SubscriptionScreen()),
                ),
                _PaymentOptionCard(
                  icon: Icons.loop,
                  title: '4. 정기결제 (비인증)',
                  description: '부트페이 UI로 카드 등록',
                  onTap: () => _navigateTo(context, const SubscriptionBootpayScreen()),
                ),
                const SizedBox(height: 16),
                const _SectionHeader(title: '인증'),
                _PaymentOptionCard(
                  icon: Icons.verified_user,
                  title: '5. 본인인증',
                  description: '휴대폰 본인인증',
                  onTap: () => _navigateTo(context, const AuthenticationScreen()),
                ),
                const SizedBox(height: 16),
                const _SectionHeader(title: '기타 결제'),
                _PaymentOptionCard(
                  icon: Icons.password,
                  title: '6. 비밀번호 결제',
                  description: '간편 비밀번호 결제',
                  onTap: () => _navigateTo(context, const PasswordPaymentScreen()),
                ),
                _PaymentOptionCard(
                  icon: Icons.widgets,
                  title: '7. 위젯 결제',
                  description: '결제 위젯 UI 사용',
                  onTap: () => _navigateTo(context, const WidgetPaymentScreen()),
                ),
                _PaymentOptionCard(
                  icon: Icons.web,
                  title: '8. 웹앱 연동',
                  description: '웹뷰로 결제 연동',
                  onTap: () => _navigateTo(context, const WebAppPaymentScreen()),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
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

/// 섹션 헤더
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

/// 결제 옵션 카드
class _PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
