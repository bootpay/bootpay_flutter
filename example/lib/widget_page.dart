import 'package:bootpay/bootpay.dart';
import 'package:bootpay/model/extra.dart';
import 'package:bootpay/model/payload.dart';
import 'package:bootpay/widget/bootpay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WidgetPage extends StatefulWidget {

  @override
  State<WidgetPage> createState() => WidgetPageState();
}


class WidgetPageState extends State<WidgetPage> {

  // WidgetPayloadTemp? _widgetPayload;
  // WidgetPayload? _selectedInfo;
  Payload? _payload;
  BootpayWidgetController _controller = BootpayWidgetController();
  final ScrollController _scrollController = ScrollController();


  // String webApplicationId = '59a568d3e13f3336c21bf707';
  // String androidApplicationId = '59a568d3e13f3336c21bf708';
  // String iosApplicationId = '59a568d3e13f3336c21bf709';

  // String webApplicationId = '65af4990ca8deb00600454ba';
  // String androidApplicationId = '65af4990ca8deb00600454bb';
  // String iosApplicationId = '65af4990ca8deb00600454bc';

  String webApplicationId = '65af4990ca8deb00600454ba';
  String androidApplicationId = '65af4990ca8deb00600454bb';
  String iosApplicationId = '65af4990ca8deb00600454bc';

  double _widgetHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // _widgetPayload = WidgetPayloadTemp();


    _payload = Payload();
    _payload?.price = 28200;
    _payload?.orderName = '5월 수강료';
    _payload?.orderId = DateTime.now().millisecondsSinceEpoch.toString();
    _payload?.webApplicationId = webApplicationId;
    _payload?.androidApplicationId = androidApplicationId;
    _payload?.iosApplicationId = iosApplicationId;
    _payload?.price = 1000;
    _payload?.taxFree = 0;
    _payload?.widgetKey = 'default-widget';
    _payload?.widgetSandbox = true;
    _payload?.widgetUseTerms = true;

    _controller.onWidgetResize = (height) {
      print('onWidgetResize : $height');
      if(_widgetHeight == height) return;
      if(_widgetHeight < height) {
        scrollDown(height - _widgetHeight);
      }
      setState(() {
        _widgetHeight = height;
      });
    };
    _controller.onWidgetChangePayment = (widgetData) {
      print('onWidgetChangePayment22 : ${widgetData?.toJson()}');
      setState(() {
        _payload?.mergeWidgetData(widgetData);
      });
    };
    _controller.onWidgetChangeAgreeTerm = (widgetData) {
      print('onWidgetChangeAgreeTerm : ${widgetData?.toJson()}');
      setState(() {
        _payload?.mergeWidgetData(widgetData);
      });
    };
    _controller.onWidgetReady = () {
      print('onWidgetReady');
    };
  }

  void scrollDown(double diff) {
    final double currentPosition = _scrollController.position.pixels;
    final double targetPosition = currentPosition + diff;

    _scrollController.animateTo(
      targetPosition,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      // color: Colors.white,
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
                      productWidget(),
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
                )
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                color: (_payload?.widgetIsCompleted ?? false) ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    goBootpayPayment();
                  },
                  child: Container(
                    height: 60,
                    child: Center(child: Text('28,200원 결제하기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget productWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Text('* 모의고사비 등 기타 경비가 포함된 금액입니다. * 정규수업용 교재비는 별도입니다. * 입학금은 별도로 받지 않습니다. * 학급당 학생수는 40명 대 (종로학원 50명 대)입니다. * 등록한 후, 대학에 추가 합격했을 경우 추가 합격을 통지 받은 날로부터 3일 이내에 환불신청서(소정양식)와 합격증을 제시하면 개강 전에는 전액을 환불해주고, 개강 후부터는 수강료 환불 기준에 따라서 환불합니다.'),
          Text('주문상품', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          Container(
              width: double.infinity,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("\n안녕하세요\n\n더모아실용음악학원입니다\n\n행복한 가정의 달 5월이 시작 되었습니다\n\n벌써 2022년의 반이 지나가려고 하는데요\n\n세삼 시간이 정말 빠르게 흐르면서\n\n이번 2022년 신년에 다짐했던 부분들을\n\n잘 이루고 있는지 다들 궁금합니다\n\n그런 기념으로\n더모아실용음악학원에서 가정의 달 5월을 맞이하여\n\n신규 등록시 첫 달 10,000원 할인 이벤트를 준비했습니다\n\n많은 분들께서 악기, 노래를 한 번 배워보고자\n\n너무 감사하게도\n\n더모아실용음악학원을 찾아주시고 있는 요즘입니다\n\n그에 보답하고자 작은 이벤트를 준비했으니\n\n부담없이 연락을 주시면 감사하겠습니다 ^^!!"),
              )
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5월 수강료', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('28,200원', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 16)),

            ]
          ), 

        ],
      ),
    );
  }

  void goBootpayPayment() {
    if((_payload?.widgetIsCompleted ?? false) == false) return;

    Bootpay().requestPayment(
      context: context,
      payload: _payload,
      showCloseButton: false,

      // closeButton: Icon(Icons.close, size: 35.0, color: Colors.black54),
      onCancel: (String data) {
        print('------- onCancel 1 : $data');
      },
      onError: (String data) {
        print('------- onError: $data');
      },
      onClose: () {
        print('------- onClose');
        if (!kIsWeb) {
          Bootpay().dismiss(context); //명시적으로 부트페이 뷰 종료 호출
        }
      },
      onConfirm: (String data)  {
        print('------- onConfirm: $data');
        return true;
      },
      onIssued: (String data) {
        print('------- onIssued: $data');
      },
      onDone: (String data) {
        print('------- onDone: $data');
      },
    );
  }

}