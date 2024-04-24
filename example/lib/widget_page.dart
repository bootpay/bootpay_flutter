import 'package:bootpay/model/widget/widget_payload.dart';
import 'package:bootpay/widget/bootpay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WidgetPage extends StatefulWidget {

  @override
  State<WidgetPage> createState() => WidgetPageState();
}


class WidgetPageState extends State<WidgetPage> {

  WidgetPayload? widgetPayload;
  BootpayWidgetController _controller = BootpayWidgetController();
  // WidgetCon

  double _widgetHeight = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widgetPayload = WidgetPayload();
    widgetPayload?.webApplicationId = '59a7a368396fa64fc5d4a7db';
    widgetPayload?.androidApplicationId = '59a7a368396fa64fc5d4a7db';
    widgetPayload?.iosApplicationId = '59a7a368396fa64fc5d4a7db';

    widgetPayload?.price = 1000;
    widgetPayload?.taxFree = 0;
    widgetPayload?.use_terms = false;

    // _controller.
    _controller.onWidgetResize = (height) {
      print(height);
      if(_widgetHeight == height) return;
      setState(() {
        _widgetHeight = height;
      });
    };
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      SizedBox(height: 10),
                      SizedBox(
                        height: _widgetHeight,
                        child: BootpayWidget(
                          widgetPayload: widgetPayload,
                          controller: _controller,
                  
                        ),
                      ),
                      productWidget(),
                    ],
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    // print('결제하기');
                    // Fluttertoast.showToast(
                    //     msg: "This is Center Short Toast",
                    //     toastLength: Toast.LENGTH_SHORT,
                    //     gravity: ToastGravity.CENTER,
                    //     timeInSecForIosWeb: 1,
                    //     backgroundColor: Colors.red,
                    //     textColor: Colors.white,
                    //     fontSize: 16.0
                    // );
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
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("\n안녕하세요\n\n더모아실용음악학원입니다\n\n행복한 가정의 달 5월이 시작 되었습니다\n\n벌써 2022년의 반이 지나가려고 하는데요\n\n세삼 시간이 정말 빠르게 흐르면서\n\n이번 2022년 신년에 다짐했던 부분들을\n\n잘 이루고 있는지 다들 궁금합니다\n\n그런 기념으로\n더모아실용음악학원에서 가정의 달 5월을 맞이하여\n\n신규 등록시 첫 달 10,000원 할인 이벤트를 준비했습니다\n\n많은 분들께서 악기, 노래를 한 번 배워보고자\n\n너무 감사하게도\n\n더모아실용음악학원을 찾아주시고 있는 요즘입니다\n\n그에 보답하고자 작은 이벤트를 준비했으니\n\n부담없이 연락을 주시면 감사하겠습니다 ^^!!\n\n본 이벤트는 2022년 5월 31일까지 진행되며,\n\n전 과목 모두 신규 등록시 첫 수강료가 10,000원 할인이 됩니다 (취미 , 입시반 포함)\n\n음악을 배워보고 싶지만 소질이 없으시다고 생각하시는분\n\n악기 하나 쯤 다뤄보고 싶다고 생각 하시는 분들\n\n악보를 못 읽는데도 가능할까? 라고 생각하시는 모든 분들\n\n걱정 하지 마시고 본원의 문을 용기내어 두드려 주시면\n\n친절하고 상세하게 상담을 통해 체계적인 레슨을 제공 해드리겠습니다^^!\n\n저희 더모아실용음악학원은\n\n항상 양질의 레슨을 제공하기 위해 최선을 다하겠습니다"),
              )
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5월 수강료', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('320,000', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w600, fontSize: 16)),

            ]
          ), 

        ],
      ),
    );
  }

}