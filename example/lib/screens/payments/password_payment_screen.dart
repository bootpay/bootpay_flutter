import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/config/bootpay_config.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/bootpay_helper.dart';
import 'package:bootpay_flutter_example/deprecated/api_provider.dart';

/// 비밀번호 결제 화면 (Android PasswordPaymentActivity / iOS PasswordController)
class PasswordPaymentScreen extends StatefulWidget {
  const PasswordPaymentScreen({Key? key}) : super(key: key);

  @override
  State<PasswordPaymentScreen> createState() => _PasswordPaymentScreenState();
}

class _PasswordPaymentScreenState extends State<PasswordPaymentScreen> {
  final ApiProvider _provider = ApiProvider();

  final String _productName = 'USB-C 허브 (7포트)';
  final String _productDescription = 'HDMI, USB 3.0, SD카드 리더기가 포함된 올인원 USB-C 허브입니다.\n다양한 기기와 호환됩니다.';
  final double _productPrice = 1000;
  int _quantity = 1;
  bool _isLoading = false;

  // 결제 완료 플래그 및 결과 데이터
  bool _isPaymentDone = false;
  String? _paymentResultData;

  double get _totalPrice => _productPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('비밀번호 결제'),
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
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.usb, size: 80, color: Colors.deepPurple[300]),
                  ),
                  const SizedBox(height: 20),
                  Text(_productName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    '${formatter.format(_productPrice.toInt())}원',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 16),
                  Text(_productDescription, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                  const SizedBox(height: 24),
                  // 안내
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.deepPurple[700]),
                            const SizedBox(width: 8),
                            Text('비밀번호 결제 안내', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.deepPurple[700])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• 사전에 등록된 결제수단으로 간편 결제\n• 6자리 비밀번호 또는 생체인증으로 결제\n• 빠르고 안전한 결제 경험',
                          style: TextStyle(fontSize: 13, color: Colors.deepPurple[900], height: 1.5),
                        ),
                      ],
                    ),
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
                ],
              ),
            ),
          ),
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
          SizedBox(width: 40, child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () => setState(() => _quantity++),
          ),
        ],
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
            onPressed: _isLoading ? null : _requestPasswordPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    '${formatter.format(_totalPrice.toInt())}원 결제하기',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }

  User _generateUser() {
    var user = User();
    user.id = 'user_1234';
    user.gender = 1;
    user.email = 'test@bootpay.co.kr';
    user.phone = '01012345678';
    user.birth = '19880610';
    user.username = '홍길동';
    user.area = '서울';
    return user;
  }

  Future<void> _requestPasswordPayment() async {
    setState(() => _isLoading = true);

    try {
      String userToken = await _getUserToken();
      if (userToken.isEmpty) {
        _showErrorDialog('오류', '사용자 토큰을 가져오는데 실패했습니다.');
        return;
      }
      _executePasswordPayment(userToken);
    } catch (e) {
      _showErrorDialog('오류', '결제 준비 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String> _getUserToken() async {
    String restApplicationId = "";
    String pk = "";

    if (BootpayConfig.ENV == BootpayConfig.ENV_PROMOTION) {
      restApplicationId = "5b8f6a4d396fa665fdc2b5ea";
      pk = "rm6EYECr6aroQVG2ntW0A6LpWnkTgP4uQ3H18sDDUYw=";
    } else {
      restApplicationId = "5b9f51264457636ab9a07cde";
      pk = "sfilSOSVakw+PZA+PRux4Iuwm7a//9CXXudCq9TMDHk=";
    }

    try {
      var res = await _provider.getRestToken(restApplicationId, pk);
      res = await _provider.getEasyPayUserToken(res.body['access_token'], _generateUser());
      return res.body["user_token"] ?? "";
    } catch (e) {
      debugPrint("error : $e");
      return "";
    }
  }

  void _executePasswordPayment(String userToken) {
    Payload payload = Payload();
    payload.webApplicationId = BootpayHelper.webApplicationId;
    payload.androidApplicationId = BootpayHelper.androidApplicationId;
    payload.iosApplicationId = BootpayHelper.iosApplicationId;

    payload.userToken = userToken;
    payload.pg = "스마트로";
    payload.orderName = _productName;
    payload.price = _totalPrice;
    payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    Item item = Item();
    item.name = _productName;
    item.qty = _quantity;
    item.id = 'ITEM_USB_HUB';
    item.price = _productPrice;
    payload.items = [item];

    payload.user = _generateUser();

    Extra extra = Extra();
    extra.appScheme = 'bootpayFlutterExampleV2';
    extra.separatelyConfirmed = false;
    payload.extra = extra;

    Bootpay().requestPassword(
      context: context,
      payload: payload,
      showCloseButton: false,
      onCancel: (String data) => debugPrint('------- onCancel: $data'),
      onError: (String data) => debugPrint('------- onError: $data'),
      onClose: () {
        debugPrint('------- onClose, _isPaymentDone: $_isPaymentDone');
        // 결제 완료 후에는 결과 페이지로 이동
        if (_isPaymentDone && _paymentResultData != null) {
          Future.microtask(() {
            if (mounted) {
              _showPaymentResult(_paymentResultData!);
            }
          });
        }
        // dismiss 호출하지 않음 - Bootpay 내부에서 자동 처리됨
      },
      onIssued: (String data) => debugPrint('------- onIssued: $data'),
      onConfirmAsync: (String data) async => true,
      onDone: (String data) {
        debugPrint('------- onDone: $data');
        _isPaymentDone = true;
        _paymentResultData = data;
        // dismiss 호출하지 않음 - Bootpay 내부에서 자동으로 onClose 호출됨
      },
    );
  }

  void _showPaymentResult(String data) {
    debugPrint('[PasswordPayment] _showPaymentResult called');
    debugPrint('[PasswordPayment] data: $data');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => _PaymentResultPage(data: data)),
    );
    debugPrint('[PasswordPayment] Navigator.push called');
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
        ],
      ),
    );
  }
}

class _PaymentResultPage extends StatelessWidget {
  final String data;
  const _PaymentResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? parsedData;
    try { parsedData = json.decode(data); } catch (e) { parsedData = null; }

    final eventData = parsedData?['data'] as Map<String, dynamic>?;
    final receiptId = eventData?['receipt_id'] ?? '';
    final orderId = eventData?['order_id'] ?? '';
    final orderName = eventData?['order_name'] ?? '';
    final price = eventData?['price'] ?? 0;
    final method = eventData?['method'] ?? '';
    final pg = eventData?['pg'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('결제 완료'), backgroundColor: Colors.white, elevation: 0, foregroundColor: Colors.black, automaticallyImplyLeading: false),
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
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
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
