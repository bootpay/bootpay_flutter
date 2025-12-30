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

/// 일반 결제 화면 (Android DefaultPaymentActivity / iOS DefaultPaymentController)
class DefaultPaymentScreen extends StatefulWidget {
  const DefaultPaymentScreen({Key? key}) : super(key: key);

  @override
  State<DefaultPaymentScreen> createState() => _DefaultPaymentScreenState();
}

class _DefaultPaymentScreenState extends State<DefaultPaymentScreen> {
  // 상품 정보
  final String _productName = '프리미엄 무선 마우스';
  final String _productDescription = '인체공학적 디자인의 고급 무선 마우스입니다.\n정밀한 트래킹과 편안한 그립감을 제공합니다.';
  final double _productPrice = 1000;
  int _quantity = 1;

  String _selectedPg = '라이트페이';
  String _selectedMethod = '카드';

  final List<String> _pgList = ['라이트페이', '나이스페이', 'KG이니시스', '다날'];
  final List<String> _methodList = ['카드', '계좌이체', '가상계좌', '휴대폰'];

  // 결제 완료 플래그 및 결과 데이터
  bool _isPaymentDone = false;
  String? _paymentResultData;

  double get _totalPrice => _productPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('일반 결제'),
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
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.mouse, size: 80, color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 20),
                  // 상품명
                  Text(
                    _productName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // 가격
                  Text(
                    '${formatter.format(_productPrice.toInt())}원',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 상품 설명
                  Text(
                    _productDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // 수량 선택
                  Row(
                    children: [
                      const Text('수량', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      _buildQuantitySelector(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // PG사 선택
                  const Text('PG사 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _pgList.map((pg) => _buildChip(pg, _selectedPg == pg, () {
                      setState(() => _selectedPg = pg);
                    })).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 결제수단 선택
                  const Text('결제수단 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _methodList.map((method) => _buildChip(method, _selectedMethod == method, () {
                      setState(() => _selectedMethod = method);
                    })).toList(),
                  ),
                ],
              ),
            ),
          ),
          // 결제 버튼
          _buildPaymentButton(formatter),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
          ),
          SizedBox(
            width: 40,
            child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => setState(() => _quantity++),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.white,
          border: Border.all(color: selected ? Theme.of(context).primaryColor : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _requestPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              '${formatter.format(_totalPrice.toInt())}원 결제하기',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  void _requestPayment() {
    Payload payload = Payload();
    payload.webApplicationId = BootpayHelper.webApplicationId;
    payload.androidApplicationId = BootpayHelper.androidApplicationId;
    payload.iosApplicationId = BootpayHelper.iosApplicationId;

    payload.pg = _selectedPg;
    payload.method = _selectedMethod;
    payload.orderName = _productName;
    payload.price = _totalPrice;
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // 상품 정보
    Item item = Item();
    item.name = _productName;
    item.qty = _quantity;
    item.id = 'ITEM_MOUSE';
    item.price = _productPrice;
    payload.items = [item];

    // 유저 정보
    User user = User();
    user.id = 'user_1234';
    user.username = '홍길동';
    user.email = 'test@bootpay.co.kr';
    user.phone = '01012345678';
    payload.user = user;

    // 추가 설정
    Extra extra = Extra();
    extra.cardQuota = '0,2,3,4,5,6';
    extra.appScheme = "bootpayFlutterExampleV2://end";
    if (kIsWeb) {
      extra.openType = 'iframe';
    }
    payload.extra = extra;

    Bootpay().requestPayment(
      context: context,
      payload: payload,
      showCloseButton: false,
      onCancel: (String data) {
        debugPrint('------- onCancel: $data');
      },
      onError: (String data) {
        debugPrint('------- onError: $data');
      },
      onClose: () {
        debugPrint('------- onClose, _isPaymentDone: $_isPaymentDone');
        // 웹에서는 결제창을 명시적으로 닫아야 함
        // 결제 완료 후에는 결과 페이지로 이동
        if (_isPaymentDone && _paymentResultData != null) {
          debugPrint('------- onClose -> show result page');
          Future.microtask(() {
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => _PaymentResultPage(data: _paymentResultData!)),
              );
            }
          });
        }
      },
      onIssued: (String data) {
        debugPrint('------- onIssued: $data');
      },
      onConfirmAsync: (String data) async {
        debugPrint('------- onConfirmAsync: $data');
        return true;
      },
      onDone: (String data) {
        debugPrint('------- onDone: $data');
        _isPaymentDone = true;
        _paymentResultData = data; // 결과 데이터 저장
        // dismiss 호출하지 않음 - Bootpay 내부에서 자동으로 onClose 호출됨
      },
    );
  }
}

/// 결제 결과 페이지
class _PaymentResultPage extends StatelessWidget {
  final String data;

  const _PaymentResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    debugPrint('####### PaymentResultPage BUILD #######');
    Map<String, dynamic>? parsedData;
    try {
      parsedData = json.decode(data);
    } catch (e) {
      parsedData = null;
    }

    final eventData = parsedData?['data'] as Map<String, dynamic>?;
    final receiptId = eventData?['receipt_id'] ?? '';
    final orderId = eventData?['order_id'] ?? '';
    final orderName = eventData?['order_name'] ?? '';
    final price = eventData?['price'] ?? 0;
    final method = eventData?['method'] ?? '';
    final pg = eventData?['pg'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('결제 완료'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
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
                    const Text('결제가 완료되었습니다', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    _buildInfoRow('주문명', orderName),
                    _buildInfoRow('결제금액', '${NumberFormat('#,###').format(price)}원'),
                    _buildInfoRow('결제수단', '$pg - $method'),
                    _buildInfoRow('주문번호', orderId),
                    _buildInfoRow('영수증ID', receiptId),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
          Flexible(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), textAlign: TextAlign.right, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
