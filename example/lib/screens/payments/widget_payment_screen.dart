import 'dart:convert';

import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/item.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:bootpay/widget/bootpay_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/bootpay_helper.dart';

/// 위젯 결제 화면 - widget_page.dart와 동일한 구조
class WidgetPaymentScreen extends StatefulWidget {
  const WidgetPaymentScreen({Key? key}) : super(key: key);

  @override
  State<WidgetPaymentScreen> createState() => _WidgetPaymentScreenState();
}

class _WidgetPaymentScreenState extends State<WidgetPaymentScreen> {
  final String _productName = '무선 이어폰 Pro';
  final String _productDescription = '노이즈 캔슬링 기능이 탑재된 프리미엄 무선 이어폰.\n최대 24시간 재생 가능합니다.';
  final double _productPrice = 1000;

  Payload _payload = Payload();
  final BootpayWidgetController _controller = BootpayWidgetController();
  final ScrollController _scrollController = ScrollController();

  // GlobalKey로 BootpayWidget 상태 유지 (iOS Swift SDK의 expandToFullscreen과 동일)
  final GlobalKey _bootpayWidgetKey = GlobalKey();

  double _widgetHeight = Bootpay().WIDGET_HEIGHT;

  // 결제 모드 상태 (전체화면 전환용)
  bool _isPaymentMode = false;

  @override
  void initState() {
    super.initState();
    _initPayload();
    _initController();
  }

  void _initPayload() {
    _payload = Payload();
    _payload.webApplicationId = BootpayHelper.webApplicationId;
    _payload.androidApplicationId = BootpayHelper.androidApplicationId;
    _payload.iosApplicationId = BootpayHelper.iosApplicationId;

    _payload.price = _productPrice;
    _payload.orderName = _productName;
    _payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    _payload.widgetKey = 'default-widget';
    _payload.widgetSandbox = true;
    _payload.widgetUseTerms = true; // 약관동의 UI 사용

    Item item = Item();
    item.name = _productName;
    item.qty = 1;
    item.id = 'ITEM_EARBUDS';
    item.price = _productPrice;
    _payload.items = [item];

    _payload.user = User();
    _payload.user?.id = 'user_1234';
    _payload.user?.username = '홍길동';
    _payload.user?.email = 'test@bootpay.co.kr';
    _payload.user?.phone = '01012341234';

    _payload.extra = Extra();
    _payload.extra?.appScheme = 'bootpayFlutterExample';

    if (kIsWeb) {
      _payload.extra?.openType = 'iframe';
    }
  }

  void _initController() {
    _controller.onWidgetReady = () {
      debugPrint('[Widget] ===== READY =====');
    };

    _controller.onWidgetResize = (height) {
      debugPrint('[Widget] ===== RESIZE: $height =====');
      if (_widgetHeight == height) return;
      setState(() {
        _widgetHeight = height;
      });
    };

    _controller.onWidgetChangePayment = (widgetData) {
      debugPrint('[Widget] ===== CHANGE PAYMENT =====');
      debugPrint('[Widget] widgetData: ${widgetData?.toJson()}');
      debugPrint('[Widget] widgetData.termPassed: ${widgetData?.termPassed}');
      debugPrint('[Widget] widgetData.completed: ${widgetData?.completed}');
      setState(() {
        _payload.mergeWidgetData(widgetData);
      });
      debugPrint('[Widget] After merge - widgetIsCompleted: ${_payload.widgetIsCompleted}');
    };

    _controller.onWidgetChangeAgreeTerm = (widgetData) {
      debugPrint('[Widget] ===== CHANGE AGREE TERM =====');
      debugPrint('[Widget] widgetData: ${widgetData?.toJson()}');
      debugPrint('[Widget] widgetData.termPassed: ${widgetData?.termPassed}');
      debugPrint('[Widget] widgetData.completed: ${widgetData?.completed}');
      setState(() {
        _payload.mergeWidgetData(widgetData);
      });
      debugPrint('[Widget] After merge - widgetIsCompleted: ${_payload.widgetIsCompleted}');
    };
  }

  /// GlobalKey를 사용한 BootpayWidget (상태 유지)
  Widget _buildBootpayWidget() {
    return BootpayWidget(
      key: _bootpayWidgetKey,
      payload: _payload,
      controller: _controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'ko_KR');

    // 결제 모드: 전체화면으로 BootpayWidget 표시
    if (_isPaymentMode) {
      return _buildPaymentModeScreen();
    }

    // 일반 모드: 상품 정보 + 위젯 + 결제 버튼
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('위젯 결제'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상품 이미지
                    Container(
                      width: double.infinity,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.headphones, size: 80, color: Colors.amber[300]),
                    ),
                    const SizedBox(height: 16),
                    Text(_productName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '${formatter.format(_productPrice.toInt())}원',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 12),
                    Text(_productDescription, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text('결제수단 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    // 위젯 결제 컴포넌트
                    SizedBox(
                      height: _widgetHeight,
                      child: _buildBootpayWidget(),
                    ),
                  ],
                ),
              ),
            ),
            _buildPayButton(formatter),
          ],
        ),
      ),
    );
  }

  /// 결제 모드 화면 (전체화면 웹뷰)
  Widget _buildPaymentModeScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('결제'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            debugPrint('[Widget] Payment mode close button pressed');
            setState(() {
              _isPaymentMode = false;
            });
            // 위젯 재로드
            Future.delayed(const Duration(milliseconds: 300), () {
              _controller.reloadWidget();
            });
          },
        ),
      ),
      body: SafeArea(
        child: _buildBootpayWidget(),
      ),
    );
  }

  Widget _buildPayButton(NumberFormat formatter) {
    final isCompleted = _payload.widgetIsCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isCompleted ? _goPayment : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCompleted ? Colors.blueAccent : Colors.grey,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            '${formatter.format(_productPrice.toInt())}원 결제하기',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _goPayment() {
    if (!_payload.widgetIsCompleted) {
      _showAlert('알림', '결제수단 선택과 약관동의를 완료해주세요.');
      return;
    }

    debugPrint('[Widget] ===== Go Payment =====');
    debugPrint('[Widget] Request Payment: ${_payload.toJson()}');

    // iOS Swift SDK와 동일하게 전체화면 모드로 전환 후 결제 요청
    setState(() {
      _isPaymentMode = true;
    });

    // 전체화면 전환 후 약간의 딜레이를 주고 결제 요청 (iOS와 동일하게 0.4초)
    Future.delayed(const Duration(milliseconds: 400), () {
      _executePayment();
    });
  }

  void _executePayment() {
    debugPrint('[Widget] ===== Execute Payment =====');

    // 기존 웹뷰에서 requestPayment 실행 (iOS Swift SDK와 동일)
    _controller.requestPaymentDirect(
      payload: _payload,
      onError: (data) {
        debugPrint('[Widget] onError: $data');
        setState(() {
          _isPaymentMode = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _controller.reloadWidget();
        });
      },
      onCancel: (data) {
        debugPrint('[Widget] onCancel: $data');
        setState(() {
          _isPaymentMode = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _controller.reloadWidget();
        });
      },
      onClose: () {
        debugPrint('[Widget] onClose');
        setState(() {
          _isPaymentMode = false;
        });
        Future.delayed(const Duration(milliseconds: 300), () {
          _controller.reloadWidget();
        });
      },
      onConfirm: (data) {
        debugPrint('[Widget] onConfirm: $data');
        return true;
      },
      onIssued: (data) => debugPrint('[Widget] onIssued: $data'),
      onDone: (data) {
        debugPrint('[Widget] onDone: $data');
        setState(() {
          _isPaymentMode = false;
        });
        _showPaymentResult(data);
      },
    );
  }

  void _showPaymentResult(String data) {
    debugPrint('[Widget] _showPaymentResult called');
    debugPrint('[Widget] data: $data');
    // 결과 페이지로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => _PaymentResultPage(data: data)),
    );
    debugPrint('[Widget] Navigator.pushReplacement called');
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 결제 결과 페이지 (widget_page.dart의 PaymentResultPage와 동일한 구조)
class _PaymentResultPage extends StatelessWidget {
  final String data;

  const _PaymentResultPage({required this.data});

  @override
  Widget build(BuildContext context) {
    debugPrint('[PaymentResultPage] build called with data: $data');

    // JSON 파싱
    Map<String, dynamic>? parsedData;
    try {
      parsedData = json.decode(data);
      debugPrint('[PaymentResultPage] Parsed data: $parsedData');
    } catch (e) {
      debugPrint('[PaymentResultPage] JSON parse error: $e');
      parsedData = null;
    }

    final eventData = parsedData?['data'] as Map<String, dynamic>?;
    final receiptId = eventData?['receipt_id'] ?? '';
    final orderId = eventData?['order_id'] ?? '';
    final orderName = eventData?['order_name'] ?? '';
    final price = eventData?['price'] ?? 0;
    final status = eventData?['status_locale'] ?? '';
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
                    const Text(
                      '결제가 완료되었습니다',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    _buildInfoRow('주문명', orderName),
                    _buildInfoRow('결제금액', '${NumberFormat('#,###').format(price)}원'),
                    _buildInfoRow('결제수단', '$pg - $method'),
                    _buildInfoRow('상태', status),
                    _buildInfoRow('주문번호', orderId),
                    _buildInfoRow('영수증ID', receiptId),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // widget_page.dart와 동일하게 pop() 사용
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
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
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
