import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/bootpay_helper.dart';

/// 정기결제 (인증) 화면 (Android SubscriptionActivity / iOS SubscriptionController)
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final String _productName = '프리미엄 멤버십 (월간)';
  final String _productDescription = '매월 자동으로 결제되는 프리미엄 멤버십입니다.\n다양한 혜택과 할인을 제공합니다.';
  final double _productPrice = 9900;

  String _selectedPg = '나이스페이';
  final List<String> _pgList = ['나이스페이', '토스', 'KG이니시스'];

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('정기결제 (인증)'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품 이미지
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.card_membership, size: 60, color: Colors.orange[300]),
                        const SizedBox(height: 8),
                        Text('PREMIUM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange[700])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(_productName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${formatter.format(_productPrice.toInt())}원 / 월',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 16),
                  Text(_productDescription, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 24),
                  // 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            Text('인증 정기결제 안내', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange[700])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• PG사에서 제공하는 카드 등록 UI를 사용합니다\n• 3DS 인증을 통한 안전한 카드 등록\n• 등록된 빌링키로 정기 결제 가능',
                          style: TextStyle(fontSize: 13, color: Colors.orange[900], height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // PG사 선택
                  const Text('PG사 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...List.generate(_pgList.length, (index) {
                    final pg = _pgList[index];
                    return _buildRadioTile(pg, _selectedPg == pg, () => setState(() => _selectedPg = pg));
                  }),
                ],
              ),
            ),
          ),
          _buildPaymentButton(formatter),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? Colors.orange : Colors.grey[300]!, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? Colors.orange : Colors.grey),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _requestSubscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              '카드 등록하기 (인증)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _requestSubscription() {
    Payload payload = Payload();
    payload.webApplicationId = BootpayHelper.webApplicationId;
    payload.androidApplicationId = BootpayHelper.androidApplicationId;
    payload.iosApplicationId = BootpayHelper.iosApplicationId;

    payload.pg = _selectedPg;
    payload.orderName = _productName;
    payload.price = _productPrice;
    payload.subscriptionId = DateTime.now().millisecondsSinceEpoch.toString();

    Item item = Item();
    item.name = _productName;
    item.qty = 1;
    item.id = 'ITEM_MEMBERSHIP';
    item.price = _productPrice;
    payload.items = [item];

    User user = User();
    user.id = 'user_1234';
    user.username = '홍길동';
    user.email = 'test@bootpay.co.kr';
    user.phone = '01012345678';
    payload.user = user;

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterExample';
    payload.extra = extra;

    Bootpay().requestSubscription(
      context: context,
      payload: payload,
      showCloseButton: false,
      onCancel: (String data) => debugPrint('------- onCancel: $data'),
      onError: (String data) => debugPrint('------- onError: $data'),
      onClose: () {
        debugPrint('------- onClose');
        if (!kIsWeb) Bootpay().dismiss(context);
      },
      onIssued: (String data) => debugPrint('------- onIssued: $data'),
      onConfirm: (String data) => true,
      onDone: (String data) {
        debugPrint('------- onDone: $data');
        _showSubscriptionResult(data);
      },
    );
  }

  void _showSubscriptionResult(String data) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _SubscriptionResultPage(data: data)),
    );
  }
}

class _SubscriptionResultPage extends StatelessWidget {
  final String data;
  const _SubscriptionResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? parsedData;
    try { parsedData = json.decode(data); } catch (e) { parsedData = null; }

    final eventData = parsedData?['data'] as Map<String, dynamic>?;
    final billingKey = eventData?['billing_key'] ?? '';
    final pg = eventData?['pg'] ?? '';
    final methodSymbol = eventData?['method_symbol'] ?? '';
    final cardName = eventData?['card_name'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('등록 완료'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 80),
                    const SizedBox(height: 24),
                    const Text('카드 등록 완료', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('빌링키가 발급되었습니다', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 32),
                    _buildInfoRow('PG사', pg),
                    _buildInfoRow('결제수단', methodSymbol),
                    _buildInfoRow('카드명', cardName),
                    _buildInfoRow('빌링키', billingKey),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('확인', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
