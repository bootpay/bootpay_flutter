import 'package:bootpay/bootpay.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Commerce 구독 결제 화면 (iOS CommerceExampleController 참조)
class CommerceScreen extends StatefulWidget {
  const CommerceScreen({Key? key}) : super(key: key);

  @override
  State<CommerceScreen> createState() => _CommerceScreenState();
}

class _CommerceScreenState extends State<CommerceScreen> {
  // 환경별 설정
  final Map<String, Map<String, dynamic>> envConfig = {
    'development': {
      'client_key': 'hxS-Up--5RvT6oU6QJE0JA',
      'plans': {
        'starter': {
          'monthly_product_id': '69268625d8df8fa1837cf661',
          'yearly_product_id': '692686c4d8df8fa1837cf666',
        },
        'pro': {
          'monthly_product_id': '692686e5d8df8fa1837cf66b',
          'yearly_product_id': '69268721d8df8fa1837cf670',
        },
        'enterprise': {
          'monthly_product_id': '69268783d8df8fa1837cf675',
          'yearly_product_id': '692687a2d8df8fa1837cf67a',
        },
      },
    },
    'production': {
      'client_key': 'sEN72kYZBiyMNytA8nUGxQ',
      'plans': {
        'starter': {
          'monthly_product_id': '6927d893ff30795ff003d374',
          'yearly_product_id': '6927d8c310561eabadddcfae',
        },
        'pro': {
          'monthly_product_id': '6927d8f9ff30795ff003d379',
          'yearly_product_id': '6927d9167f65277ba9ddcf71',
        },
        'enterprise': {
          'monthly_product_id': '6927d8f9ff30795ff003d379',
          'yearly_product_id': '6927d9167f65277ba9ddcf71',
        },
      },
    },
  };

  // 플랜 정보
  final Map<String, Map<String, dynamic>> planInfo = {
    'starter': {
      'name': 'Starter',
      'monthly_price': 9900,
      'yearly_price': 7900,
      'features': ['5GB 클라우드 스토리지', '최대 3개 프로젝트', '기본 분석 대시보드'],
    },
    'pro': {
      'name': 'Professional',
      'monthly_price': 29900,
      'yearly_price': 23900,
      'features': ['100GB 클라우드 스토리지', '무제한 프로젝트', '고급 분석 및 리포트'],
    },
    'enterprise': {
      'name': 'Enterprise',
      'monthly_price': 99000,
      'yearly_price': 79000,
      'features': ['무제한 클라우드 스토리지', '무제한 프로젝트', '전용 계정 매니저'],
    },
  };

  String currentEnv = 'production';
  bool isYearlyBilling = false;
  String selectedPlan = 'pro';

  // 테마 컬러
  final Color primaryColor = const Color(0xFF667EEA);
  final Color secondaryColor = const Color(0xFF764BA2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Commerce 구독'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            // 헤더
            const Text(
              '나에게 맞는 요금제를 선택하세요',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '모든 요금제에서 14일 무료 체험을 제공합니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 결제 주기 토글
            _buildBillingToggle(),
            const SizedBox(height: 24),

            // 플랜 카드들
            _buildPlanCard('starter', '🚀', false),
            const SizedBox(height: 16),
            _buildPlanCard('pro', '⚡', true),
            const SizedBox(height: 16),
            _buildPlanCard('enterprise', '🏢', false),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '월간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: !isYearlyBilling ? Colors.black87 : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 12),
        Switch(
          value: isYearlyBilling,
          onChanged: (value) {
            setState(() {
              isYearlyBilling = value;
            });
          },
          activeColor: primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          '연간',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isYearlyBilling ? Colors.black87 : Colors.grey[500],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            '20% 할인',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF15803D),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String planKey, String icon, bool isPopular) {
    final plan = planInfo[planKey]!;
    final name = plan['name'] as String;
    final monthlyPrice = plan['monthly_price'] as int;
    final yearlyPrice = plan['yearly_price'] as int;
    final features = plan['features'] as List<String>;
    final price = isYearlyBilling ? yearlyPrice : monthlyPrice;
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? primaryColor : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPopular) const SizedBox(height: 8),
                // 아이콘
                Text(icon, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 12),
                // 플랜 이름
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // 가격
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₩${formatter.format(price)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isPopular ? primaryColor : const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '/월',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // 기능 목록
                ...features.map((feature) => _buildFeatureRow(feature)),
                const SizedBox(height: 20),
                // 선택 버튼
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _onPlanSelected(planKey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? primaryColor : const Color(0xFFF1F5F9),
                      foregroundColor: isPopular ? Colors.white : const Color(0xFF475569),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      '$name 시작하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 인기 배지
          if (isPopular)
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '가장 인기',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text(
            '✓',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _onPlanSelected(String planKey) {
    if (planKey == 'enterprise') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enterprise 플랜'),
          content: const Text(
            'Enterprise 플랜은 영업팀으로 문의해 주세요.\n이메일: sales@cloudsync.example.com',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      selectedPlan = planKey;
    });
    _startPayment();
  }

  void _startPayment() {
    final config = envConfig[currentEnv]!;
    final clientKey = config['client_key'] as String;
    final plans = config['plans'] as Map<String, Map<String, String>>;
    final planConfig = plans[selectedPlan]!;
    final plan = planInfo[selectedPlan]!;
    final planName = plan['name'] as String;
    final monthlyPrice = plan['monthly_price'] as int;
    final yearlyPrice = plan['yearly_price'] as int;

    final productId = isYearlyBilling
        ? planConfig['yearly_product_id']!
        : planConfig['monthly_product_id']!;
    final billingType = isYearlyBilling ? '연간' : '월간';
    final price = isYearlyBilling ? yearlyPrice : monthlyPrice;

    debugPrint('[CommerceExample] 환경: $currentEnv, 플랜: $selectedPlan, 상품ID: $productId');

    // CommercePayload 생성
    final payload = CommercePayload(
      clientKey: clientKey,
      name: 'CloudSync Pro $planName 플랜',
      memo: '$billingType 구독 결제',
      price: price.toDouble(),
      redirectUrl: 'https://api.bootpay.co.kr/v2/callback',
      usageApiUrl: currentEnv == 'production'
          ? 'https://api.bootapi.com/v1/billing/usage'
          : 'https://dev-api.bootapi.com/v1/billing/usage',
      requestId: 'order_${DateTime.now().millisecondsSinceEpoch}',
      useAutoLogin: true,
      useNotification: true,
    );

    // 사용자 정보
    payload.user = CommerceUser(
      membershipType: 'guest',
      userId: 'demo_user_1234',
      name: '데모 사용자',
      phone: '01040334678',
      email: 'demo@example.com',
    );

    // 상품 정보
    payload.products = [
      CommerceProduct(
        productId: productId,
        duration: -1, // 무기한 구독
        quantity: 1,
      ),
    ];

    // 메타데이터
    final orderId = payload.requestId ?? 'order_${DateTime.now().millisecondsSinceEpoch}';
    payload.metadata = {
      'order_id': orderId,
      'plan_key': selectedPlan,
      'billing_type': billingType,
      'env': currentEnv,
      'selected_at': DateTime.now().toIso8601String(),
    };

    // Extra 옵션
    payload.extra = CommerceExtra(
      separatelyConfirmed: false,
      createOrderImmediately: true,
    );

    // 환경 설정
    BootpayCommerce.setEnvironmentMode(currentEnv);

    // 결제 요청 (Bootpay.requestPayment와 동일한 API 패턴)
    BootpayCommerce.requestCheckout(
      context: context,
      payload: payload,
      showCloseButton: false,
      onDone: (data) {
        debugPrint('-- Commerce done: $data');
        _showPaymentResult(data);
      },
      onError: (data) {
        debugPrint('-- Commerce error: $data');
        _showPaymentResult(data);
      },
      onCancel: (data) {
        debugPrint('-- Commerce cancel: $data');
        _showPaymentResult(data);
      },
      onIssued: (data) {
        debugPrint('-- Commerce issued: $data');
        _showPaymentResult(data);
      },
      onClose: () {
        debugPrint('-- Commerce close');
      },
    );
  }

  void _showPaymentResult(Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _CommerceResultPage(data: data),
      ),
    );
  }
}

/// Commerce 결제 결과 화면 (iOS PaymentResultController와 동일한 구조)
class _CommerceResultPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const _CommerceResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final event = data['event'] as String? ?? '';
    final message = data['message'] as String? ?? '';

    // iOS와 동일한 상태 판단 로직
    IconData statusIcon;
    Color statusColor;
    String title;
    String subtitle;
    Color buttonColor;

    switch (event) {
      case 'done':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        title = '구독 신청 완료';
        subtitle = '구독이 성공적으로 시작되었습니다.';
        buttonColor = Colors.green;
        break;
      case 'cancel':
        statusIcon = Icons.arrow_back_rounded;
        statusColor = Colors.orange;
        title = '결제 취소';
        subtitle = message.isNotEmpty ? message : '결제가 취소되었습니다.';
        buttonColor = Colors.orange;
        break;
      case 'error':
        statusIcon = Icons.error;
        statusColor = Colors.red;
        title = '결제 실패';
        subtitle = message.isNotEmpty ? message : '결제 처리 중 오류가 발생했습니다.';
        buttonColor = Colors.red;
        break;
      case 'issued':
        statusIcon = Icons.account_balance;
        statusColor = Colors.blue;
        title = '가상계좌 발급 완료';
        subtitle = message.isNotEmpty ? message : '가상계좌가 발급되었습니다. 입금을 완료해 주세요.';
        buttonColor = Colors.blue;
        break;
      default:
        // event가 없으면 receipt_id로 판단
        if (data['receipt_id'] != null) {
          statusIcon = Icons.check_circle;
          statusColor = Colors.green;
          title = '구독 신청 완료';
          subtitle = '구독이 성공적으로 시작되었습니다.';
          buttonColor = Colors.green;
        } else {
          statusIcon = Icons.error_outline;
          statusColor = Colors.orange;
          title = '결과 확인 불가';
          subtitle = '결제 결과를 확인할 수 없습니다.';
          buttonColor = Colors.orange;
        }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('결제 결과'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Icon(statusIcon, color: statusColor, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    // 상세 정보 카드 (iOS와 동일)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          // order_number 표시
                          if (data['order_number'] != null)
                            _buildInfoRow('주문번호', data['order_number'].toString()),
                          // request_id 표시
                          if (data['request_id'] != null)
                            _buildInfoRow('요청 ID', data['request_id'].toString()),
                          // receipt_id 표시
                          if (data['receipt_id'] != null)
                            _buildInfoRow('영수증 ID', data['receipt_id'].toString()),
                          // metadata 표시 (iOS와 동일)
                          if (data['metadata'] != null) ...[
                            if ((data['metadata'] as Map)['plan_key'] != null)
                              _buildInfoRow(
                                '플랜',
                                _capitalize((data['metadata'] as Map)['plan_key'].toString()),
                              ),
                            if ((data['metadata'] as Map)['billing_type'] != null)
                              _buildInfoRow(
                                '결제 주기',
                                (data['metadata'] as Map)['billing_type'].toString(),
                              ),
                          ],
                          // 이벤트 표시
                          if (event.isNotEmpty)
                            _buildInfoRow('이벤트', event),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
