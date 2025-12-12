import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/model/user.dart';
import 'package:bootpay/widget/bootpay_widget.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WidgetPage extends StatefulWidget {
  @override
  State<WidgetPage> createState() => WidgetPageState();
}

class WidgetPageState extends State<WidgetPage> {
  Payload _payload = Payload();
  BootpayWidgetController _controller = BootpayWidgetController();
  final ScrollController _scrollController = ScrollController();

  // Application IDs - 부트페이 관리자에서 확인
  String webApplicationId = '5b8f6a4d396fa665fdc2b5e9';
  String androidApplicationId = '5b8f6a4d396fa665fdc2b5ea';
  String iosApplicationId = '5b8f6a4d396fa665fdc2b5e9';

  // 결제 정보
  static const String ORDER_NAME = '테스트 상품';
  static const double PRICE = 1000.0;

  double _widgetHeight = Bootpay().WIDGET_HEIGHT;

  @override
  void initState() {
    super.initState();
    _initPayload();
    _initController();
  }

  /// Payload 초기화
  void _initPayload() {
    _payload = Payload();
    _payload.webApplicationId = webApplicationId;
    _payload.androidApplicationId = androidApplicationId;
    _payload.iosApplicationId = iosApplicationId;

    _payload.price = PRICE;
    _payload.orderName = ORDER_NAME;
    _payload.orderId = DateTime.now().millisecondsSinceEpoch.toString();

    // Widget 필수 설정
    _payload.widgetKey = 'default-widget';
    _payload.widgetSandbox = true; // 테스트: true, 운영: false
    _payload.widgetUseTerms = true; // 약관동의 UI 사용 여부 

    // User 설정 (선택)
    _payload.user = User();
    _payload.user?.id = 'test_user_1234';
    _payload.user?.username = '홍길동';
    _payload.user?.email = 'test@bootpay.co.kr';
    _payload.user?.phone = '01012341234';

    // Extra 설정 (선택)
    _payload.extra = Extra();
    _payload.extra?.appScheme = 'bootpayFlutterExample';
    // displaySuccessResult, displayErrorResult 기본값 false (권장)
    // 가맹점에서 직접 결제 결과 페이지 구현
  }

  /// WidgetController 초기화
  void _initController() {
    // 위젯 준비 완료
    _controller.onWidgetReady = () {
      debugPrint('[Widget] ===== READY =====');
    };

    // 위젯 높이 변경
    _controller.onWidgetResize = (height) {
      debugPrint('[Widget] ===== RESIZE: $height =====');
      if (_widgetHeight == height) return;
      setState(() {
        _widgetHeight = height;
      });
    };

    // 결제수단 변경
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

    // 약관동의 변경
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

  /// 가격 포맷팅
  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(price.toInt())}원';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('결제하기'),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    _buildProductWidget(),
                    SizedBox(height: 10),
                    SizedBox(
                      height: _widgetHeight,
                      child: BootpayWidget(
                        payload: _payload,
                        controller: _controller,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  /// 상품 정보 위젯
  Widget _buildProductWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '주문상품',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ORDER_NAME,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _formatPrice(PRICE),
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 결제 버튼
  Widget _buildPayButton() {
    final isCompleted = _payload.widgetIsCompleted;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: isCompleted ? Colors.blueAccent : Colors.grey,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: isCompleted ? _goPayment : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 56,
            child: Center(
              child: Text(
                '${_formatPrice(PRICE)} 결제하기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 결제 요청
  void _goPayment() {
    if (!_payload.widgetIsCompleted) {
      _showAlert('알림', '결제수단 선택과 약관동의를 완료해주세요.');
      return;
    }

    debugPrint('[Widget] Request Payment: ${_payload.toJson()}');

    _controller.requestPayment(
      context: context,
      payload: _payload,
      onCancel: (String data) {
        debugPrint('[Widget] Cancel: $data');
        // 취소 후 위젯 재로드 (재시도 가능)
        Future.delayed(Duration(milliseconds: 500), () {
          _controller.reloadWidget();
        });
      },
      onError: (String data) {
        debugPrint('[Widget] Error: $data');
        // 에러 후 위젯 재로드 (재시도 가능)
        Future.delayed(Duration(milliseconds: 500), () {
          _controller.reloadWidget();
        });
      },
      onClose: () {
        debugPrint('[Widget] Close');
        if (!kIsWeb) {
          Bootpay().dismiss(context);
        }
      },
      onConfirm: (String data) {
        debugPrint('[Widget] Confirm: $data');
        // 서버에서 결제 정보 검증 후 true/false 반환
        return true;
      },
      onIssued: (String data) {
        debugPrint('[Widget] Issued (가상계좌 발급): $data');
      },
      onDone: (String data) {
        debugPrint('[Widget] Done: $data');
        // 가맹점 결제 결과 페이지로 이동
        _showPaymentResult(data);
      },
    );
  }

  /// 결제 완료 결과 표시
  void _showPaymentResult(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('결제 완료'),
        content: Text('결제가 성공적으로 완료되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // 이전 화면으로 이동
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 알림 다이얼로그
  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }
}
